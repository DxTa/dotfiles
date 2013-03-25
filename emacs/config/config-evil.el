
(evil-mode t)

(eval-after-load 'evil
  '(progn
     ;; (sackspace-mode t)

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
                       "<tab>" 'evil-jump-item
                       "j" 'evil-next-visual-line
                       "k" 'evil-previous-visual-line

                       "gp" 'simpleclip-paste

                       "C-:" 'eval-expression

                       "C-e" 'end-of-line

                       "SPC" 'evil-toggle-fold
                       "zc" 'evil-close-folds
                       "zo" 'evil-open-folds

                       "RET" 'evil-ex-nohighlight

                       ",," 'evil-buffer

                       "gi" 'inline-variable)

     (tung/fill-keymap evil-insert-state-map
                       "C-a" 'back-to-indentation
                       "C-e" 'end-of-line
                       "C-d" 'delete-char

                       "M-h" " => "
                       "M-a" "@"
                       "M-q" 'balance-tags)

     (tung/fill-keymap evil-visual-state-map
                       "Y" (lambda ()
                             (interactive)
                             (call-interactively 'simpleclip-copy)
                             (deactivate-mark t))

                       "C-a" 'align-regexp

                       "ge" 'extract-variable)

     (tung/fill-keymap evil-motion-state-map
                       "<tab>" 'evil-jump-item)

     (evil-add-hjkl-bindings ibuffer-mode-map)

     ;; gdefaults
     (defadvice evil-ex-pattern-whole-line
       (after evil-global-defaults activate)
       (setq ad-return-value "g"))

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
     ;; Others requires hack
     (defvar evil-terminal-cursor
       '((normal . "gray")
         (insert . "#00afff")
         (emacs . "orange")))

     (defun evil-update-terminal-cursor ()
       (let* ((color (cdr (assoc evil-state evil-terminal-cursor)))
              (terminal-string-format
               (if (getenv "TMUX" (selected-frame))
                   "\033Ptmux;\033\033]12;%s\007\033\\" "\033]12;%s\007"))
              (terminal-string (format terminal-string-format color)))
         (when (and color (not (window-system)))
           (send-string-to-terminal terminal-string))))

     (add-hook 'evil-insert-state-entry-hook #'evil-update-terminal-cursor)
     (add-hook 'evil-normal-state-entry-hook #'evil-update-terminal-cursor)
     (add-hook 'evil-emacs-state-entry-hook #'evil-update-terminal-cursor)

     ))


(provide 'config-evil)
