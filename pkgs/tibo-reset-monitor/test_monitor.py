import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
import urllib.error
from unittest.mock import patch

import monitor


def record(id="a", when="2026-10-13T05:06:00Z", kind="regular", source=None, text="Done!"):
    return {"id": id, "reset_type": kind, "announced_at": when, "text": text,
            "source": source or {"type": "x_post", "author": "thsottiaux", "url": "https://x.com/thsottiaux/status/123"}}


def page(records=(), cursor=None):
    return {"data": list(records), "pagination": {"has_more": cursor is not None, "next_cursor": cursor}}


class MonitorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.db = monitor.open_state(self.temp.name)
        self.output = io.StringIO()
        self.capture = contextlib.redirect_stdout(self.output)
        self.capture.__enter__()
        self.sent = []

    def tearDown(self):
        self.capture.__exit__(None, None, None)
        self.db.close()
        self.temp.cleanup()

    def send(self, payload):
        self.sent.append(payload)
        return {"id": str(len(self.sent))}

    def poll(self, records, sender=None):
        monitor.poll(self.db, lambda _: page(records), sender or self.send)

    def test_bootstrap_is_silent_then_restart_deduplicates_and_orders(self):
        self.poll([record("old")])
        self.assertEqual(self.sent, [])
        self.db.close()
        self.db = monitor.open_state(self.temp.name)
        self.poll([record("late", "2026-10-15T00:00:00Z"), record("old"), record("early", "2026-10-14T00:00:00Z")])
        self.assertEqual(len(self.sent), 2)
        self.assertEqual(self.sent[0]["embeds"][0]["timestamp"], "2026-10-14T00:00:00+00:00")
        self.poll([record("late"), record("early"), record("old")])
        self.assertEqual(len(self.sent), 2)

    def test_empty_first_poll_establishes_baseline(self):
        self.poll([])
        self.poll([record()])
        self.assertEqual(len(self.sent), 1)

    def test_pagination_fetches_every_page_before_sending(self):
        self.poll([])
        calls = []
        def fetch(url):
            calls.append(url)
            return page([record("a")], "next") if len(calls) == 1 else page([record("b")])
        def send(payload):
            self.assertEqual(len(calls), 2)
            return self.send(payload)
        monitor.poll(self.db, fetch, send)
        self.assertIn("cursor=next", calls[1])
        self.assertEqual(len(self.sent), 2)

    def test_duplicate_ids_across_pages_send_once(self):
        self.poll([])
        pages = iter([page([record()], "next"), page([record()])])
        monitor.poll(self.db, lambda _: next(pages), self.send)
        self.assertEqual(len(self.sent), 1)

    def test_failed_later_page_does_not_initialize_or_send(self):
        pages = iter([page([record()], "next"), {"data": []}])
        with self.assertRaises(monitor.MonitorError):
            monitor.poll(self.db, lambda _: next(pages), self.send)
        self.assertIsNone(monitor.metadata(self.db, "initialized"))
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM seen").fetchone()[0], 0)
        self.assertEqual(self.sent, [])

    def test_cursor_cycle_rejected(self):
        with self.assertRaises(monitor.MonitorError):
            monitor.poll(self.db, lambda _: page([record()], "loop"), self.send)
        self.assertIsNone(monitor.metadata(self.db, "initialized"))

    def test_delivery_failure_preserves_only_acknowledged_ids(self):
        self.poll([])
        def send(payload):
            if self.sent:
                raise monitor.MonitorError("network_error")
            return self.send(payload)
        with self.assertRaises(monitor.MonitorError):
            self.poll([record("a"), record("b"), record("c")], send)
        self.assertEqual(self.db.execute("SELECT id FROM seen").fetchall(), [("a",)])
        self.poll([record("a"), record("b"), record("c")])
        self.assertEqual(len(self.sent), 3)

    def test_discord_ack_required(self):
        self.poll([])
        with self.assertRaises(monitor.MonitorError):
            self.poll([record()], lambda _: {})
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM seen").fetchone()[0], 0)

    def test_rate_limit_defers_after_restart_and_stops_later_events(self):
        self.poll([])
        def limited(_):
            raise monitor.RateLimited(600)
        with self.assertRaises(monitor.RateLimited):
            monitor.poll(self.db, lambda _: page([record("a"), record("b")]), limited, now=lambda: 1000)
        self.db.close()
        self.db = monitor.open_state(self.temp.name)
        monitor.poll(self.db, lambda _: self.fail("request during defer"), self.send, now=lambda: 1599)
        monitor.poll(self.db, lambda _: page([record("a"), record("b")]), self.send, now=lambda: 1600)
        self.assertEqual(len(self.sent), 2)

    def test_api_rate_limit_persists_before_bootstrap(self):
        def limited(_):
            raise monitor.RateLimited(600)
        with self.assertRaises(monitor.RateLimited):
            monitor.poll(self.db, limited, self.send, now=lambda: 1000)
        self.assertEqual(monitor.metadata(self.db, "next_allowed_at"), "1600")
        self.assertIsNone(monitor.metadata(self.db, "initialized"))

    def test_invalid_record_fails_closed(self):
        invalid = record("bad")
        invalid["reset_type"] = "scheduled"
        with self.assertRaises(monitor.MonitorError):
            self.poll([record(), invalid])
        self.assertIsNone(monitor.metadata(self.db, "initialized"))


