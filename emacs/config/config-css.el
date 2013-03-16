
(defun tung/setup-css-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (set (make-local-variable 'imenu-generic-expression)
       css-imenu-expression)
  (tung/fill-keymap css-mode-map "C-c C-s" #'css-helper-explain)
  (rainbow-mode t))

(add-hook 'css-mode-hook #'tung/setup-css-mode)

(eval-after-load 'css-mode
  '(progn
     (setq css-indent-offset 2)
     (defconst css-imenu-expression
       `((nil
          ,(concat "^\\([ \t]*[^@:{}\n][^:{}]+\\(?::"
                   (regexp-opt css-pseudo-ids t)
                   "\\(?:([^)]+)\\)?[^:{\n]*\\)*\\)\\(?:\n[ \t]*\\)*{")
          1)))
     ))

(eval-after-load 'auto-complete
  '(add-to-list 'ac-modes 'css-mode))


(provide 'config-css)
