
;;;; evil
(td/after 'evil-autoloads
  (evil-mode t)
  (setq-default mode-line-format
                (cons '(evil-mode ("" evil-mode-line-tag)) mode-line-format)))

(td/after 'evil
  (when (boundp 'global-surround-mode)
    (global-surround-mode))

  (setq evil-move-cursor-back nil
        evil-mode-line-format nil
        evil-cross-lines t
        evil-emacs-state-cursor '("orange"))

  (mapc (lambda (mode)
          (evil-set-initial-state mode 'emacs))
        '(cider-popup-buffer-mode
          undo-tree-visualizer-mode
          epa-key-list-mode))

  (mapc (lambda (mode)
          (evil-set-initial-state mode 'insert))
        '(cider-repl-mode
          magin-log-edit-mode
          nodejs-repl-mode))

  (evil-define-key 'normal org-mode-map
    "zz" #'org-cycle)

  (td/bind evil-normal-state-map
           "''" (td/cmd (evil-goto-mark ?`))
           "C-j" (td/cmd (evil-next-visual-line 10))
           "C-k" (td/cmd (evil-previous-visual-line 10))
           "j" #'evil-next-visual-line
           "k" #'evil-previous-visual-line
           "<tab>" #'evil-jump-item
           "gp" #'simpleclip-paste
           "C-:" #'eval-expression
           "z SPC" #'evil-toggle-fold
           "C-f" #'ace-jump-char-mode
           "gi" #'inline-variable
           ",," #'evil-buffer
           ",m" #'recompile
           ",w" #'evil-write-all
           ",e" #'ido-find-file)
  (td/bind evil-insert-state-map
           "C-a" #'back-to-indentation
           "C-e" #'end-of-line
           "C-d" #'delete-char
           "M-h" " => "
           "M-a" "@")
  (td/bind evil-visual-state-map
           "Y" #'simpleclip-copy
           "M-a" #'align=
           "C-a" #'back-to-indentation
           "C-e" #'end-of-line
           "ge" #'extract-variable
           "*" #'evil-visualstar/begin-search-forward
           "#" #'evil-visualstar/begin-search-backward)
  (td/bind evil-motion-state-map
           "C-a" #'back-to-indentation
           "C-e" #'end-of-line
           "<tab>" #'evil-jump-item
           "TAB" #'evil-jump-item)

  (defadvice evil-ex-pattern-whole-line
    (after evil-global-defaults activate)
    (setq ad-return-value "g")))

(provide 'td-evil)