
(dolist (mode-hook '(;js-mode-hook
                     ruby-mode-hook
                     php-mode-hook
                     coffee-mode-hook
                     emacs-lisp-mode-hook
                     go-mode-hook))
  (add-hook mode-hook 'flycheck-mode))

(eval-after-load 'flycheck
  '(setq flycheck-checkers (delq 'emacs-lisp-checkdoc flycheck-checkers)))


(provide 'config-flycheck)
