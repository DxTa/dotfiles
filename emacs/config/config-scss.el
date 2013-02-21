
(defun tung/setup-scss-mode ()
  (interactive)
  (tung/setup-css-mode))

(add-hook 'scss-mode-hook #'tung/setup-scss-mode)

(eval-after-load 'scss-mode
  '(setq scss-compile-at-save nil))

(eval-after-load 'auto-complete
  '(progn
     (add-to-list 'ac-modes 'scss-mode)
     (add-hook 'scss-mode-hook
               (lambda ()
                 (tung/append-ac-sources '(ac-source-css-property))))))


(provide 'config-scss)
