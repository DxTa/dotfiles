
(evil-mode t)

(eval-after-load 'evil
  '(progn
     (require 'sackspace)
     (sack/install-in-evil)

     (add-hook 'tung/programming-environment-hook
               (lambda () (surround-mode t)))

     (setq evil-move-cursor-back nil
           evil-mode-line-format nil
           evil-cross-lines t

           evil-shift-width 2
           evil-flash-delay 1
           evil-complete-all-buffers nil

           evil-emacs-state-cursor '("orange" box))

     (evil-set-toggle-key "<f12>")

     (mapc (lambda (mode)
             (evil-set-initial-state mode 'emacs))
           '(nrepl-mode
             nrepl-popup-buffer-mode
             epa-key-list-mode
             ack-mode
             magit-log-edit-mode))

     (tung/fill-keymap evil-normal-state-map
                       "C-j" (icalled (next-line 10))
                       "C-k" (icalled (previous-line 10))
                       "]" 'evil-jump-item
                       "j" 'evil-next-visual-line
                       "k" 'evil-previous-visual-line
                       "M-=" 'cleanup-buffer

                       "gp" 'simpleclip-paste

                       "C-:" 'eval-expression

                       "C-e" 'end-of-line

                       "SPC" 'evil-toggle-fold
                       "zc" 'evil-close-folds
                       "zo" 'evil-open-folds

                       "RET" 'evil-ex-nohighlight

                       "C-d" 'mc/mark-next-like-this
                       "C-S-d" 'mc/mark-all-like-this

                       ",," 'evil-buffer

                       "gi" 'inline-variable)

     (tung/fill-keymap evil-insert-state-map
                       "C-a" 'back-to-indentation
                       "C-e" 'end-of-line
                       "C-h" 'delete-backward-char

                       "M-h" " => "
                       "M-a" "@"
                       "M-q" 'balance-tags)

     (tung/fill-keymap evil-visual-state-map
                       "Y" 'simpleclip-copy
                       "<tab>" (kbd ">gv")
                       "<backtab>" (kbd "<gv")
                       "C-a" 'align-regexp

                       "C-d" 'mc/mark-next-like-this
                       "M-d" 'mc/mark-all-like-this

                       "ge" 'extract-variable)

     (tung/fill-keymap evil-motion-state-map
                       "]" 'evil-jump-item)

     (evil-add-hjkl-bindings ibuffer-mode-map)

     ;; Fix for input-method in insert state
     (add-hook 'evil-insert-state-exit-hook
               (lambda () (setq evil-input-method nil)))

     ;; Escape Compatibility
     (define-key isearch-mode-map (kbd "ESC") 'isearch-abort)
     (defadvice ac-stop
       (after tung/return-evil-normal-state activate)
       (evil-normal-state))
     (defadvice mc/keyboard-quit
       (after tung/return-evil-normal-state activate)
       (evil-normal-state))

     ;; Change cursor in Terminal mode
     ;; Some terminal support escape sequence
     ;; iTerm and Konsole: "\033]50;CursorShape=?\x7"
     ;;   - 2: underline
     ;;   - 1: line
     ;;   - 0: block
     ;; Xterm: "\033[? q"
     ;;   - 4: underline
     ;;   - 6: line
     ;;   - 2: block
     ;; Some others require hack
     (add-hook 'evil-insert-state-entry-hook
               (lambda ()
                 (unless (window-system)
                   (send-string-to-terminal "\033]12;#00afff\007"))))
     (add-hook 'evil-normal-state-entry-hook
               (lambda ()
                 (unless (window-system)
                   (send-string-to-terminal "\033]12;gray\007"))))
     (add-hook 'evil-emacs-state-entry-hook
               (lambda ()
                 (unless (window-system)
                   (send-string-to-terminal "\033]12;orange\007"))))
     ))


(provide 'config-evil)
