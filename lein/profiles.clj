{:user
 {
  ;; :dependencies [[com.cemerick/pomegranate "0.2.0"]
  ;;                [org.clojure/tools.trace "0.7.6"]]
  :injections [(require '[clojure.pprint :refer [pprint]])]
  :global-vars {*warn-on-reflection* true
                *print-length* 120
                *print-level* 5}}}
