
(eval-after-load 'javadoc-lookup
  '(progn
     (javadoc-add-artifacts ["org.ow2.asm" "asm" "4.1"]
                            ["org.ow2.asm" "asm-analysis" "4.1"]
                            ["org.ow2.asm" "asm-tree" "4.1"]
                            ["net.sf.jgrapht" "jgrapht" "0.8.3"])
     (javadoc-add-roots "~/build/jdk/docs/api")))
