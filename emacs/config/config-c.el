
(defun tung/setup-c-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (define-key c-mode-map (kbd "<tab>") #'indent-for-tab-command)
  (setq c-basic-offset 2
        indent-tabs-mode nil))

(add-hook 'c-mode-hook #'tung/setup-c-mode)

(eval-after-load 'auto-complete
  '(progn
     (add-to-list 'ac-modes 'objc-mode)))

(require 'google-c-style)
(add-hook 'c-mode-common-hook #'google-set-c-style)


(provide 'config-c)
