
(defun tung/setup-scss-mode ()
  (interactive)
  (tung/setup-css-mode))

(add-hook 'scss-mode-hook #'tung/setup-scss-mode)

(eval-after-load 'scss-mode
  '(setq scss-compile-at-save nil))

(eval-after-load 'auto-complete
  '(add-to-list 'ac-modes 'scss-mode))


(provide 'config-scss)
