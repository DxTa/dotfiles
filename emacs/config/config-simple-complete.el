
(setq tab-always-indent 'complete)
(add-to-list 'completion-styles 'initials t)
(add-hook 'after-change-major-mode-hook
          (lambda ()
            (setq completion-at-point-functions '(evil-complete-next))))

(provide 'config-simple-complete)
