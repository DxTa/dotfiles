
(defun tung/setup-emacs-lisp-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (rainbow-delimiters-mode)
  (eldoc-mode t))

(add-hook 'emacs-lisp-mode-hook #'tung/setup-emacs-lisp-mode)

(eval-after-load 'config-hippie-expand
  '(add-hook 'emacs-lisp-mode-hook
             '(lambda ()
                (tung/append-he-sources '(try-complete-lisp-symbol-partially
                                           try-complete-lisp-symbol)))))

(eval-after-load 'auto-complete
  '(add-to-list 'ac-modes 'lisp-interaction-mode))


(provide 'config-emacs-lisp)
