
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

     (fset 'ido-directory-too-big-p #'ignore)
     (ido-mode t)
     (setq ido-decorations
           '("\n>> " "" "\n   " "\n   ..." "[" "]"
             " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]"))

     (add-hook 'ido-minibuffer-setup-hook
               (lambda ()
                 (progn
                   (set (make-local-variable 'truncate-lines) nil)
                   (tung/fill-keymap ido-common-completion-map
                                     "C-n" 'ido-next-match
                                     "C-p" 'ido-prev-match
                                     "C-h" 'delete-backward-char
                                     "~" (icalled (if (looking-back "/") (insert "~/")
                                                    (call-interactively 'self-insert-command)))))))
     (ido-ubiquitous-mode t)))


;; Ido imenu
(defun ido-goto-symbol ()
  (interactive)
  (imenu--cleanup)
  (setq imenu--index-alist nil)
  (let* ((index (imenu--make-index-alist))
         (symbols (reduce
                   (lambda (lst x)
                     (cond ((markerp (cdr x)) (append lst `(,x)))
                           ((listp (cdr x)) (append lst (cdr x)))
                           (t lst)))
                   index :initial-value '()))
         (selected (ido-completing-read "Symbol: " (mapcar 'car symbols))))
    (imenu (assoc selected symbols))))


;; Recentf
(defun recentf-ido-find-file ()
  (interactive)
  (let ((file (ido-completing-read "Recent file: " recentf-list nil t)))
    (when file (find-file file))))


(provide 'config-ido)
