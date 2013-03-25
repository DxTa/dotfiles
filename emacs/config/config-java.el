
(defun tung/setup-java-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (setq c-basic-offset 4)
  (define-key java-mode-map (kbd "<tab>") #'indent-for-tab-command))

(add-hook 'java-mode-hook #'tung/setup-java-mode)

(eval-after-load 'javadoc-lookup
  '(progn
     (setq javadoc-lookup-cache-dir "~/.emacs.d/data/javadoc-cache")
     (defun add-javadoc-artifact (group artifact version)
       (interactive "sGroup: \nsArtifact: \nsVersion: ")
       (javadoc-add-artifacts `[,group ,artifact ,version]))))

(global-set-key (kbd "C-h j") #'javadoc-lookup)


(provide 'config-java)
