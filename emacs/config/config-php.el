
(tung/add-auto-mode 'php-mode
                    '("\\.php$" "\\.tpl$" "\\.ctp$"))

(defun tung/setup-php-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (php-enable-drupal-coding-style))

(add-hook 'php-mode-hook #'tung/setup-php-mode)

(eval-after-load 'auto-complete
  '(add-to-list 'ac-modes 'php-mode))


(provide 'config-php)
