
(tung/add-auto-mode 'web-mode '("\\.ejs$"))

(defun tung/setup-html-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (web-mode))

(add-hook 'html-mode-hook #'tung/setup-html-mode)
(add-hook 'sgml-mode-hook #'tung/setup-html-mode)
(add-hook 'nxml-mode-hook #'tung/setup-html-mode)

(global-set-key (kbd "M-e") 'simplezen-expand)

(eval-after-load 'auto-complete
  '(progn
     (add-to-list 'ac-modes 'html-mode)
     (add-to-list 'ac-modes 'sgml-mode)
     (add-to-list 'ac-modes 'nxml-mode)
     (add-to-list 'ac-modes 'web-mode)))


(provide 'config-html)
