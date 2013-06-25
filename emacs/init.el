
;; init.el --- tungd's Emacs configuration file
(setq default-frame-alist
      '((left-fringe . 24) (right-fringe . 0))
      initial-frame-alist default-frame-alist)

(setq td-screen-layouts
      '((:query (= (x-display-pixel-width) 1366)
                :height 35 :width 140 :top 0 :left 200)
        (:query (and (= (x-display-pixel-width) 1280) (= (x-display-screens) 2))
                :height 48 :width 100 :top 10 :left (+ (x-display-pixel-width) 200))
        (:query (= (x-display-pixel-width) (+ 1366 1280))
                :height 48 :width 100 :top 0 :left (- 1366 750))))

(defun set-frame-size-and-position-according-to-display ()
  (interactive)
  (when (display-graphic-p)
    (mapc (lambda (layout)
            (when (eval (plist-get layout :query))
              (and (plist-get layout :width)
                   (set-frame-width (selected-frame) (eval (plist-get layout :width))))
              (and (plist-get layout :height)
                   (set-frame-height (selected-frame) (eval (plist-get layout :height))))
              (set-frame-position (selected-frame)
                                  (eval (plist-get layout :left))
                                  (eval (plist-get layout :top)))))
          td-screen-layouts)))

(set-frame-size-and-position-according-to-display)

(defalias 'aa #'set-frame-size-and-position-according-to-display
  "Auto Adjust frame size according to current display")

(defun td-custom-frame (&optional frame)
  (interactive)
  (mapc (lambda (mode)
          (when (fboundp mode) (funcall mode -1)))
        '(tool-bar-mode scroll-bar-mode blink-cursor-mode))
  (unless (display-graphic-p) (menu-bar-mode -1)))

(td-custom-frame)
(add-hook 'after-make-frame-functions #'td-custom-frame)

;;;; packages
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
(setq td-packages
      ;; (reverse (mapcar (lambda (info) (car info)) package-alist))
      '(ack-and-a-half alert clojure-mode coffee-mode color-theme-approximate dash diff-hl
        diminish elixir-mode emmet-mode evil expand-region go-mode groovy-mode ibuffer-vc
        ido-ubiquitous js-comint js2-mode magit markdown-mode melpa nrepl org-pomodoro
        php-mode projectile rainbow-delimiters rainbow-mode restclient s scss-mode
        simple-httpd skewer-mode smex soothe-theme surround twilight-anti-bright-theme
        undo-tree web-mode wgrep yaml-mode yasnippet))

;;;; helpers
(setq user-emacs-directory "~/.emacs.d/data/")

