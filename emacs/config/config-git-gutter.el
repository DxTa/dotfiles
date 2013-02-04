
(global-git-gutter-mode t)

(add-hook 'after-save-hook
          (lambda () (when eproject-root (git-gutter))))

(defadvice magit-quit-session
  (after update-git-gutter activate)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer (git-gutter))))

(defadvice git-gutter:root-directory
  (around eproject-git-root activate)
  (when eproject-root
    (setq ad-return-value eproject-root)))

(eval-after-load 'git-gutter
  '(progn
     (setq git-gutter:modified-sign " * "
           git-gutter:added-sign " + "
           git-gutter:deleted-sign " - ")

     (set-face-foreground 'git-gutter:modified "#deae3e")
     (set-face-foreground 'git-gutter:added "#81af34")
     (set-face-foreground 'git-gutter:deleted "red")))

(provide 'config-git-gutter)
