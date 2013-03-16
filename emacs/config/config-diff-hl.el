
(eval-after-load 'diff-hl
  '(progn
     (setq diff-hl-draw-borders nil)

     (defun customize-diff-hl-faces (frame)
       (set-face-attribute 'diff-hl-insert frame :inherit nil :foreground "#81af34")
       (set-face-attribute 'diff-hl-delete frame :inherit nil :foreground "#ff0000")
       (set-face-attribute 'diff-hl-change frame :background nil :foreground "#deae3e"))

     (customize-diff-hl-faces nil)
     (add-hook 'after-make-frame-functions #'customize-diff-hl-faces)

     (define-fringe-bitmap 'diff-hl-bmp-insert
       [0 24 24 126 126 24 24 0])

     (define-fringe-bitmap 'diff-hl-bmp-delete
       [0 0 0 126 126 0 0 0])

     (define-fringe-bitmap 'diff-hl-bmp-change
       [0 60 126 126 126 126 60 0])

     (defadvice magit-quit-session
       (after update-diff-hl activate)
       (dolist (buffer (buffer-list))
         (with-current-buffer buffer (diff-hl-update))))

     (defun diff-hl-fringe-spec (type pos)
       (let* ((key (cons type pos))
              (val (gethash key diff-hl-spec-cache)))
         (unless val
           (let* ((face-sym (intern (concat "diff-hl-" (symbol-name type))))
                  (bmp-sym (intern (concat "diff-hl-bmp-" (symbol-name type)))))
             (setq val (propertize " " 'display `((left-fringe ,bmp-sym ,face-sym))))
             (puthash key val diff-hl-spec-cache)))
         val))))

(global-diff-hl-mode 1)

(provide 'config-diff-hl)
