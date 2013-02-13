
(electric-pair-mode t)
;; (electric-indent-mode t)
;; (electric-layout-mode t)

(eval-after-load 'electric
  '(progn
     (defun tung/electric-brace ()
       (when (and (eq last-command-event ?\n)
                  (looking-at "}"))
         (evil-open-above 0)))
     (add-hook 'post-self-insert-hook #'tung/electric-brace t)

     (defun tung/electric-parenthesis ()
       (when (and (eq last-command-event ?\s)
                  (or (and (looking-back "( " (- (point) 2))
                           (looking-at ")"))
                      (and (looking-back "{ " (- (point) 2))
                           (looking-at "}"))
                      (and (looking-back "\\[ " (- (point) 2))
                           (looking-at "\\]"))))
         (insert " ")
         (backward-char 1)))
     (add-hook 'post-self-insert-hook #'tung/electric-parenthesis t)
     ))


(provide 'config-electric)
