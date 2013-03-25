
;; Commands
(defun byte-recompile-config ()
  (interactive)
  (dolist (dir '("~/.emacs.d/config" "~/.emacs.d/vendor"))
    (byte-recompile-directory dir 0)))

(defun indent-defun ()
  "Indent the current defun."
  (interactive)
  (save-excursion
    (mark-defun)
    (indent-region (region-beginning) (region-end))))

(defun extract-variable (begin end var)
  (interactive "r\nsVariable name: ")
  (kill-region begin end)
  (insert var)
  (forward-line -1)
  (newline-and-indent)
  (insert var " = ")
  (yank))

(defun inline-variable ()
  (interactive)
  (let ((var (current-word)))
    (re-search-forward "= ")
    (let ((value (buffer-substring (point) (point-at-eol))))
      (kill-whole-line)
      (search-forward var)
      (replace-match value))))

(defun balance-tags ()
  (interactive)
  (let ((tag nil)
        (quote nil))
    (save-excursion
      (do ((skip 1))
          ((= 0 skip))
        (re-search-backward "</?[a-zA-Z0-9_-]+")
        (cond ((looking-at "</") (setq skip (+ skip 1)))
              ((not (looking-at "<[a-zA-Z0-9_-]+[^>]*?/>"))
               (setq skip (- skip 1)))))
      (when (looking-at "<\\([a-zA-Z0-9_-]+\\)")
        (setq tag (match-string 1)))
      (if (eq (get-text-property (point) 'face)
              'font-lock-string-face)
          (setq quote t)))
    (when tag
      (setq quote
            (and quote (not (eq (get-text-property (- (point) 1) 'face)
                                'font-lock-string-face))))
      (if quote (insert "\""))
      (insert "</" tag ">")
      (if quote (insert "\"")))))


(defun eval-and-replace ()
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))


(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face))))


(defun rename-this-file-and-buffer (new-name)
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (file-name (buffer-file-name)))
    (unless file-name
      (error "Buffer '%s' is not a file!" name))
    (if (get-buffer new-name)
        (message "Buffer named '%s' already exists!" new-name)
      (progn
        (rename-file file-name new-name t)
        (rename-buffer new-name)
        (set-visited-file-name new-name)
        (set-buffer-modified-p nil)))))

(defalias 'rem 'rename-this-file-and-buffer)


(defun delete-this-file ()
  (interactive)
  (or (buffer-file-name)
      (error "Buffer '%s' is not a file!" (buffer-name)))
  (when (yes-or-no-p (format "Really delete '%s'?"
                             (file-name-nondirectory buffer-file-name)))
    (delete-file (buffer-file-name))
    (kill-this-buffer)))

(defalias 'del 'delete-this-file)


(defun sudo-edit (&optional arg)
  (interactive "p")
  (if arg
      (find-file (concat "/sudo::" (ido-read-file-name "File: ")))
    (find-alternate-file (concat "/sudo::" buffer-file-name))))


(defun open-with ()
  (interactive)
  (when buffer-file-name
    (shell-command
     (concat (cond ((eq system-type 'darwin) "open")
                   ((eq system-type 'linux) "xgd-open")
                   (t (read-shell-command "Open current file with: ")))
             " " buffer-file-name))))


(defun google ()
  (interactive)
  (browse-url
   (concat "http://www.google.com/?q="
           (url-hexify-string
            (if mark-active
                (buffer-substring (region-beginning) (region-end))
              (read-string "Google: "))))))


(defun display-todo-marker ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "TODO:" nil t)
      (let ((overlay (make-overlay (- (point) 5) (point))))
        (overlay-put overlay
                     'before-string
                     (propertize (format "A")
                                 'display '(left-fringe right-triangle)))))))


(defun cleanup-buffer ()
  (interactive)
  (indent-region (point-min) (point-max))
  (untabify (point-min) (point-max))
  (whitespace-cleanup))


(defun kill-other-buffers ()
  (interactive)
  (dolist (buffer (buffer-list))
    (unless (or (eql buffer (current-buffer)) (not (buffer-file-name buffer)))
      (kill-buffer buffer))))


(defun comment-or-uncomment-line (&optional lines)
  (interactive "P")
  (comment-or-uncomment-region
   (line-beginning-position)
   (line-end-position lines)))

(defun comment-or-uncomment-region-or-line (&optional lines)
  (interactive "P")
  (if (use-region-p)
      (if (< (mark) (point))
          (comment-or-uncomment-region (mark) (point))
        (comment-or-uncomment-region (point) (mark)))
    (comment-or-uncomment-line lines)))


(defun align= (begin end)
  (interactive "r")
  (align-regexp begin end "\\(\\s-*\\)[=|:]" 1 1))


;; Functions
(defun tung/occurences (regex string)
  (let ((matches '())
        (last-match 0))
    (while (string-match regex string last-match)
      (add-to-list 'matches (match-string 0 string))
      (setq last-match (match-end 0)))
    matches))

(defun tung/count-occurences (regex string)
  (length (tung/occurences regex string)))

(defun tung/strip-tags (html)
  (replace-regexp-in-string
   " +" " " (replace-regexp-in-string
             "\n" "" (replace-regexp-in-string
                      "<.*?>" "" html))))

(defun tung/read-url (url &optional text)
  (let* ((command (format "curl -L '%s'" url))
         (html (shell-command-to-string command)))
    (if text
        (tung/strip-tags html)
      html)))

(defun tung/fill-keymap (keymap &rest mappings)
  (while mappings
    (let* ((spec (pop mappings))
           (cmd (pop mappings))
           (key (typecase spec
                  (vector spec)
                  (string (read-kbd-macro spec)))))
      (define-key keymap key cmd))))

(defun tung/add-auto-mode (mode patterns)
  (dolist (pattern patterns)
    (add-to-list 'auto-mode-alist (cons pattern mode))))

(defun tung/byte-compile-config-on-save ()
  (let ((fname (buffer-file-name)))
    (when (string-match "config/.*\\.el$" fname)
      (byte-compile-file fname))))

(defun tung/filter (condp lst)
  (delq nil
        (mapcar (lambda (x) (and (funcall condp x) x)) lst)))

(defun tung/buffers-of-mode (mode)
  (tung/filter (lambda (buffer)
                 (with-current-buffer buffer
                   (eq mode major-mode)))
               (buffer-list)))

(defmacro icalled (&rest fn)
  `(lambda () (interactive) ,@fn))


;; Advices
(defun tung/make-parent-directories (filename)
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir t)))))

(defadvice find-file
  (before make-directory-maybe (filename &optional wildcards) activate)
  (tung/make-parent-directories filename))

(defadvice save-buffers-kill-emacs
  (around no-query-kill-emacs activate)
  (labels ((process-list ())) ad-do-it))

(defadvice switch-to-buffer
  (before save-buffer-now activate)
  (when buffer-file-name (save-buffer)))

(defadvice other-window (before other-window-now activate)
  (when buffer-file-name (save-buffer)))
