
(tung/add-auto-mode 'web-mode '("\\.ejs$"))

(defun tung/setup-html-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (web-mode)
  (autopair-mode -1)
  (zencoding-mode t))

(add-hook 'html-mode-hook #'tung/setup-html-mode)
(add-hook 'sgml-mode-hook #'tung/setup-html-mode)
(add-hook 'nxml-mode-hook #'tung/setup-html-mode)

;; (eval-after-load 'zencoding
  ;; (define-key zencoding-mode-keymap (kbd "M-e") 'zencoding-expand-line))

(eval-after-load 'auto-complete
  '(progn
     (add-to-list 'ac-modes 'html-mode)
     (add-to-list 'ac-modes 'sgml-mode)
     (add-to-list 'ac-modes 'nxml-mode)
     (add-to-list 'ac-modes 'web-mode)))


(provide 'config-html)
