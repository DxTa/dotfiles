
(global-git-gutter-mode t)

(eval-after-load 'git-gutter
  '(progn
     (setq git-gutter:modified-sign "  * "
           git-gutter:added-sign "  + "
           git-gutter:deleted-sign "  - "
           git-gutter:always-show-gutter t)

     (set-face-foreground 'git-gutter:modified "#deae3e")
     (set-face-foreground 'git-gutter:added "#81af34")
     (set-face-foreground 'git-gutter:deleted "red")))


(eval-after-load 'magit
  '(defadvice magit-quit-session
     (after update-git-gutter activate)
     (dolist (buffer (buffer-list))
       (with-current-buffer buffer (git-gutter)))))

(eval-after-load 'eproject
  '(defadvice git-gutter:root-directory
     (around eproject-git-root activate)
     (when eproject-mode
       (setq ad-return-value eproject-root))))

(eval-after-load 'projectile
  '(defadvice git-gutter:root-directory
     (around projectile-git-root activate)
     (when (projectile-project-p)
       (setq ad-return-value (projectile-project-root)))))


(provide 'config-git-gutter)
