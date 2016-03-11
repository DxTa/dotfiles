{:user
 {:dependencies [[slamhound "RELEASE"]]
  :aliases {"slamhound" ["run" "-m" "slam.hound"]}
  :plugins [[cider/cider-nrepl "RELEASE"]]
  :injections [(require '[clojure.pprint :refer [pprint]])
               (require '[clojure.repl :as repl])]
  :global-vars {*print-length* 120 *print-level* 5}}}
