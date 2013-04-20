
(defun tung/setup-go-mode ()
  (interactive)
  (setq tab-width 4)
  (tung/setup-programming-environment))

(add-hook 'go-mode-hook #'tung/setup-go-mode)


(provide 'config-go)
