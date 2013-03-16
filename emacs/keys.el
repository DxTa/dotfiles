(tung/fill-keymap (current-global-map)
                  "M-m" 'smex
                  "C-c C-m" 'smex-major-mode-commands
                  "M-`" 'other-frame
                  "C-x C-b" 'ibuffer
                  "C-l" 'comment-or-uncomment-region-or-line

                  "C-+" 'text-scale-increase
                  "C--" 'text-scale-decrease

                  "M-j" 'other-window
                  "M-k" 'other-window

                  "C-c g" 'magit-status
                  "C-c f" 'ido-find-file
                  "M-p" 'eproject-find-file
                  "C-c a" 'eproject-ack
                  "C-c g" 'magit-status
                  "C-c b" 'ido-switch-buffer
                  "C-c o" 'imenu
                  "C-c r" 'recentf-ido-find-file
                  "C-c t" 'find-tag

                  "C-c Q" 'delete-window
                  "C-c q" 'delete-frame
                  "C-c k" 'kill-buffer-and-window
                  "C-c 1" 'delete-other-windows

                  "C-c c" 'server-edit
                  "C-c d" 'dired-jump

                  "C-c C-e" 'eval-and-replace)


(tung/fill-keymap minibuffer-local-map
                  "C-w" 'backward-kill-word)

;; Hot binding key
(defmacro tung/hot-key (name key)
  `(defun ,name (fns)
     (global-set-key (kbd ,key) fns)))

(tung/hot-key f5 "<f5>")
(tung/hot-key f6 "<f6>")
(tung/hot-key f7 "<f7>")
(tung/hot-key f8 "<f8>")
(tung/hot-key f9 "<f9>")
(tung/hot-key f10 "<f10>")
