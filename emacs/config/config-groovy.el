
(tung/add-auto-mode 'groovy-mode '("\\.gradle$"))

(defun tung/setup-groovy-mode ()
  (interactive)
  (tung/setup-programming-environment))

(add-hook 'groovy-mode-hook #'tung/setup-groovy-mode)


(provide 'config-groovy)
