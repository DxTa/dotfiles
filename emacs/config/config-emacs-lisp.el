
(defun tung/setup-emacs-lisp-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (rainbow-delimiters-mode)
  (setq eldoc-idle-delay 0)
  ;; (eldoc-mode t)
  )

(add-hook 'emacs-lisp-mode-hook #'tung/setup-emacs-lisp-mode)

(add-hook 'after-change-major-mode-hook
          (lambda ()
            (unless (eq major-mode 'emacs-lisp-mode)
              (eldoc-mode nil))))

(eval-after-load 'config-hippie-expand
  '(add-hook 'emacs-lisp-mode-hook
             '(lambda ()
                (tung/append-he-sources '(try-complete-lisp-symbol-partially
                                           try-complete-lisp-symbol)))))

(eval-after-load 'auto-complete
  '(progn
     (add-to-list 'ac-modes 'lisp-interaction-mode)
     (add-hook 'emacs-lisp-mode-hook
               (lambda ()
                 (tung/append-ac-sources '(ac-source-features
                                           ac-source-functions
                                           ac-source-variables
                                           ac-source-symbols))))))


(provide 'config-emacs-lisp)
