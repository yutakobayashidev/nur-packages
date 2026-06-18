#!/usr/bin/env bb

;; gcloud named configurations switcher

(require '[babashka.process :as p]
         '[cheshire.core :as json]
         '[clojure.java.shell :refer [sh]]
         '[clojure.string :as string]
         '[clojure.tools.cli :refer [parse-opts]])

(def cli-opts
  [["-c" "--current" "show the current configuration name"]
   ["-h" "--help"]])

(defn show-help [summary]
  (println
   (string/join
    "\n"
    ["gctx - gcloud named configurations switcher"
     ""
     "Options:"
     summary])))

(defn fzf [xs]
  (let [proc (p/process ["fzf"]
                        {:in (string/join "\n" xs)
                         :err :inherit
                         :out :string})]
    (string/trim-newline (:out @proc))))

(defn set-config [name]
  (when (seq name)
    (let [result (sh "gcloud" "config" "configurations" "activate" name)]
      (if (zero? (:exit result))
        (println (str "switched to " name))
        (binding [*out* *err*]
          (println (:err result)))))))

(defn get-entries []
  (let [result (sh "gcloud" "config" "configurations" "list" "--format=json")]
    (if (zero? (:exit result))
      (json/parse-string (:out result) true)
      (do
        (binding [*out* *err*]
          (println (:err result)))
        []))))

(defn account [entry]
  (get-in entry [:properties :core :account]))

(defn project [entry]
  (get-in entry [:properties :core :project]))

(defn show-current-config []
  (->> (get-entries)
       (filter :is_active)
       first
       :name
       println))

(defn display-entry [entry]
  (let [mark (if (:is_active entry) "*" " ")
        name (:name entry)
        project (or (project entry) "-")
        account (or (account entry) "-")]
    (str mark " " name "\t" project "\t" account)))

(defn select-config []
  (let [entries (get-entries)
        display->name (into {}
                            (map (fn [entry]
                                   [(display-entry entry) (:name entry)])
                                 entries))
        selected (fzf (keys display->name))]
    (set-config (get display->name selected))))

(let [opts (parse-opts *command-line-args* cli-opts)]
  (cond
    (get-in opts [:options :help])
    (show-help (:summary opts))

    (get-in opts [:options :current])
    (show-current-config)

    :else
    (select-config)))
