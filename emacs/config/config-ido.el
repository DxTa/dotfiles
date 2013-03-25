
(ido-mode t)

(eval-after-load 'ido
  '(progn
     (setq ido-enable-prefix nil
           ido-enable-flex-matching t
           ido-enable-dot-prefix t
           ido-use-virtual-buffers t
           ido-auto-merge-delay-time 15
           ido-create-new-buffer 'always
           ido-use-url-at-point nil
           ido-use-filename-at-point nil
           ido-ignore-extensions t
           ido-save-directory-list-file (expand-file-name "~/.emacs.d/data/ido.last")
           ido-everywhere t
           ido-ignore-buffers '("\\` ")
           ido-ignore-files '("ido.last" ".*-autoloads.el"))

     (defun minibuffer-home ()
       (interactive)
       (if (looking-back "/")
           (insert "~/")
         (call-interactively 'self-insert-command)))

     (defun minibuffer-insert-word-at-point ()
       (interactive)
       (let (word beg)
         (with-current-buffer (window-buffer (minibuffer-selected-window))
           (setq word (thing-at-point 'word)))
         (insert word)))


     (add-hook 'ido-minibuffer-setup-hook
               (lambda ()
                 (tung/fill-keymap ido-common-completion-map
                                   "ESC" 'ido-exit-minibuffer
                                   "C-h" 'delete-backward-char
                                   "~" #'minibuffer-home
                                   "C-i" #'minibuffer-insert-word-at-point)))

     (ido-ubiquitous-mode t)
     (ido-vertical-mode t)

     (setq ido-decorations
           '("\n>> " "" "\n   " "\n   ..." "[" "]"
             " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]"
             "\n>> " ""))))


(provide 'config-ido)
