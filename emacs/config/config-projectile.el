
(projectile-global-mode)

(eval-after-load 'projectile
  '(progn
     (global-set-key (kbd "M-p") 'projectile-find-file)
     (global-set-key (kbd "C-c a") 'projectile-ack)))


(provide 'config-projectile)
