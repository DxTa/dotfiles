{:user
 {:plugins [[cider/cider-nrepl "0.6.0"]]
  :injections [(require '[clojure.pprint :refer [pprint]])
               (require '[clojure.repl :as repl])]
  :global-vars {*print-length* 120 *print-level* 5}}}