(defmacro after (mode &rest body)
  (declare (indent defun))
  ;; (eval `(require ,mode))
  `(eval-after-load ,mode
     `(funcall (function ,(lambda () ,@body)))))

(defmacro td-cmd (&rest body)
  `(lambda () (interactive) ,@body))

(defun td-join (sep parts)
  (mapconcat #'identity parts sep))

(defun td-mode (mode &rest patterns)
  (mapc (lambda (pattern)
          (add-to-list 'auto-mode-alist (cons pattern mode)))
        patterns))

(defun td-repl (mode &rest repls)
  (mapc (lambda (repl)
          (add-to-list 'interpreter-mode-alist (cons repl mode)))
        repls))

(defun td-filter (condp l)
  (delq nil (mapcar (lambda (x) (and (funcall condp x) x)) l)))

(defun td-uniq (l)
  (delq nil (delete-dups l)))

(defun even? (n)
  (eq 0 (mod n 2)))

(defun odd? (n)
  (not (even? n)))

;;;; custom
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

(defvar after-load-theme-functions nil)
(defadvice load-theme (after load-theme-hooks activate)
  (run-hooks 'after-load-theme-functions))

(defun td-custom-faces ()
  (set-face-attribute 'default nil :family "M+ 1m" :height 140)
  (set-face-attribute 'mode-line nil :box nil)
  (set-face-attribute 'mode-line-highlight nil :box '(:line-width 1))
  (set-face-attribute 'highlight nil :foreground nil)
  (set-face-attribute 'font-lock-comment-face nil :background nil))

(add-hook 'after-load-theme-functions #'td-custom-faces)

;;;; paths
(setq td-extra-paths
      '("~/cli/bin"
        "~/local/bin"
        "~/local/share/npm/bin"
        "/usr/local/bin"
        "/Application/Xcode.app/Contents/Developer/usr/bin"))

(setq exec-path
      (append (mapcar #'expand-file-name td-extra-paths) exec-path))
(setenv "PATH" (td-join ":" exec-path))

;;;; platform specific
(when (eq system-type 'darwin)
  (setq delete-by-moving-to-trash t
        mac-command-modifier 'meta
        mac-option-modifier 'super))

(when (eq system-type 'gnu/linux)
  (menu-bar-mode -1))

(after 'browse-url
  (setq browse-url-browser-function
        (cond
         ((eq system-type 'darwin) 'browse-url-default-macosx-browser)
         ((eq system-type 'gnu/linux) "xdg-open"))))

;;;; startup
(defun td-scratch-fortune ()
  (let ((cookie (shell-command-to-string "fortune -a")))
    (concat
     (replace-regexp-in-string
      " *$" ""
      (replace-regexp-in-string "^" ";; " cookie))
     "\n")))

(setq inhibit-startup-message t
      initial-scratch-message (td-scratch-fortune))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Time needed to load: %s seconds." (emacs-uptime "%s")))
          'append)

;;;; server
(require 'server)
(after 'server
  (unless (server-running-p) (server-start nil)))

;;;; aliases
(defalias 'qrr 'query-replace-regexp)
(defalias 'qr 'query-replace)
(defalias 'yes-or-no-p 'y-or-n-p)

;;;; random seed
(random t)

;;;; keys
(defun td-bind (&rest mappings)
  (let ((keymap (if (odd? (length mappings))
                    (pop mappings)
                  (current-global-map))))
    (while mappings
      (let* ((key (pop mappings))
             (cmd (pop mappings)))
        (define-key keymap (kbd key) cmd)))))

(td-bind "M-RET" #'td-fullscreen)
(td-bind "M-m" #'execute-extended-command)

(td-bind "M-z" #'zap-up-to-char)
(td-bind "M-Z" #'zap-to-char)
(td-bind "RET" #'newline-and-indent)

(td-bind "M-=" #'cleanup-buffer)
(td-bind "C-=" #'indent-defun)

(td-bind "M-j" #'other-window)
(td-bind "M-k" (td-cmd (other-window -1)))
(td-bind "M-`" #'other-frame)
(td-bind "C-c q" #'delete-frame)
(td-bind "C-c Q" #'delete-window)
(td-bind "C-c k" #'kill-buffer-and-window)

(td-bind "C-c c" #'server-edit)
(td-bind "C-c o" #'imenu)
(td-bind "C-c b" #'ido-switch-buffer)
(td-bind "C-c f" #'find-file)
(td-bind "C-c t" #'find-tag)
(td-bind "C-c C-b" #'ibuffer)
(td-bind "C-c w" #'whitespace-mode)

(td-bind "C-c C-e" #'eval-and-replace)
(td-bind "C-l" #'toggle-comment-dwim)
(td-bind "M-o" #'open-file-at-cursor)

;;;; general
(setq ring-bell-function 'ignore
      x-select-enable-clipboard nil
      imenu-auto-rescan t
      scroll-margin 3
      frame-title-format '("%b %+%+ %f")
      default-input-method 'vietnamese-telex
      tab-stop-list (number-sequence 2 100 2)
      require-final-newline t)

(setq-default major-mode 'text-mode
              tab-width 2
              indicate-empty-lines nil
              indent-tabs-mode nil
              fill-column 90
              truncate-lines t)

(column-number-mode t)
(visual-line-mode -1)
(global-hl-line-mode t)
(which-function-mode t)
(savehist-mode t)

;;;; encoding
(setq eol-mnemonic-dos " dos "
      eol-mnemonic-mac " mac "
      eol-mnemonic-unix " unix "
      eol-mnemonic-undecided " - ")

(setq-default buffer-file-coding-system 'utf-8-unix)

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;;;; backup
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      backup-directory-alist
      `((".*" . ,(expand-file-name "backups" user-emacs-directory))
        (,tramp-file-name-regexp . nil)))

(global-auto-revert-mode t)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(setq auto-save-default nil
      auto-save-list-file-prefix
      (expand-file-name "auto-saves" user-emacs-directory))

;;;; tramp
(after 'tramp
  (setq password-cache-expiry nil
        tramp-default-method "ftp"))

;;;; file
;; (defadvice ido-find-file
;;   (after find-file-sudo activate)
;;   (when (and buffer-file-name
;;              (not (eq (user-uid)
;;                       (nth 2 (file-attributes buffer-file-name)))))
;;     (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun before-save-make-directories ()
  (let ((dir (file-name-directory buffer-file-name)))
    (when (and buffer-file-name (not (file-exists-p dir)))
      (make-directory dir t))))

(add-hook 'before-save-hook #'before-save-make-directories)
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;;;; uniquify
(require 'uniquify)
(after 'uniquify
  (setq uniquify-buffer-name-style 'post-forward
        uniquify-separator " - "
        uniquify-after-kill-buffer-p t
        uniquify-ignore-buffers-re "^\\*"))

;;;; saveplace
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (expand-file-name "save-places" user-emacs-directory))

;;;; recentf
(recentf-mode t)
(setq recentf-max-saved-items 100)
(add-to-list 'recentf-exclude "ido.last")
(add-hook 'server-visit-hook #'recentf-save-list)

;;;; theme
(color-theme-approximate-on)
(setq custom-theme-directory "~/.emacs.d/themes/")
(load-theme 'subatomic t)

(defadvice load-theme (before theme-dont-propagate activate)
  (mapcar #'disable-theme custom-enabled-themes))

;; show-paren-mode
(after 'paren
  (setq show-paren-delay 0))
(show-paren-mode t)

;;;; diminish
(after 'diminish-autoloads
  (defun td-compact-mode-line (file mode &optional lighter)
    (eval-after-load file
      `(diminish ,mode ,(when lighter (concat " " lighter)))))

  (mapc (lambda (args)
          (apply #'td-compact-mode-line args))
        '(("yasnippet" 'yas-minor-mode "Y")
          ("eldoc" 'eldoc-mode "Doc")
          ("flycheck" 'flycheck-mode "Chk")
          ("projectile" 'projectile-mode "Proj")
          ("hideshow" 'hs-minor-mode)
          ("undo-tree" 'undo-tree-mode)
          ("rainbow-mode" 'rainbow-mode)
          ("isearch-mode" 'isearch-mode)
          ("abbrev" 'abbrev-mode)
          ("sackspace" 'sackspace-mode))))

;;;; ibuffer
(after 'ibuffer
  (define-ibuffer-column size-readable
    (:name "Size" :inline t)
    (cond
     ((> (buffer-size) 1000) (format "%7.1fk" (/ (buffer-size) 1000.0)))
     ((> (buffer-size) 1000000) (format "%7.1fM" (/ (buffer-size) 1000000.0)))
     (t (format "%8d" (buffer-size)))))

  (setq ibuffer-expert t
        ibuffer-show-empty-filter-groups nil
        ibuffer-saved-filter-groups
        '(("Default"
           ("Docs" (or
                    (filename . "inbox.org")
                    (filename . "~/Dropbox/Notes")
                    (mode . text-mode)
                    (mode . markdown-mode)
                    (mode . org-mode)))
           ("Dired" (mode . dired-mode))
           ("Shells" (or
                      (mode . eshell-mode)
                      (mode . shell-mode)))
           ("Misc" (or
                    (name . "\*magit.+\*")
                    (name . "\*Help\*")
                    (name . "\*Apropos\*")
                    (name . "\*info\*")
                    (name . "\*Completions\*")
                    (name . "\*Backtrace\*")))))
        ibuffer-formats
        '((mark modified read-only vc-status-mini " "
                (name 18 18 :left :elide) " "
                (size-readable 9 -1 :right) " "
                (mode 16 16 :left :elide) " "
                (vc-status 16 16 :left) " "
                filename-and-process)))

  (defun ibuffer-vc-add-filter-groups ()
    (interactive)
    (mapc (lambda (g)
            (add-to-list 'ibuffer-filter-groups g))
          (ibuffer-vc-generate-filter-groups-by-vc-root)))

  (defun td-ibuffer-hook ()
    (ibuffer-auto-mode 1)
    (ibuffer-switch-to-saved-filter-groups "Default")
    (ibuffer-vc-add-filter-groups)
    (ibuffer-do-sort-by-alphabetic))

  (add-hook 'ibuffer-mode-hook #'td-ibuffer-hook))

;;;; hippie-expand
(require 'hippie-exp)

(after 'hippie-exp
  (setq hippie-expand-verbose t
        hippie-expand-try-functions-list
        '(try-expand-all-abbrevs
          try-expand-dabbrev-visible
          try-expand-dabbrev
          try-expand-dabbrev-same-mode-buffers))

  (define-prefix-command 'td-completion-map)
  (td-bind "C-;" 'td-completion-map)
  (td-bind td-completion-map
           "f" (make-hippie-expand-function
                '(try-complete-file-name-partially try-complete-file-name) t)
           "l" (make-hippie-expand-function
                '(try-expand-line) t))

  (defun try-expand-dabbrev-same-mode-buffers (prefix)
    (cl-flet ((buffer-list () (same-mode-buffers)))
      (try-expand-dabbrev-all-buffers prefix)))

  (setq td-mode-completers
        '((emacs-lisp-mode . (try-complete-lisp-symbol-partially
                              try-complete-lisp-symbol))
          (js2-mode . ())
          (markdown-mode . (try-ispell-expand))
          (org-mode . (try-ispell-expand))))

  (defun td-he-set-sources ()
    (set (make-local-variable 'hippie-expand-try-functions-list)
         (td-uniq
          (append hippie-expand-try-functions-list
                  (cdr (assoc major-mode td-mode-completers))))))

  (add-hook 'emacs-lisp-mode-hook #'td-he-set-sources))

(defun smart-he-tab (prefix)
  (interactive "*P")
  (if (looking-at "\\_>")
      (hippie-expand prefix)
    (indent-for-tab-command)))

;;;; ido
(ido-mode t)

(after 'ido
  (setq ido-enable-prefix nil
        ido-enable-flex-matching t
        ido-enable-dot-prefix t
        ido-use-virtual-buffers t
        ido-auto-merge-delay-time 15
        ido-create-new-buffer 'always
        ido-use-url-at-point nil
        ido-use-filename-at-point nil
        ido-ignore-extensions t
        ido-save-directory-list-file (expand-file-name "ido.last" user-emacs-directory)
        ido-everywhere t
        ido-ignore-buffers '("\\` ")
        ido-ignore-files '("ido.last" ".*-autoloads.el"))

  (setq ido-decorations
        '("\n>> " "" "\n   " "\n   ..." "[" "]"
          " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]"
          "\n>> " ""))

  (defun td-minibuffer-home ()
    (interactive)
    (if (looking-back "/")
        (insert "~/")
      (call-interactively 'self-insert-command)))

  (defun td-minibuffer-insert-word-at-point ()
    (interactive)
    (let (word beg)
      (with-current-buffer (window-buffer (minibuffer-selected-window))
        (setq word (thing-at-point 'word)))
      (insert word)))

  (defun td-ido-hook ()
    (td-bind ido-completion-map
             "C-h" #'delete-backward-char
             "ESC" #'ido-exit-minibuffer
             "C-w" #'ido-delete-backward-updir
             "C-n" #'ido-next-match
             "C-p" #'ido-prev-match
             "TAB" #'ido-complete
             "C-l" #'td-minibuffer-insert-word-at-point
             "~" #'td-minibuffer-home))

  (add-hook 'ido-setup-hook #'td-ido-hook))

(after 'ido-ubiquitous-autoloads
  (ido-ubiquitous-mode t))

;;;; smex
(after 'smex-autoloads
  (smex-initialize)
  (td-bind "M-m" #'smex
           "M-M" #'smex-major-mode-commands))

;;;; projectile
(after 'projectile-autoloads
  (projectile-global-mode)
  (td-bind "M-p" #'projectile-find-file
           "C-c a" #'projectile-ack))

(after 'projectile
  (setq projectile-tags-command "~/local/bin/ctags -Re %s %s")
  (push "build.gradle" projectile-project-root-files))

;;;; ispell
(defun ispell-suggest-word (word)
  (let* ((cmd (format "echo '%s' | aspell -a --sug-mode=ultra --suggest | sed -n '1!p'" word))
         (raw (shell-command-to-string cmd)))
    (when (string-match ":\s+\\(.*\\)" raw)
      (split-string (match-string 1 raw) ", "))))

(defun ido-ispell-word-at-point ()
  (interactive)
  (let* ((word (current-word))
         (prompt (format "Suggestions [%s]: " word))
         (sugs (ispell-suggest-word word))
         (select (and sugs (ido-completing-read prompt sugs))))
    (when select
      (save-excursion
        (beginning-of-thing 'word)
        (kill-word 1)
        (insert select)))))

(td-bind "C-c i" #'ido-ispell-word-at-point)

(defun try-ispell-expand (old)
  (unless old
    (he-init-string (he-dabbrev-beg) (point))
    (setq he-expand-list (ispell-suggest-word he-search-string)))
  (while (and he-expand-list
              (he-string-member (car he-expand-list) he-tried-table))
    (setq he-expand-list (cdr he-expand-list)))
  (if (null he-expand-list)
      (progn (he-reset-string) nil)
    (he-substitute-string (car he-expand-list))
    (setq he-tried-table (cons (car he-expand-list) (cdr he-tried-table)))
    (setq he-expand-list (cdr he-expand-list))
    t))

;;;; yasnippets
(after 'yasnippet-autoloads
  (setq yas-snippet-dirs '("~/.emacs.d/snippets")
        yas-prompt-functions '(yas-ido-prompt yas-completing-prompt yas-no-prompt))
  (yas-global-mode t)
  (push #'yas-hippie-try-expand hippie-expand-try-functions-list))

;;;; rainbow-mode
(after 'rainbow-mode-autoloads
  (add-hook 'css-mode-hook #'rainbow-mode))

;;;; expand-region
(td-bind "M--" #'er/expand-region)

;;;; org
(after 'org
  (defun td-custom-org-faces ()
    (set-face-attribute 'org-level-1 nil :height 1.3)
    (set-face-attribute 'org-level-2 nil :height 1.2)
    (set-face-attribute 'org-level-3 nil :height 1.1))
  (td-custom-org-faces)
  (add-hook 'after-load-theme-functions #'td-custom-org-faces))

;;;; rainbow-delimiters
(after 'rainbow-delimiters-autoloads
  (defun td-custom-rainbow-delimiter-faces ()
    (set-face-attribute 'rainbow-delimiters-depth-1-face nil :foreground "#d97a35")
    (set-face-attribute 'rainbow-delimiters-depth-2-face nil :foreground "#deae3e")
    (set-face-attribute 'rainbow-delimiters-depth-3-face nil :foreground "#81af34")
    (set-face-attribute 'rainbow-delimiters-depth-4-face nil :foreground "#4e9f75")
    (set-face-attribute 'rainbow-delimiters-depth-5-face nil :foreground "#11535F")
    (set-face-attribute 'rainbow-delimiters-depth-6-face nil :foreground "#00959e")
    (set-face-attribute 'rainbow-delimiters-depth-7-face nil :foreground "#8700ff")
    (set-face-attribute 'rainbow-delimiters-unmatched-face nil :background "#d13120"))
  (td-custom-rainbow-delimiter-faces)
  (add-hook 'after-load-theme-functions #'td-custom-rainbow-delimiter-faces)

  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode-enable)
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode-enable)
  (add-hook 'nrepl-mode-hook #'rainbow-delimiters-mode-enable))


;;;; diff-hl
(after 'diff-hl-autoloads
  (global-diff-hl-mode))

(after 'diff-hl
  (defun diff-hl-overlay-modified (ov after-p beg end &optional len)
    "Markers disappear and reapear is kind of annoying to me.")

  (setq diff-hl-draw-borders nil)

  (define-fringe-bitmap 'diff-hl-bmp-insert
    [0 24 24 126 126 24 24 0])
  (define-fringe-bitmap 'diff-hl-bmp-delete
    [0 0 0 126 126 0 0 0])
  (define-fringe-bitmap 'diff-hl-bmp-change
    [0 60 126 126 126 126 60 0])

  (defadvice magit-quit-session
    (after update-diff-hl activate)
    (mapc (lambda (buffer)
            (with-current-buffer buffer (diff-hl-update)))
          (buffer-list)))

  (defun diff-hl-fringe-spec (type pos)
    (let* ((key (cons type pos))
           (val (gethash key diff-hl-spec-cache)))
      (unless val
        (let* ((face-sym (intern (concat "diff-hl-" (symbol-name type))))
               (bmp-sym (intern (concat "diff-hl-bmp-" (symbol-name type)))))
          (setq val (propertize " " 'display `((left-fringe ,bmp-sym ,face-sym))))
          (puthash key val diff-hl-spec-cache)))
      val))

  (defun td-custom-diff-hl-faces ()
    (set-face-attribute 'diff-hl-insert nil :inherit nil :foreground "#81af34")
    (set-face-attribute 'diff-hl-delete nil :inherit nil :foreground "#ff0000")
    (set-face-attribute 'diff-hl-change nil :background nil :foreground "#deae3e"))
  (td-custom-diff-hl-faces)
  (add-hook 'after-load-theme-functions #'td-custom-diff-hl-faces))

;;;; undo-tree
(after 'undo-tree-autoloads
  (global-undo-tree-mode t)
  (setq undo-limit (* 32 1024 1024 1024)
        undo-strong-limit (* 64 1024 1024 1024)
        undo-tree-auto-save-history t
        undo-tree-visualizer-relative-timestamps t
        undo-tree-visualizer-timestamps t
        undo-tree-history-directory-alist
        `(("." . ,(expand-file-name "undos" user-emacs-directory)))))

;;;; evil
(after 'evil-autoloads
  (evil-mode t)
  (setq-default mode-line-format
                (cons '(evil-mode ("" evil-mode-line-tag)) mode-line-format)))

(after 'evil
  (when (boundp 'global-surround-mode)
    (global-surround-mode))
  (evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)
  (mapc (lambda (mode) (evil-set-initial-state mode 'emacs))
        '(nrepl-mode
          nrepl-popup-buffer-mode
          ack-mode
          magin-log-edit-mode
          undo-tree-visualizer-mode))
  (setq evil-move-cursor-back nil
        evil-mode-line-format nil
        evil-cross-lines t
        evil-emacs-state-cursor '("orange"))
  (td-bind evil-normal-state-map
           "C-j" "10gj"
           "C-k" "10gk"
           "j" #'evil-next-visual-line
           "k" #'evil-previous-visual-line
           "TAB" #'evil-jump-item
           "gp" #'clipboard-yank
           "C-:" #'eval-expression
           "C-e" #'end-of-line
           "SPC" #'evil-toggle-fold
           "RET" #'evil-ex-nohighlight
           "gi" #'inline-variable
           ",," #'evil-buffer
           ",w" #'evil-write-all
           ",e" #'ido-find-file)
  (td-bind evil-insert-state-map
           "TAB" #'smart-he-tab
           "<backtab>" (td-cmd (he-reset-string))
           "C-a" #'back-to-indentation
           "C-e" #'end-of-line
           "C-d" #'delete-char
           "M-h" " => "
           "M-a" "@")
  (td-bind evil-visual-state-map
           "Y" #'clipboard-kill-ring-save
           "C-a" #'align=
           "ge" #'extract-variable
           "*" #'evil-visual-search)
  (td-bind evil-motion-state-map
           "<tab>" #'evil-jump-item)
  (defadvice evil-ex-pattern-whole-line
    (after evil-global-defaults activate)
    (setq ad-return-value "g"))
  (defun evil-visual-search (beg end)
    (interactive "r")
    (when (evil-visual-state-p)
      (evil-exit-visual-state)
      (setq isearch-forward t)
      (evil-search
       (regexp-quote (buffer-substring-no-properties beg end)) t t))))

;;;; magit
(after 'magit-autoloads
  (td-bind "C-c g" #'magit-status))

(after 'magit
  (defadvice magit-status (around magit-fullscreen activate)
    (window-configuration-to-register :magit-fullscreen)
    ad-do-it
    (delete-other-windows))
  (defun magit-quit-session ()
    "Restores previous window configuration"
    (interactive)
    (kill-buffer)
    (jump-to-register :magit-fullscreen))
  (td-bind magit-status-mode-map "q" #'magit-quit-session))

;;;; electric
(electric-pair-mode t)
(after 'electric
  (defun td-electric-brace ()
    (when (and (eq last-command-event ?\n)
               (looking-at "}"))
      (indent-according-to-mode)
      (forward-line -1)
      (end-of-line)
      (newline-and-indent)))
  (add-hook 'post-self-insert-hook #'td-electric-brace t)
  (defun td-electric-parenthesis ()
    (when (and (eq last-command-event ?\s)
               (or (and (looking-back "( " (- (point) 2))
                        (looking-at ")"))
                   (and (looking-back "{ " (- (point) 2))
                        (looking-at "}"))
                   (and (looking-back "\\[ " (- (point) 2))
                        (looking-at "\\]"))))
      (insert " ")
      (backward-char 1)))
  (add-hook 'post-self-insert-hook #'td-electric-parenthesis t))

;;;; hideshow

;;;; figlet
(defun figlet-region (beg end)
  (interactive "r")
  (let ((message (buffer-substring-no-properties beg end)))
    (kill-region beg end)
    (insert (shell-command-to-string
             (format "figlet -f%s \"%s\"" "chunky" message)))))

(td-bind "C-c C-f" #'figlet-region)

;;;; whitespace
(after 'whitespace
  (add-to-list 'whitespace-display-mappings
               '(newline-mark ?\n [?\u00AC ?\n] [?$ ?\n]) t)
  (setq whitespace-style
        '(face
          tabs tab-mark
          spaces space-mark
          newline newline-mark
          trailing lines-tail
          space-before-tab space-after-tab))
  (setq whitespace-line-column fill-column)

  (defun td-custom-whitespace-faces ()
    (set-face-attribute 'whitespace-space nil :background nil)
    (set-face-attribute 'whitespace-tab nil :background nil))
  (td-custom-whitespace-faces)
  (add-hook 'after-load-theme-functions #'td-custom-whitespace-faces))

;; prog
;;;; web
(after 'web-mode-autoloads
  (td-mode 'web-mode
           "\\.html$" "\\.erb" "\\.rhtml$" "\\.ejs$" "*twig*" "*tmpl*" "\\.hbs$"
           "\\.ctp$" "\\.tpl$" "/\\(views\\|html\\|templates\\)/.*\\.php\\'")
  ;; electric pair mode is not flexible enough
  (defadvice electric-pair-post-self-insert-function
    (around disable-electric-pair activate)
    (unless (eq major-mode 'web-mode) ad-do-it))

  (add-hook 'web-mode-hook #'emmet-mode))

(after 'emmet-mode
  (setq emmet-indentation 2
        emmet-preview-default nil)

  (defadvice emmet-preview
    (after emmet-preview-hide-tooltip activate)
    (overlay-put emmet-preview-output 'before-string nil))

  (defun td-custom-emmet-faces ()
    (set-face-attribute 'emmet-preview-input nil :box nil))
  (td-custom-emmet-faces)
  (add-hook 'after-load-theme-functions #'td-custom-emmet-faces))

;; (after 'skewer-mode-autoloads
;;   (setq httpd-port 6000)
;;   (add-hook 'js2-mode-hook #'skewer-mode)
;;   (add-hook 'css-mode-hook #'skewer-mode)
;;   (add-hook 'web-mode-hook #'skewer-mode))

;;;; js2
(after 'js2-mode-autoloads
  (td-mode 'js2-mode "\\.js$")
  (td-repl 'js2-mode "node")
  (setq js2-basic-offset 2
        js2-bounce-indent-p t
        js2-language-version 180
        js2-strict-missing-semi-warning nil
        js2-global-externs '($ jQuery Ember require define)
        js2-include-node-externs t))

(after 'js2-mode
  (td-bind js2-mode-map "M-j" nil))

;;;; coffee
(after 'coffee-mode-autoloads
  (td-mode 'coffee-mode "\\.coffee$" "Cakefile"))

;;;; css
(defun td-css-imenu-expressions ()
  (add-to-list
   'imenu-generic-expression
   `((nil
      ,(concat "^\\([ \t]*[^@:{}\n][^:{}]+\\(?::"
               (regexp-opt css-pseudo-ids t)
               "\\(?:([^)]+)\\)?[^:{\n]*\\)*\\)\\(?:\n[ \t]*\\)*{")
      1)) t))

(add-hook 'css-mode-hook #'td-css-imenu-expressions)

(after 'css-mode
  (setq css-indent-offset 2))

;;;; scss
(after 'scss-mode
  (setq scss-compile-at-save nil))

;;;; emacs lisp
(defun td-elisp-imenu-expressions ()
  (setq imenu-prev-index-position-function nil)
  (add-to-list 'imenu-generic-expression '("Section" "^;;;; \\(.+\\)$" 1) t))

(add-hook 'emacs-lisp-mode-hook #'td-elisp-imenu-expressions)

;;;; php
(after 'php-mode
  (setq php-template-compatibility nil)
  (add-hook 'php-mode-hook #'php-enable-drupal-coding-style))

;;;; ruby
(td-mode 'ruby-mode "Rakefile" "Guardfile" "Gemfile" "Vagrantfile" "\\.ru$" "\\.rake$")

(after 'ruby-mode
  (setq ruby-deep-arglist nil
        ruby-deep-indent-paren nil)
  (add-to-list 'hs-special-modes-alist
               '(ruby-mode
                 "\\(def\\|do\\|{\\)" "\\(end\\|end\\|}\\)" "#"
                 (lambda (arg) (ruby-end-of-block)) nil)))

;;;; python
(after 'python
  (defun setup-python-mode ()
    (setq tab-width 4
          python-indent 4))
  (add-hook 'python-mode-hook #'setup-python-mode))

;;;; c

;;;; java

;;;; clojure
(after 'clojure-mode
  (define-clojure-indent
    (defroutes 'defun) (context 2)
    (GET 2) (POST 2) (PUT 2) (DELETE 2) (HEAD 2) (ANY 2)))

(after 'nrepl
  (setq nrepl-hide-special-buffers t
        nrepl-popup-stacktraces nil)
  (defun td-setup-nrepl ()
    (nrepl-eval "(set! *print-length* 30)")
    (nrepl-eval "(set! *print-level* 5)"))
  (add-hook 'nrepl-interaction-mode-hook #'td-setup-nrepl)
  (add-hook 'nrepl-interaction-mode-hook #'nrepl-turn-on-eldoc-mode))

;;;; markdown
(after 'markdown-mode-autoloads
  (td-mode 'markdown-mode "\\.md$" "\\.mkd$" "\\.markdown$")
  (setq markdown-command "pandoc -s"
        markdown-enable-math t
        markdown-header-face '(:inherit font-lock-function-name-face :weight bold)
        markdown-header-face-1 '(:inherit markdown-header-face :height 2.0)
        markdown-header-face-2 '(:inherit markdown-header-face :height 1.6)
        markdown-header-face-3 '(:inherit markdown-header-face :height 1.4)
        markdown-header-face-4 '(:inherit markdown-header-face :height 1.2))
  (defun markdown-export-docx ()
    (interactive)
    (let* ((parts (list markdown-command))
           (format "docx")
           (buf (buffer-name))
           (output-file (replace-regexp-in-string
                         (regexp-opt '("\.markdown" "\.md")) (concat "." format) buf)))
      (push (concat "--data-dir=~/Dropbox/templates") parts)
      (push (concat "-t " format) parts)
      (push (concat "-o ~/Desktop/" output-file) parts)
      (push (buffer-file-name) parts)
      (when (= 0 (shell-command (mapconcat 'identity (nreverse parts) " ")))
        (message (concat "Wrote " output-file))))))

(after 'markdown-mode
  (td-bind markdown-mode-map "M-p" nil)
  (td-bind markdown-mode-map "C-c C-b" nil))

;;;; commands
(defun open-file-at-cursor ()
  (interactive)
  (let ((path (if (region-active-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (thing-at-point 'filename))))
    (if (string-match-p "\\`https*://" path)
        (browse-url path)
      (progn
        (if (file-exists-p path)
            (find-file path)
          (if (file-exists-p (concat path ".el"))
              (find-file (concat path ".el"))
            (when (y-or-n-p (format "Creat %s?" path))
              (find-file path))))))))

(defun finder ()
  "Open the current working directory in finder."
  (interactive)
  (shell-command (concat "open " (shell-quote-argument default-directory))))

(defun toggle-comment-dwim (&optional args)
  (interactive "*P")
  (comment-normalize-vars)
  (if (not (region-active-p))
      (comment-or-uncomment-region
       (line-beginning-position) (line-end-position))
    (comment-dwim args)))

(defun byte-recompile-config-dir ()
  (interactive)
  (mapc (lambda (dir)
          (byte-recompile-directory dir 0))
        '("~/.emacs.d")))

(defun byte-recompile-config ()
  (interactive)
  (when (string-match "init.el" buffer-file-name)
    (let ((byte-compile-verbose nil))
      (byte-compile-file buffer-file-name))))

;; (add-hook 'after-save-hook #'byte-recompile-config)

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

(defun eval-and-replace ()
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(defun increment-number-at-point ()
  (interactive)
  (skip-chars-backward "0123456789")
  (when (looking-at "[0123456789]+" )
    (replace-match
     (number-to-string (1+ (string-to-number (match-string 0)))))))

(defun decrement-number-at-point ()
  (interactive)
  (skip-chars-backward "0123456789")
  (when (looking-at "[0123456789]+" )
    (replace-match
     (number-to-string (1- (string-to-number (match-string 0)))))))

(defun delete-current-buffer-file ()
  (interactive)
  (let ((filename (buffer-file-name)))
    (when (and filename (file-exists-p filename))
      (delete-file filename)
      (kill-this-buffer))))

(defun rename-current-buffer-file (new-name)
  (interactive
   (list (read-string "New name: " (buffer-name))))
  (let ((filename (buffer-file-name)))
    (when (and filename (file-exists-p filename))
      (if (get-buffer new-name)
          (error "Buffer named '%s' already exists!" new-name)
        (progn
          (rename-file filename new-name t)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

(defun make-executable ()
  (interactive)
  (when (buffer-file-name)
    (start-file-process
     "Make Executable" nil "/bin/bash"
     (format "-c chmod u+x %s" (file-name-nondirectory buffer-file-name)))))

(defun align= (beg end)
  "Align region to equal signs"
  (interactive "r")
  (align-regexp beg end "\\(\\s-*\\)[=|:]" 1 1))

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

(defun cleanup-buffer ()
  (interactive)
  (indent-region (point-min) (point-max))
  (untabify (point-min) (point-max))
  (whitespace-cleanup))

(defun buffers-of-mode (mode)
  (td-filter (lambda (b)
               (with-current-buffer b
                 (eq mode major-mode)))
             (buffer-list)))

(defun current-buffer? (b)
  (eql b (current-buffer)))

(defun same-mode-buffers ()
  (buffers-of-mode major-mode))

(defun other-buffers ()
  (td-filter #'current-buffer? (buffer-list)))

(defun other-buffer-files ()
  (td-filter (lambda (b) (not (current-buffer? b)))
             (td-filter #'buffer-file-name (buffer-list))))

(defun kill-other-buffers ()
  (interactive)
  (mapc #'kill-buffer (other-buffer-files)))

(defun td-fullscreen ()
  "ns-toggle-fullscreen is not cool for me"
  (interactive)
  (set-frame-position (selected-frame) 0 0)
  (set-frame-width (selected-frame) 190)
  (set-frame-height (selected-frame) 34))

;;;; advices
(defadvice save-buffers-kill-emacs
  (around no-query-kill-emacs activate)
  (labels ((process-list ())) ad-do-it))

(defadvice switch-to-buffer
  (before save-buffer-now activate)
  (when buffer-file-name (save-buffer)))

(defadvice other-window
  (before save-buffer-now activate)
  (when buffer-file-name (save-buffer)))

;;;; inbox
(find-file "~/Dropbox/inbox.org")
(td-bind "C-c j" (td-cmd (find-file "~/Dropbox/inbox.org")))
(switch-to-buffer "*scratch*")
