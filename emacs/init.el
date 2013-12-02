
;; init.el --- tungd's Emacs configuration file
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)

(fringe-mode '(16 . 0))

;;;; packages
(require 'cask "~/.cask/cask.el")
(cask-initialize)

;;;; vendors
(add-to-list 'load-path (expand-file-name "vendor" user-emacs-directory))

;;;; autoloads
(autoload '-filter "dash")
(autoload '-uniq "dash")
(autoload '-remove "dash")
(autoload '-elem-index "dash")
(autoload 's-trim-left "s")

;;;; platform specific
(when (eq system-type 'darwin)
  (exec-path-from-shell-initialize)
  (setq mac-command-modifier 'meta
        mac-option-modifier 'super)
  (when (display-graphic-p)
    (set-face-attribute 'default nil :family "Meslo LG M" :height 140)
    (set-frame-size (selected-frame) 120 35)
    (set-frame-position (selected-frame) 500 22)))

(when (eq system-type 'gnu/linux)
  (menu-bar-mode -1)
  (set-face-attribute 'default nil :family "Meslo LG L" :height 110 :bold t))

;;;; helpers
(setq user-emacs-directory "~/.emacs.d/data/")

(defmacro td-after (file &rest body)
  (declare (indent 1) (debug t))
  `(progn
     (eval-when-compile
       (require ,file nil :no-error))
     (eval-after-load ,file
       `(funcall (function ,(lambda () ,@body))))))

(defmacro td-cmd (&rest body)
  `(lambda () (interactive) ,@body))

(defmacro td-on (hook &rest body)
  (declare (indent 1))
  `(add-hook ,hook (function (lambda () ,@body))))

(defun td-mode (mode &rest patterns)
  (mapc (lambda (pattern)
          (add-to-list 'auto-mode-alist (cons pattern mode)))
        patterns))

(defun td-bind (&rest mappings)
  (let ((keymap (if (eq 1 (mod (length mappings) 2))
                    (pop mappings)
                  (current-global-map))))
    (while mappings
      (let* ((key (pop mappings))
             (cmd (pop mappings)))
        (define-key keymap (kbd key) cmd)))))

(defun td-data-file (f)
  (expand-file-name f user-emacs-directory))

(defun td-set-local (&rest args)
  (while args
    (let* ((name (pop args))
           (value (pop args)))
      (set (make-local-variable name) value))))

;;;; custom
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file :no-error :no-message)

;;;; startup
(defun td-scratch-fortune ()
  (shell-command-to-string "fortune -a | sed -e 's/^/;; /'"))

(setq inhibit-startup-message t
      initial-scratch-message (td-scratch-fortune))

(td-on 'emacs-startup-hook
  (message "Time needed to load: %s seconds." (emacs-uptime "%s")))

;;;; random seed
(random t)

;;;; server
(require 'server)
(td-after 'server
  (unless (server-running-p) (server-start nil)))

;;;; aliases
(defalias 'qrr 'query-replace-regexp)
(defalias 'qr 'query-replace)
(defalias 'yes-or-no-p 'y-or-n-p)

;;;; keys
(td-bind "C-M-f" #'td-toggle-fullscreen)
(td-bind "M-m" #'execute-extended-command)

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
(td-bind "C-c o" #'imenu-flat)
(td-bind "C-c i" #'imenu)
(td-bind "C-c b" #'ido-switch-buffer)
(td-bind "C-c f" #'find-file)
(td-bind "C-c u" #'recentf-ido-find-file)
(td-bind "C-c l" #'ido-goto-line)
(td-bind "C-c t" #'find-tag)
(td-bind "C-c C-b" #'ibuffer)
(td-bind "C-c w" #'whitespace-mode)
(td-bind "C-c m" #'recompile)

(td-bind "C-c C-e" #'eval-and-replace)
(td-bind "C-l" #'comment-or-uncomment-region-dwim)
(td-bind "M-o" #'open-file-at-point)

;;;; inbox
(td-bind "C-c j" (td-cmd (find-file "~/Dropbox/inbox.org")))

;;;; general
(setq delete-by-moving-to-trash t
      ring-bell-function 'ignore
      x-select-enable-clipboard nil
      frame-title-format '("%b %+%+ %f")
      default-input-method 'vietnamese-telex
      tab-stop-list (number-sequence 2 128 2)
      history-length 256
      confirm-nonexistent-file-or-buffer nil
      comment-style 'multi-line
      require-final-newline t)

(setq-default major-mode 'text-mode
              tab-width 2
              indicate-empty-lines nil
              indent-tabs-mode nil
              fill-column 80
              truncate-lines nil)

(td-after 'imenu
  (setq imenu-auto-rescan t))

(visual-line-mode -1)
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
(prefer-coding-system 'utf-8-unix)


(when (display-graphic-p)
  ;; Fallback font for Latin Extended Aditional (support Vietnamese text)
  (set-fontset-font nil '(#x1e00 . #x1eff) (font-spec :family "DejaVu Sans Mono")))

;;;; backup
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      backup-directory-alist
      (list (cons "." (td-data-file "backups"))))

(setq auto-save-default nil
      auto-save-list-file-prefix
      (td-data-file "auto-saves"))

;;;; tramp
(td-after 'tramp
  (setq password-cache-expiry nil
        tramp-default-method "ftp"))

;;;; file
;; (defadvice ido-find-file
;;   (td-after find-file-sudo activate)
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
(td-after 'uniquify
  (setq uniquify-buffer-name-style 'post-forward
        uniquify-separator " - "
        uniquify-after-kill-buffer-p t
        uniquify-ignore-buffers-re "^\\*"))

;;;; saveplace
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (td-data-file "save-places"))

;;;; recentf
(td-after 'recentf
  (add-to-list 'recentf-exclude "*ido*")
  (add-to-list 'recentf-exclude "*elpa*")
  (add-to-list 'recentf-exclude "*cache*")
  (add-hook 'server-visit-hook #'recentf-save-list))

(setq recentf-max-saved-items 256
      recentf-save-file (td-data-file "recentf"))

(recentf-mode t)

;;;; display
(setcdr
 (assoc 'truncation fringe-indicator-alist) nil)

(let ((display-table
       (or standard-display-table
           (setq standard-display-table (make-display-table)))))
  (set-display-table-slot display-table 'truncation ?¬)
  (set-window-display-table (selected-window) display-table))

;; (color-theme-approximate-on)
(setq custom-theme-directory "~/.emacs.d/themes/")

(defun td-clear-themes ()
  (interactive)
  "One time I decided that I don't want theme properties propagate, however I
changed my mind and use one theme with my own custom theme now"
  (mapc #'disable-theme custom-enabled-themes))

(load-theme 'solarized-dark t)
(load-theme 'td-custom t)

;;;; linum
(column-number-mode t)

(td-after 'linum
  (setq linum-format " %4d "))

;;;; hl-line
(global-hl-line-mode t)

;;;; show-paren-mode
(td-after 'paren
  (setq show-paren-delay 0))

(show-paren-mode t)

;;;; diminish
(td-after 'diminish-autoloads
  (defun td-compact-mode-line (file mode &optional lighter)
    (eval-after-load file
      `(diminish ,mode ,(when lighter (concat " " lighter)))))

  (mapc (lambda (args)
          (apply #'td-compact-mode-line args))
        '(("yasnippet" 'yas-minor-mode "Y")
          ("eldoc" 'eldoc-mode "Doc")
          ("flycheck" 'flycheck-mode "Chk")
          ("projectile" 'projectile-mode "Proj")
          ("flyspell" 'flyspell-mode "Spell")
          ("emmet-mode" 'emmet-mode "Em")
          ("hideshow" 'hs-minor-mode)
          ("undo-tree" 'undo-tree-mode)
          ("rainbow-mode" 'rainbow-mode)
          ("isearch-mode" 'isearch-mode)
          ("abbrev" 'abbrev-mode)
          ("sackspace" 'sackspace-mode))))

;;;; ibuffer
(td-after 'ibuffer
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

;;;; completion
(define-prefix-command 'td-completion-map)
(td-bind "C-;" 'td-completion-map
         "C-c ;" 'td-completion-map)

(td-bind td-completion-map
         ";" #'end-with-semicolon
         "C-;" #'end-with-semicolon)

;;;; auto-complete
(td-after 'auto-complete
  (setq ac-auto-start nil
        ac-disable-inline t
        ac-expand-on-auto-complete nil
        ac-ignore-case nil
        ac-use-menu-map t)

  (ac-set-trigger-key "TAB")

  (ac-linum-workaround)
  (ac-flyspell-workaround)

  (add-to-list 'ac-modes 'scss-mode)
  (add-to-list 'ac-modes 'html-mode)
  (add-to-list 'ac-modes 'coffee-mode)
  (add-to-list 'ac-modes 'typescript-mode)
  (add-to-list 'ac-modes 'cider-mode)
  (add-to-list 'ac-modes 'nodejs-repl-mode)

  (defun current-buffer-line-candidates ()
    (-uniq (mapcar #'s-trim-left (current-buffer-lines))))

  (ac-define-source buffer-lines
    '((prefix . "^\s*\\(.+\\)")
      (candidates . current-buffer-line-candidates)))

  (td-bind td-completion-map
           "s" #'ac-complete-yasnippet
           "f" #'ac-complete-filename
           "l" #'ac-complete-buffer-lines
           "h" #'ac-quick-help
           "t" #'ac-complete-tern-completion)

  (td-bind ac-menu-map
           "C-n" #'ac-next
           "C-p" #'ac-previous
           "C-l" #'ac-expand-common))

(td-after 'auto-complete-config
  ;; (ac-config-default)
  (setq-default ac-sources '(ac-source-yasnippet
                             ac-source-imenu
                             ac-source-words-in-same-mode-buffers
                             ac-source-dictionary))

  (require 'ac-c-headers)

  (defvar td-local-ac-sources
    '((emacs-lisp-mode . (ac-source-symbols
                          ac-source-functions
                          ac-source-variables
                          ac-source-features))
      (css-mode . (ac-source-css-property))
      (scss-mode . (ac-source-css-property))
      (js-mode . (ac-source-tern-completion))
      (c-mode . (ac-source-c-headers
                 ac-source-c-header-symbols))))

  (defun td-set-local-ac-sources ()
    (let* ((sources (cdr (assoc major-mode td-local-ac-sources)))
           (prefixes '(ac-source-yasnippet
                       ac-source-imenu
                       ac-source-words-in-same-mode-buffers))
           (suffixes '(ac-source-dictionary))
           (local-sources (append prefixes sources suffixes)))
      (when sources
        (td-set-local 'ac-sources local-sources))))

  (add-hook 'after-change-major-mode-hook #'td-set-local-ac-sources))

(td-after 'auto-complete-autoloads
  (require 'auto-complete-config)
  (global-auto-complete-mode))

;;;; ido
(td-after 'smex-autoloads
  (setq smex-save-file (td-data-file "smex"))
  (smex-initialize)
  (td-bind "M-m" #'smex))

(ido-mode t)

(td-after 'ido
  (setq ido-enable-prefix nil
        ido-enable-dot-prefix t
        ido-use-virtual-buffers nil
        ido-auto-merge-work-directories-length -1
        ido-create-new-buffer 'always
        ido-use-url-at-point nil
        ido-use-filename-at-point nil
        ido-ignore-extensions t
        ido-save-directory-list-file (td-data-file "ido.last")
        ido-everywhere t
        ido-ignore-buffers '("\\` ")
        ido-ignore-files '("ido.last" ".*-autoloads.el")
        ido-file-extensions-order '(".rb" ".py" ".clj" ".cljs" ".el"
                                    ".coffee" ".js" ".scss" ".css" ".php" ".html" ".db"))

  ;; (setq ido-decorations
  ;;       '("\n>> " "" "\n   " "\n   ..." "[" "]"
  ;;         " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]"
  ;;         "\n>> " ""))

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

  (defun ido-goto-line ()
    (interactive)
    (let* ((lines (split-string (buffer-string) "[\n\r]"))
           (choices (-remove (lambda (l)
                               (zerop (length l)))
                             lines))
           (line (ido-completing-read "Line: " choices)))
      (goto-line (+ 1 (-elem-index line lines)))))

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

(td-after 'ido-ubiquitous-autoloads
  (ido-ubiquitous-mode t))

(td-after 'ido-ubiquitous
  (setq ido-ubiquitous-enable-old-style-default nil))

(td-after 'ido-vertical-mode-autoloads
  (ido-vertical-mode t))

;;;; projectile
(td-after 'projectile-autoloads
  (projectile-global-mode)
  (td-bind "M-p" #'projectile-find-file
           "C-c a" #'projectile-ag))

(td-after 'projectile
  (setq projectile-tags-command "ctags -Re %s %s"
        projectile-completion-system 'ido))

;;;; diff
(td-after 'ediff
  (setq ediff-split-window-function 'split-window-horizontally))

;;;; spell
;; (add-hook 'text-mode-hook #'turn-on-flyspell)
;; (add-hook 'prog-mode-hook #'flyspell-prog-mode)

(td-after 'flyspell
  (td-bind flyspell-mode-map "C-;" nil))

(td-after 'ispell
  (setq ispell-extra-args '("-C")))

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

(td-bind "C-c s" #'ido-ispell-word-at-point)

(td-after 'hippie-exp
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
      t)))

;;;; yasnippets
(td-after 'yasnippet-autoloads
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-global-mode t))

(td-after 'yasnippet
  (setq yas-prompt-functions '(yas-ido-prompt yas-completing-prompt yas-no-prompt)))

;;;; rainbow-mode
(td-after 'rainbow-mode-autoloads
  (add-hook 'css-mode-hook #'rainbow-mode))

;;;; expand-region
(td-bind "C--" #'er/expand-region)

;;;; multiple-cursors
(td-after 'multiple-cursors-autoloads
  (td-bind "C-<" #'mc/mark-previous-like-this
           "C->" #'mc/mark-next-like-this
           "C-c C->" #'mc/mark-all-like-this))

;;;; org
(td-after 'org
  (setq org-export-allow-bind-keywords t
        org-export-latex-listings 'minted
        org-src-fontify-natively t)

  (add-to-list 'org-export-latex-packages-alist '("" "minted")))

;;;; rainbow-delimiters
(td-after 'rainbow-delimiters-autoloads
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode-enable)
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode-enable)
  (add-hook 'nrepl-mode-hook #'rainbow-delimiters-mode-enable))

;;;; diff-hl
(td-after 'diff-hl-autoloads
  (global-diff-hl-mode))

(td-after 'diff-hl
  (unless (display-graphic-p)
    (diff-hl-margin-mode t))

  (setq diff-hl-draw-borders nil
        diff-hl-fringe-bmp-function #'td-diff-hl-bmp)

  ;; (define-fringe-bitmap 'diff-hl-bmp-insert
  ;;   [0 24 24 126 126 24 24 0])
  ;; (define-fringe-bitmap 'diff-hl-bmp-delete
  ;;   [0 0 0 126 126 0 0 0])
  ;; (define-fringe-bitmap 'diff-hl-bmp-change
  ;;   [0 60 126 126 126 126 60 0]
  ;;   [0 0 24 60 60 24 0 0])
  ;;
  ;; (+ (expt 2 15) (expt 2 14) (expt 2 13) (expt 2 12))
  ;;

  (define-fringe-bitmap 'td-diff-hl-bmp [61440] 1 16 '(top t))
  (defun td-diff-hl-bmp (type pos) 'td-diff-hl-bmp)

  (defadvice magit-mode-quit-window
    (after update-diff-hl activate)
    (mapc (lambda (buffer)
            (with-current-buffer buffer (diff-hl-update)))
          (buffer-list)))

  (defun diff-hl-overlay-modified (ov after-p beg end &optional len)
    "Markers disappear and reapear is kind of annoying to me."))

(td-after 'diff-hl-margin
  (defun td-make-diff-hl-margin-spec (type char)
    (cons (cons type 'left)
          (propertize
           " " 'display
           `((margin left-margin)
             ,(propertize char 'face
                          (intern (format "diff-hl-%s" type)))))))
  (setq diff-hl-margin-spec-cache
        (list
         (td-make-diff-hl-margin-spec 'insert "|")
         (td-make-diff-hl-margin-spec 'delete "|")
         (td-make-diff-hl-margin-spec 'change "|")
         (td-make-diff-hl-margin-spec 'unknown "|"))))

;;;; undo-tree
(td-after 'undo-tree-autoloads
  (global-undo-tree-mode t))

(td-after 'undo-tree
  (setq undo-limit (* 128 1024 1024)
        undo-strong-limit (* 256 1024 1024)
        undo-tree-auto-save-history t
        undo-tree-visualizer-relative-timestamps t
        undo-tree-visualizer-timestamps t
        undo-tree-history-directory-alist
        (list (cons "." (td-data-file "undos"))))

  (defadvice undo-tree-make-history-save-file-name
    (after undo-tree activate)
    (setq ad-return-value (concat ad-return-value ".gz"))))

;;;; ace-jump-mode
(td-after 'ace-jump-mode-autoloads
  (td-bind "C-'" #'ace-jump-mode))

;;;; evil
(td-after 'evil-autoloads
  (evil-mode t)
  (setq-default mode-line-format
                (cons '(evil-mode ("" evil-mode-line-tag)) mode-line-format)))

(td-after 'evil
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

  (td-bind evil-normal-state-map
           "''" (td-cmd (evil-goto-mark ?`))
           "C-j" (td-cmd (evil-next-visual-line 10))
           "C-k" (td-cmd (evil-previous-visual-line 10))
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
  (td-bind evil-insert-state-map
           "C-a" #'back-to-indentation
           "C-e" #'end-of-line
           "C-d" #'delete-char
           "M-h" " => "
           "M-a" "@")
  (td-bind evil-visual-state-map
           "Y" #'simpleclip-copy
           "M-a" #'align=
           "C-a" #'back-to-indentation
           "C-e" #'end-of-line
           "ge" #'extract-variable
           "*" #'evil-visualstar/begin-search-forward
           "#" #'evil-visualstar/begin-search-backward)
  (td-bind evil-motion-state-map
           "C-a" #'back-to-indentation
           "C-e" #'end-of-line
           "<tab>" #'evil-jump-item
           "TAB" #'evil-jump-item)

  (defadvice evil-ex-pattern-whole-line
    (after evil-global-defaults activate)
    (setq ad-return-value "g")))

;;;; magit
(td-after 'magit-autoloads
  (td-bind "C-c g" #'magit-status))

(td-after 'magit
  (setq magit-restore-window-configuration t
        magit-save-some-buffers t)

  (add-hook 'magit-status-mode-hook #'delete-other-windows)

  (defun magit-quick-amend ()
    (interactive)
    (save-window-excursion
      (magit-with-refresh
        (shell-command "git --no-pager commit --amend --reuse-message=HEAD"))))

  (td-bind magit-status-mode-map
           "C-c C-a" #'magit-quick-amend))

(td-after 'git-commit-mode
  (setq magit-commit-all-when-nothing-staged t))

;;;; electric
(electric-pair-mode t)

(defun td-smart-brace ()
  (when (and (eq last-command-event ?\n)
             (looking-at "[<}]"))
    (indent-according-to-mode)
    (forward-line -1)
    (end-of-line)
    (newline-and-indent)))

(defun td-smart-parenthesis ()
  (when (and (eq last-command-event ?\s)
             (or (and (looking-back "( " (- (point) 2))
                      (looking-at ")"))
                 (and (looking-back "{ " (- (point) 2))
                      (looking-at "}"))
                 (and (looking-back "\\[ " (- (point) 2))
                      (looking-at "\\]"))))
    (insert " ")
    (backward-char 1)))

(add-hook 'post-self-insert-hook #'td-smart-brace t)
(add-hook 'post-self-insert-hook #'td-smart-parenthesis t)

;;;; hideshow
(autoload 'hideshowvis-symbols
  "hideshowvis"
  "Will indicate regions foldable with hideshow in the fringe.")

(td-after 'hideshowvis
  (defadvice display-code-line-counts
    (around hideshowvis-no-line-count activate)
    ad-do-it
    (overlay-put ov 'display " ...")))

(hideshowvis-symbols)

;;;; figlet
(defun figlet-region (beg end)
  (interactive "r")
  (let ((message (buffer-substring-no-properties beg end)))
    (kill-region beg end)
    (insert (shell-command-to-string
             (format "figlet -f%s \"%s\"" "chunky" message)))))

(td-bind "C-c C-f" #'figlet-region)

;;;; whitespace
(td-after 'whitespace
  (add-to-list 'whitespace-display-mappings
               '(newline-mark ?\n [?\u00AC ?\n] [?$ ?\n]) t)
  (setq whitespace-style
        '(face
          tabs tab-mark
          spaces space-mark
          newline newline-mark
          trailing lines-tail
          space-before-tab space-after-tab))
  (setq whitespace-line-column fill-column))

;;;; popwin
(autoload 'popwin-mode "popwin"
  "Auto manage popup buffers")

(popwin-mode t)

(td-after 'popwin
  (add-to-list 'popwin:special-display-config 'cider-popup-buffer-mode)
  (add-to-list 'popwin:special-display-config "*cider-error*")
  (add-to-list 'popwin:special-display-config 'ag-mode))

;; prog
(defun td-custom-font-lock-hightlights ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\(ME\\)?\\|TODO\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t)))
  (font-lock-add-keywords
   nil '(("%\\(?:[-+0-9\\$.]+\\)?[bdiuoxXDOUfeEgGcCsSpn]"
          0 font-lock-preprocessor-face t)))
  (number-font-lock-mode t))

(add-hook 'prog-mode-hook 'td-custom-font-lock-hightlights)

;;;; flycheck
(td-after 'flycheck-autoloads
  (defun turn-on-flycheck ()
    (interactive)
    (flycheck-mode t))

  (defun td-elisp-flycheck-may-turn-on ()
    (unless (string-match "init.el" (or (buffer-file-name) ""))
      (turn-on-flycheck)))

  (add-hook 'go-mode-hook #'turn-on-flycheck)
  (add-hook 'emacs-lisp-mode-hook #'td-elisp-flycheck-may-turn-on))

(td-after 'flycheck
  (setq flycheck-check-syntax-automatically '(mode-enabled save))
  (mapc (lambda (checker)
          (delq checker flycheck-checkers))
        '(go-build emacs-lisp-checkdoc)))

;;;; web
(td-mode 'html-mode
         "\\.html" "*twig*" "*tmpl*" "\\.erb" "\\.rhtml$" "\\.ejs$" "\\.hbs$"
         "\\.ctp$" "\\.tpl$" "/\\(html\\|view\\|template\\|layout\\)/.*\\.php$")

(td-after 'mmm-mode-autoloads
  (setq mmm-global-mode 'auto
        mmm-submode-decoration-level 0
        mmm-parse-when-idle t
        mmm-mode-prefix-key (kbd "C-c n"))

  (require 'mmm-auto)
  (require 'mmm-sample)

  (mmm-add-mode-ext-class 'html-mode nil 'html-js)
  (mmm-add-mode-ext-class 'html-mode nil 'html-css)
  (mmm-add-mode-ext-class 'html-mode "\\.ejs\\'" 'ejs)
  (mmm-add-mode-ext-class 'html-mode "\\.\\(erb\\|rhtml\\)\\'" 'erb)
  (mmm-add-mode-ext-class 'html-mode "\\.\\(html\\|html\\.php\\|tmpl\\|ctp\\|tpl\\)\\'" 'html-php)
  (mmm-add-mode-ext-class 'html-mode "/\\(html\\|view\\|template\\|layout\\)/.*\\.php\\'" 'html-php)
  (mmm-add-mode-ext-class 'sh-mode nil 'here-doc)
  (mmm-add-mode-ext-class 'php-mode nil 'here-doc)
  (mmm-add-mode-ext-class 'ruby-mode nil 'here-doc)

  (defun td-mmm-yaml-front-matter-verify ()
    (eq (line-beginning-position) (point-min)))

  (mmm-add-group
   'markdown-extensions
   '((markdown-code-block
      :front "^\\([`~]\\{3,\\}\\)\\([a-zA-Z0-9_-]+\\)$"
      :front-offset (end-of-line 1)
      :save-matches 1
      :back "^~1$"
      :match-submode mmm-here-doc-get-mode
      :insert ((?c markdown-code-block
                   "Code Block Name: " @ "```" str _ "\n" @ "\n" @ "```" "\n" @)))
     (markdown-yaml-front-matter
      :front "^\\(-\\{3,\\}\\)$"
      :front-verify td-mmm-yaml-front-matter-verify
      :front-offset (end-of-line 1)
      :save-matches 1
      :back "^~1$"
      :submode yaml-mode)))
  (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-extensions))

(td-after 'emmet-mode-autoloads
  (add-hook 'sgml-mode-hook #'emmet-mode)
  (add-hook 'web-mode-hook #'emmet-mode)
  (add-hook 'css-mode-hook #'emmet-mode))

(td-after 'emmet-mode
  (setq emmet-indentation 2
        emmet-preview-default nil
        emmet-insert-flash-time 0.1)

  (defadvice emmet-preview
    (after emmet-preview-hide-tooltip activate)
    (overlay-put emmet-preview-output 'before-string nil)))

;;;; javascript
(td-after 'js
  (setq js-indent-level 2
        js-expr-indent-offset 2
        js-flat-functions t))

(td-after 'tern-autoloads
  (add-hook 'js-mode-hook (lambda () (tern-mode t))))

(td-after 'tern-auto-complete-autoloads
  (add-hook 'js-mode-hook #'tern-ac-setup))

(td-after 'nodejs-repl-autoloads
  (defalias 'run-js 'nodejs-repl)

  (defun js-send-region-dwim (&optional args)
    (interactive "*P")
    (with-region-or-current-line
      (js-send-region (region-beginning) (region-end))))

  (defun td-inf-js-setup ()
    (td-bind (current-local-map)
             "C-x C-e" #'js-send-region-dwim
             "C-x C-b" #'js-send-buffer))

  (add-hook 'js-mode-hook #'td-inf-js-setup))

(td-after 'nodejs-repl
  (defun nodejs-repl-ac-candidates ()
    (let* ((input (buffer-substring (comint-line-beginning-position) (point)))
           (token (nodejs-repl--get-last-token input))
           (candidates (nodejs-repl-get-candidates token)))
      candidates))

  (ac-define-source nodejs-repl
    '((prefix . (comint-line-beginning-position))
      (candidates . nodejs-repl-ac-candidates))))

;;;; typescript
(td-after 'tss-autoloads
  (td-mode 'typescript-mode "\\.ts$"))

(td-after 'typescript
  (tss-config-default))

;;;; coffee
(td-after 'coffee-mode-autoloads
  (td-mode 'coffee-mode "\\.coffee$" "Cakefile"))

;;;; css
(defun td-css-imenu-expressions ()
  (add-to-list 'imenu-generic-expression '("Section" "^.*\\* =\\(.+\\)$" 1) t))

(td-after 'css-mode
  (add-hook 'css-mode-hook #'td-css-imenu-expressions)
  (setq css-indent-offset 2))

;;;; scss
(td-after 'scss-mode
  (add-hook 'scss-mode-hook #'td-css-imenu-expressions)
  (setq scss-compile-at-save nil))

;;;; emacs lisp
(td-after 'lisp-mode
  (defun td-elisp-imenu-expressions ()
    (setq imenu-prev-index-position-function nil)
    (add-to-list 'imenu-generic-expression '("Section" "^;;;; \\(.+\\)$" 1) t))

  (add-hook 'emacs-lisp-mode-hook #'td-elisp-imenu-expressions)
  (add-hook 'emacs-lisp-mode-hook #'turn-on-eldoc-mode))

(td-after 'eldoc
  (setq eldoc-idle-delay 0
        eldoc-echo-area-use-multiline-p nil))

;;;; php
(td-after 'php-mode
  (setq php-template-compatibility nil
        php-manual-path "~/local/docs/php")

  (add-hook 'php-mode-hook #'php-enable-drupal-coding-style)

  (td-bind php-mode-map "C-c C-b" nil))

;;;; ruby
(td-mode 'ruby-mode
         "\\.rb$" "\\.ru$" "\\.rake$"
         "Rakefile" "Guardfile" "Gemfile" "Vagrantfile")

(td-after 'ruby-mode
  (setq ruby-deep-arglist nil
        ruby-deep-indent-paren nil
        ruby-insert-encoding-magic-comment nil)

  (td-bind ruby-mode-map "C-M-f" nil)

  (add-to-list 'hs-special-modes-alist
               '(ruby-mode
                 "\\(def\\|do\\|{\\)" "\\(end\\|end\\|}\\)" "#"
                 (lambda (arg) (ruby-end-of-block)) nil)))

;;;; python
(td-after 'python
  (setq python-indent-offset 4
        python-indent-guess-indent-offset nil)
  (defun setup-python-mode ()
    (td-set-local tab-width 4))
  (add-hook 'python-mode-hook #'setup-python-mode))

;;;; c


;;;; vala
(autoload 'vala-mode "vala-mode"
  "Major mode for editing Vala files; updated for Emacs 24.")

(td-mode 'vala-mode "\\.vala$")

(td-after 'vala-mode
  (td-on 'vala-mode-hook
    (td-set-local c-basic-offset 4)))

;;;; java
(td-after 'javadoc-lookup
  (javadoc-add-roots "~/local/docs/jdk/docs/api"))

;;;; clojure
(td-after 'clojure-mode
  (define-clojure-indent
    (defroutes 'defun) (context 2)
    (GET 2) (POST 2) (PUT 2) (DELETE 2) (HEAD 2) (ANY 2)
    (run 2) (run* 2) (fresh 'defun)))

(td-after 'cider-mode
  (td-bind cider-mode-map
           "C-c C-b" nil
           "C-c C-g" 'cider-interrupt)
  (add-hook 'cider-mode-hook #'ac-nrepl-setup)
  (add-hook 'cider-mode-hook #'cider-turn-on-eldoc-mode))

(td-after 'cider-repl
  (setq cider-repl-popup-stacktraces t
        cider-repl-pop-to-buffer-on-connect nil))

;;;; go
(td-after 'go-mode
  (exec-path-from-shell-copy-env "GOPATH")
  (require 'go-autocomplete)
  (add-hook 'go-mode-hook #'go-eldoc-setup))

;;;; rust
(td-after 'rust-mode
  (setq rust-indent-offset 4))

;;;; markdown
(td-after 'markdown-mode-autoloads
  (td-mode 'markdown-mode "\\.md$" "\\.mkd$" "\\.markdown$"))

(td-after 'markdown-mode
  (setq markdown-command "redcarpet"
        markdown-enable-math t
        markdown-header-face '(:inherit font-lock-function-name-face :weight bold)
        markdown-header-face-1 '(:inherit markdown-header-face :height 2.0)
        markdown-header-face-2 '(:inherit markdown-header-face :height 1.6)
        markdown-header-face-3 '(:inherit markdown-header-face :height 1.4)
        markdown-header-face-4 '(:inherit markdown-header-face :height 1.2))

  (add-hook 'markdown-mode-hook #'turn-on-flyspell)
  (add-hook 'markdown-mode-hook #'turn-on-auto-fill)

  (td-bind markdown-mode-map "M-p" nil)
  (td-bind markdown-mode-map "C-c C-b" nil))

;;;; sh
(td-after 'sh-script
  (setq sh-indentation 2))

;;;; commands
(defmacro with-region-or-current-line (&rest body)
  (declare (indent defun) (debug t))
  `(if (region-active-p) ,@body
     (progn
       (end-of-line)
       (set-mark (line-beginning-position))
       ,@body
       (deactivate-mark))))

(defun comment-or-uncomment-region-dwim (&optional args)
  (interactive "*P")
  (comment-normalize-vars)
  (with-region-or-current-line
    (comment-or-uncomment-region (region-beginning) (region-end))))

(defun open-file-at-point ()
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
     "Make Executable" nil "chmod" "u+x" (file-name-nondirectory buffer-file-name))))

(defun align=: (&optional args)
  "Align region to equal signs or colon"
  (interactive)
  (with-region-or-current-line
    (align-regexp (region-beginning) (region-end) "\\(\\s-*\\)[=|:]" 1 1)))

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

(defun imenu-flat ()
  (interactive)
  (let* ((symbols
          (apply #'append
                 (mapcar (lambda (index)
                           (if (listp (cdr index)) (cdr index) (list index)))
                         imenu--index-alist)))
         (index (completing-read "Symbol: " symbols)))
    (goto-char (cdr (assoc index symbols)))))

(defun buffers-of-mode (mode)
  (-filter (lambda (b)
             (with-current-buffer b (eq mode major-mode)))
           (buffer-list)))

(defun same-mode-buffers ()
  (buffers-of-mode major-mode))

(defun td-toggle-fullscreen ()
  "ns-toggle-fullscreen is not cool for me"
  (interactive)
  (set-frame-parameter
   nil 'fullscreen
   (when (not (frame-parameter nil 'fullscreen)) 'fullboth)))

(defun local-buffer? (buffer)
  (and (buffer-file-name buffer)
       (not (string-match tramp-file-name-regexp (buffer-file-name buffer)))))

(defun current-buffer-lines (&optional buffer)
  (let ((buffer (or buffer (current-buffer))))
    (with-current-buffer buffer
      (split-string
       (buffer-substring-no-properties (point-min) (point-max))
       "\n"))))

(defun recentf-ido-find-file ()
  "Find a recent file using Ido."
  (interactive)
  (let ((file (ido-completing-read "Recent file: " recentf-list nil t)))
    (when file
      (find-file file))))

(defun end-with-semicolon ()
  (interactive)
  (end-of-line)
  (insert ";"))

;;;; advices
(defadvice save-buffers-kill-emacs
  (around no-query-kill-emacs activate)
  (cl-labels ((process-list ())) ad-do-it))