class PayloadTests(unittest.TestCase):
    def test_japan_pacific_date_and_dst(self):
        payload = monitor.build_payload(record())
        text = payload["embeds"][0]["description"]
        self.assertIn("10月13日(火) 14:06 (JST)", text)
        self.assertIn("10月12日(月) 22:06 (PDT)", text)
        winter = monitor.build_payload(record(when="2026-12-01T10:00:00Z"))
        self.assertIn("12月1日(火) 02:00 (PST)", winter["embeds"][0]["description"])

    def test_banked_is_not_announced_as_completed_limit_reset(self):
        payload = monitor.build_payload(record(kind="banked"))
        self.assertIn("リセット権", payload["embeds"][0]["title"])
        self.assertNotIn("利用枠リセット", payload["embeds"][0]["title"])
        self.assertEqual(payload["embeds"][0]["color"], 0x9B59B6)

    def test_observed_without_link_is_labelled_nonofficial(self):
        payload = monitor.build_payload(record(source={"type": "observed"}))
        embed = payload["embeds"][0]
        self.assertIn("観測", embed["title"])
        self.assertIn("公式発表とは限りません", embed["description"])
        self.assertNotIn("発表を見る", embed["description"])

    def test_external_text_is_bounded_escaped_and_mentions_disabled(self):
        payload = monitor.build_payload(record(text="@everyone [click](https://evil.invalid) **bold**\n" * 1000))
        self.assertEqual(payload["allowed_mentions"], {"parse": []})
        text = payload["embeds"][0]["description"]
        self.assertLess(len(text), 4096)
        self.assertIn(r"\[click\]", text)
        self.assertIn(r"\*\*bold\*\*", text)

    def test_unsafe_source_links_rejected(self):
        for url in ["javascript:alert(1)", "https://user:secret@example.com", "https://example.com/\nabc"]:
            with self.subTest(url=url), self.assertRaises(monitor.MonitorError):
                monitor.validate_record(record(source={"type": "observed", "url": url}))


class HttpTests(unittest.TestCase):
    def test_429_header_and_body(self):
        def opener(request, timeout):
            raise urllib.error.HTTPError(request.full_url, 429, "SECRET", {"Retry-After": "900"}, io.BytesIO(b'{"retry_after":1200}'))
        with self.assertRaises(monitor.RateLimited) as caught:
            monitor.request_json("https://discord.com/api/webhooks/SECRET", {}, opener=opener)
        self.assertEqual(caught.exception.seconds, 1200)
        self.assertNotIn("SECRET", str(caught.exception))

    def test_transport_error_does_not_leak_webhook(self):
        def opener(request, timeout):
            raise urllib.error.URLError("https://discord.com/api/webhooks/SECRET")
        with self.assertRaises(monitor.MonitorError) as caught:
            monitor.request_json("https://discord.com/api/webhooks/SECRET", {}, opener=opener)
        self.assertEqual(str(caught.exception), "network_error")

    def test_503_does_not_leak_response_body(self):
        def opener(request, timeout):
            raise urllib.error.HTTPError(request.full_url, 503, "SECRET", {}, io.BytesIO(b'SECRET'))
        with self.assertRaises(monitor.MonitorError) as caught:
            monitor.request_json("https://example.com", opener=opener)
        self.assertEqual(str(caught.exception), "http_status")

class BoundaryTests(unittest.TestCase):
    def test_long_url_and_adversarial_text_stay_under_discord_limits(self):
        for text in ["\n" * 10000, "😀\n" * 5000, "*" * 10000]:
            for url in ["https://x.com/" + "a" * 100000, "https://x.com/" + "a" * 1400]:
                payload = monitor.build_payload(record(text=text, source={"type": "observed", "url": url}))
                embed = payload["embeds"][0]
                self.assertLessEqual(len(embed["description"].encode("utf-16-le")) // 2, 4096)
                self.assertLess(len(json.dumps(payload)), 20000)

    def test_real_scheduled_schema_is_rejected(self):
        event = record()
        event.update(status="scheduled", scheduled_for="2026-12-01T00:00:00Z")
        with self.assertRaises(monitor.MonitorError):
            monitor.validate_record(event)

    def test_main_uses_wait_ack_and_persistent_state(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)
            secret = path / "webhook"
            secret.write_text("https://discord.com/api/webhooks/123/SECRET?wait=false")
            argv = ["monitor", "--state-dir", str(path / "state"), "--webhook-file", str(secret)]
            sent = []
            events = []
            def request(url, payload=None):
                if payload is None:
                    return page(events)
                self.assertIn("wait=true", url)
                self.assertNotIn("wait=false", url)
                sent.append(payload)
                return {"id": "message"}
            with patch("sys.argv", argv), patch.object(monitor, "request_json", request), contextlib.redirect_stdout(io.StringIO()) as output:
                self.assertEqual(monitor.main(), 0)
                events.append(record())
                self.assertEqual(monitor.main(), 0)
                self.assertEqual(monitor.main(), 0)
            self.assertEqual(len(sent), 1)
            self.assertNotIn("SECRET", output.getvalue())

    def test_main_rejects_concurrent_invocation(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)
            secret = path / "webhook"
            secret.write_text("https://discord.com/api/webhooks/123/SECRET")
            argv = ["monitor", "--state-dir", directory, "--webhook-file", str(secret)]
            with (path / "monitor.lock").open("a") as lock:
                monitor.fcntl.flock(lock, monitor.fcntl.LOCK_EX | monitor.fcntl.LOCK_NB)
                with patch("sys.argv", argv), patch.object(monitor, "request_json", side_effect=AssertionError("must not request")), contextlib.redirect_stdout(io.StringIO()) as output:
                    self.assertEqual(monitor.main(), 1)
            self.assertNotIn("SECRET", output.getvalue())


if __name__ == "__main__":
    unittest.main()
