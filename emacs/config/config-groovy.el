
(tung/add-auto-mode 'groovy-mode '("\\.gradle$"))

(defun tung/setup-groovy-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (setq c-basic-offset 4))

(add-hook 'groovy-mode-hook #'tung/setup-groovy-mode)

(eval-after-load 'auto-complete
  '(add-to-list 'ac-modes 'groovy-mode))


(provide 'config-groovy)
