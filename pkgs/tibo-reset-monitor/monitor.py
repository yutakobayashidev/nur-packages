#!/usr/bin/env python3
"""Poll executed Codex reset announcements and deliver Discord notices."""
import argparse
import datetime as dt
import email.utils
import fcntl
import json
import math
import os
from pathlib import Path
import re
import sqlite3
import time
import urllib.error
import urllib.parse
import urllib.request
from zoneinfo import ZoneInfo

API_URL = "https://codex-resets.com/api/v1/resets"


class MonitorError(Exception):
    """Safe, fixed error identifiers only; never include a credential URL."""


class RateLimited(MonitorError):
    def __init__(self, seconds):
        super().__init__("rate_limited")
        self.seconds = seconds


def log(event, **fields):
    print(json.dumps({"timestamp": dt.datetime.now(dt.timezone.utc).isoformat(),
                      "event": event, **fields}, ensure_ascii=False), flush=True)


def retry_after(headers, body, now):
    candidates = [300.0]
    value = headers.get("Retry-After")
    if value:
        try:
            candidates.append(float(value))
        except ValueError:
            try:
                candidates.append(email.utils.parsedate_to_datetime(value).timestamp() - now)
            except (TypeError, ValueError, OverflowError):
                pass
    try:
        candidates.append(float(json.loads(body).get("retry_after", 0)))
    except (ValueError, TypeError, AttributeError):
        pass
    return max(x for x in candidates if math.isfinite(x))


def request_json(url, payload=None, *, opener=urllib.request.urlopen, now=time.time):
    headers = {"Accept": "application/json", "User-Agent": "tibo-reset-monitor/0.1.0"}
    body = None
    if payload is not None:
        headers["Content-Type"] = "application/json"
        body = json.dumps(payload, ensure_ascii=False).encode()
    request = urllib.request.Request(url, data=body, headers=headers)
    try:
        with opener(request, timeout=30) as response:
            if not 200 <= response.status < 300:
                raise MonitorError("http_status")
            raw = response.read(2_000_001)
    except urllib.error.HTTPError as error:
        if error.code == 429:
            raw = error.read(65_536)
            raise RateLimited(retry_after(error.headers, raw, now())) from None
        raise MonitorError("http_status") from None
    except (urllib.error.URLError, TimeoutError, OSError):
        raise MonitorError("network_error") from None
    if len(raw) > 2_000_000:
        raise MonitorError("response_too_large")
    try:
        return json.loads(raw)
    except (ValueError, UnicodeError):
        raise MonitorError("invalid_json") from None


def timestamp(value):
    if not isinstance(value, str):
        raise MonitorError("invalid_timestamp")
    try:
        parsed = dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        raise MonitorError("invalid_timestamp") from None
    if parsed.tzinfo is None:
        raise MonitorError("invalid_timestamp")
    return parsed


def safe_url(value):
    if not isinstance(value, str) or any(c.isspace() for c in value):
        raise MonitorError("invalid_source_url")
    try:
        parsed = urllib.parse.urlsplit(value)
        if parsed.scheme != "https" or not parsed.hostname or parsed.username or parsed.password:
            raise ValueError
    except ValueError:
        raise MonitorError("invalid_source_url") from None
    return urllib.parse.quote(value, safe=":/?=&%#@+,-._~")


def validate_record(record):
    if not isinstance(record, dict):
        raise MonitorError("invalid_record")
    if not isinstance(record.get("id"), str) or not 1 <= len(record["id"]) <= 64:
        raise MonitorError("invalid_record")
    if record.get("reset_type") not in ("regular", "banked") or not isinstance(record.get("text"), str):
        raise MonitorError("invalid_record")
    if record.get("status") == "scheduled" or "scheduled_for" in record:
        raise MonitorError("scheduled_record")
    timestamp(record.get("announced_at"))
    source = record.get("source")
    if not isinstance(source, dict) or source.get("type") not in ("x_post", "observed"):
        raise MonitorError("invalid_source")
    if source["type"] == "x_post":
        if source.get("author") != "thsottiaux" or "url" not in source:
            raise MonitorError("invalid_source")
    if "url" in source:
        safe_url(source["url"])
    return record


def fetch_resets(fetch, api_url=API_URL):
    records, cursors = {}, set()
    cursor = None
    while True:
        query = {"limit": 100, "order": "asc"}
        if cursor is not None:
            query["cursor"] = cursor
        page = fetch(api_url + "?" + urllib.parse.urlencode(query))
        if not isinstance(page, dict) or not isinstance(page.get("data"), list):
            raise MonitorError("invalid_page")
        pagination = page.get("pagination")
        if not isinstance(pagination, dict) or type(pagination.get("has_more")) is not bool:
            raise MonitorError("invalid_pagination")
        for record in page["data"]:
            validate_record(record)
            records.setdefault(record["id"], record)
        cursor = pagination.get("next_cursor")
        if not pagination["has_more"]:
            if "next_cursor" not in pagination or cursor is not None:
                raise MonitorError("invalid_pagination")
            break
        if not isinstance(cursor, str) or not re.fullmatch(r"[A-Za-z0-9_-]{1,1024}", cursor) or cursor in cursors:
            raise MonitorError("invalid_pagination")
        cursors.add(cursor)
    return sorted(records.values(), key=lambda x: (timestamp(x["announced_at"]), x["id"]))


