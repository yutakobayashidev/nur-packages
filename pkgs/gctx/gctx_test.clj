(require '[babashka.fs :as fs]
         '[babashka.process :as p]
         '[clojure.string :as string]
         '[clojure.test :refer [deftest is run-tests]])

(def script (first *command-line-args*))

(defn write-executable [path content]
  (spit (str path) content)
  (fs/set-posix-file-permissions path "rwxr-xr-x"))

(defn run-gctx [tmp & args]
  (let [path (str tmp ":" (System/getenv "PATH"))
        activation-log (str (fs/path tmp "activation"))
        fzf-log (str (fs/path tmp "fzf-input"))]
    @(p/process (into ["bb" script] args)
                {:env {"PATH" path
                       "GCTX_ACTIVATION_LOG" activation-log
                       "GCTX_FZF_LOG" fzf-log}
                 :out :string
                 :err :string})))

(deftest command-behavior
  (fs/with-temp-dir [tmp {}]
    (write-executable
     (fs/path tmp "gcloud")
     "#!/bin/sh\nif [ \"$*\" = \"config configurations list --format=json\" ]; then\n  printf '%s\\n' '[{\"name\":\"development\",\"is_active\":false,\"properties\":{\"core\":{\"project\":\"dev-project\",\"account\":\"dev@example.com\"}}},{\"name\":\"production\",\"is_active\":true,\"properties\":{\"core\":{\"project\":\"prod-project\",\"account\":\"prod@example.com\"}}}]'\nelif [ \"$*\" = \"config configurations activate development\" ]; then\n  printf '%s\\n' \"$*\" > \"$GCTX_ACTIVATION_LOG\"\nelse\n  exit 1\nfi\n")
    (write-executable
     (fs/path tmp "fzf")
     "#!/bin/sh\ntee \"$GCTX_FZF_LOG\" | grep development\n")

    (let [help-result (run-gctx tmp "--help")
          current-result (run-gctx tmp "--current")
          switch-result (run-gctx tmp)
          activation-log (fs/path tmp "activation")]
      (is (zero? (:exit help-result)))
      (is (string/includes? (:out help-result)
                            "gctx - gcloud named configurations switcher"))
      (is (zero? (:exit current-result)))
      (is (= "production" (string/trim (:out current-result))))
      (is (zero? (:exit switch-result)))
      (is (= "switched to development"
             (string/trim (:out switch-result)))
          (:err switch-result))
      (is (fs/exists? activation-log)
          (if (fs/exists? (fs/path tmp "fzf-input"))
            (slurp (str (fs/path tmp "fzf-input")))
            (pr-str switch-result)))
      (when (fs/exists? activation-log)
        (is (= "config configurations activate development"
               (string/trim (slurp (str activation-log))))))

      (fs/delete-if-exists activation-log)
      (write-executable (fs/path tmp "fzf") "#!/bin/sh\nexit 1\n")
      (let [cancel-result (run-gctx tmp)]
        (is (zero? (:exit cancel-result)))
        (is (not (fs/exists? activation-log)))))))

(let [{:keys [fail error]} (run-tests)]
  (System/exit (if (zero? (+ fail error)) 0 1)))
