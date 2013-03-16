
(dolist (case-fn '(electric-case-c-init
                   electric-case-java-init))
  (autoload case-fn "electric-case"))

(loop for (mode case-fn)
      in '((cc-mode-hook electric-case-c-init)
           (java-mode-hook electric-case-java-init)
           (ruby-mode electrict-case-c-init))
      do
      (add-hook mode case-fn))


(provide 'config-case)