def markdown(text):
    return re.sub(r"([\\`*_~|\[\]<>])", r"\\\1", text)


def clip(text, units):
    """Discord limits are safest measured as UTF-16 code units."""
    encoded = text.encode("utf-16-le", errors="replace")
    if len(encoded) <= units * 2:
        return text
    return encoded[:(units - 1) * 2].decode("utf-16-le", errors="ignore") + "…"


def format_time(value, zone):
    value = value.astimezone(ZoneInfo(zone))
    weekday = "月火水木金土日"[value.weekday()]
    return f"{value.month}月{value.day}日({weekday}) {value:%H:%M} ({value.tzname()})"


def build_payload(record):
    announced = timestamp(record["announced_at"])
    banked = record["reset_type"] == "banked"
    source = record["source"]
    observed = source["type"] == "observed"
    title = "🎟️ Codex のリセット権付与を検知しました！" if banked else "🎉 Codex の利用枠リセットを検知しました！"
    if observed:
        title = "🔎 Codex のリセット権付与が観測されました" if banked else "🔎 Codex の利用枠リセットが観測されました"
    lines = ["🟪 リセット権の付与（banked）" if banked else "🟧 通常リセット",
             f"🇯🇵 日本時間　**{format_time(announced, 'Asia/Tokyo')}**",
             f"🇺🇸 米国太平洋時間　**{format_time(announced, 'America/Los_Angeles')}**",
             "※ 発表・初回観測の時刻です。"]
    if observed:
        lines.append("※ トラッカーによる観測情報です。公式発表とは限りません。")
    if record["text"]:
        lines.extend(["", "> " + clip(markdown(record["text"][:1000]).replace("\n", "\n> "), 2000)])
    if source.get("url"):
        label = "情報を見る" if observed else "発表を見る"
        link = safe_url(source["url"])
        if len(link) <= 1500:
            lines.append(f"🔗 [{label}]({link})")
    return {"username": "Tibo Reset Monitor", "allowed_mentions": {"parse": []}, "embeds": [{
        "title": title, "description": clip("\n".join(lines), 4096), "color": 0x9B59B6 if banked else 0xFF8C00,
        "timestamp": announced.isoformat(), "footer": {"text": "Codex Resets · 非公式トラッカー"},
    }]}


def open_state(directory):
    directory = Path(directory)
    directory.mkdir(parents=True, exist_ok=True, mode=0o700)
    db = sqlite3.connect(directory / "state.sqlite3")
    db.execute("CREATE TABLE IF NOT EXISTS seen (id TEXT PRIMARY KEY)")
    db.execute("CREATE TABLE IF NOT EXISTS metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL)")
    db.commit()
    return db


def metadata(db, key, default=None):
    row = db.execute("SELECT value FROM metadata WHERE key=?", (key,)).fetchone()
    return row[0] if row else default


def poll(db, fetch, send, *, api_url=API_URL, now=time.time):
    if now() < float(metadata(db, "next_allowed_at", "0")):
        log("deferred")
        return
    try:
        records = fetch_resets(fetch, api_url)
        if metadata(db, "initialized") is None:
            with db:
                db.executemany("INSERT OR IGNORE INTO seen VALUES (?)", [(r["id"],) for r in records])
                db.execute("INSERT INTO metadata VALUES ('initialized','1')")
            log("baseline_created", count=len(records))
            return
        count = 0
        for record in records:
            if db.execute("SELECT 1 FROM seen WHERE id=?", (record["id"],)).fetchone():
                continue
            result = send(build_payload(record))
            if not isinstance(result, dict) or not isinstance(result.get("id"), str) or not result["id"]:
                raise MonitorError("missing_discord_ack")
            with db:
                db.execute("INSERT INTO seen VALUES (?)", (record["id"],))
            count += 1
            log("notification_sent", reset_id=record["id"], reset_type=record["reset_type"])
        log("poll_completed", sent=count)
    except RateLimited as error:
        with db:
            db.execute("INSERT OR REPLACE INTO metadata VALUES ('next_allowed_at', ?)", (str(now() + error.seconds),))
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--webhook-file", type=Path, required=True)
    parser.add_argument("--state-dir", type=Path, required=True)
    parser.add_argument("--api-url", default=API_URL)
    args = parser.parse_args()
    os.umask(0o077)
    try:
        args.state_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
        with (args.state_dir / "monitor.lock").open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            webhook = args.webhook_file.read_text().strip()
            safe_url(webhook)
            parsed = urllib.parse.urlsplit(webhook)
            if parsed.hostname not in ("discord.com", "discordapp.com") or not parsed.path.startswith("/api/webhooks/"):
                raise MonitorError("invalid_webhook")
            query = urllib.parse.parse_qsl(parsed.query, keep_blank_values=True)
            query = [(k, v) for k, v in query if k != "wait"] + [("wait", "true")]
            webhook = urllib.parse.urlunsplit(parsed._replace(query=urllib.parse.urlencode(query)))
            db = open_state(args.state_dir)
            try:
                poll(db, request_json, lambda payload: request_json(webhook, payload), api_url=args.api_url)
            finally:
                db.close()
    except (MonitorError, OSError, sqlite3.Error) as error:
        log("poll_failed", error=str(error) if isinstance(error, MonitorError) else type(error).__name__)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
