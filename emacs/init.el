
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
(autoload 's-trim "s")
(autoload 'zap-up-to-char "misc" nil :interactive)
(autoload 'zap-to-char "misc" nil :interactive)

;;;; platform specific
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta
        mac-option-modifier 'super))

;;;; helpers
(setq user-emacs-directory "~/.emacs.d/data/")

(defmacro td/after (file &rest body)
  (declare (indent 1) (debug t))
  `(progn
     (eval-when-compile
       (require ,file nil :no-error))
     (eval-after-load ,file
       `(funcall (function ,(lambda () ,@body))))))

(defmacro td/cmd (&rest body)
  `(lambda () (interactive) ,@body))

(defmacro td/on (hook &rest body)
  (declare (indent 1))
  `(add-hook ,hook (function (lambda () ,@body))))

(defun td/mode (mode &rest patterns)
  (mapc (lambda (pattern)
          (add-to-list 'auto-mode-alist (cons pattern mode)))
        patterns))

(defmacro td/key-group (name prefix &rest mappings)
  (let ((name (intern (format "%s-map" name))))
    `(progn
       (defvar ,name nil ,(format "Prefix command for '%s'." name))
       (define-prefix-command ',name)
       (td/bind ,prefix ,name)
       (td/bind ,name ,@mappings))))

(defun td/bind (&rest mappings)
  (let ((keymap (if (eq 1 (mod (length mappings) 2))
                    (pop mappings)
                  (current-global-map))))
    (while mappings
      (let* ((key (pop mappings))
             (cmd (pop mappings)))
        (define-key keymap (kbd key) cmd)))))

(defun td/data-file (f)
  (expand-file-name f user-emacs-directory))

(defun td/set-local (&rest args)
  "Vary-arity version of `setq-local'"
  (while args
    (let* ((name (pop args))
           (value (pop args)))
      (set (make-local-variable name) value))))

;;;; custom
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file :no-error :no-message)

(defun td/from-git-config (key)
  (s-trim (shell-command-to-string
           (format "git config --global --get %s" key))))

(setq user-full-name (td/from-git-config "user.name")
      user-mail-address (td/from-git-config "user.email"))

;;;; startup
(defun td/scratch-fortune ()
  (shell-command-to-string "fortune -a | sed -e 's/^/;; /'"))

(setq inhibit-startup-message t
      initial-scratch-message (td/scratch-fortune))

(td/on 'emacs-startup-hook
  (message "Time needed to load: %s seconds." (emacs-uptime "%s")))

(defun td/setup-frame (frame)
  (interactive)
  (message "%s" (display-graphic-p))
  (when (eq system-type 'darwin)
    (when (display-graphic-p)
      (set-face-attribute 'default frame :family "Meslo LG M" :height 140)
      (set-frame-size frame 120 35)
      (set-frame-position frame 500 22)))
  (when (eq system-type 'gnu/linux)
    (menu-bar-mode -1)
    (set-face-attribute 'default frame :family "M+ 1mn" :height 110)))

(add-hook 'after-make-frame-functions #'td/setup-frame)

;;;; random seed
(random t)

;;;; server
(require 'server)

(td/after 'server
  (unless (server-running-p) (server-start nil)))

;;;; aliases
(defalias 'qrr 'query-replace-regexp)
(defalias 'qr 'query-replace)
(defalias 'yes-or-no-p 'y-or-n-p)

;;;; keys
(td/bind "C-M-f" #'td/toggle-fullscreen)
(td/bind "M-m" #'execute-extended-command)
(td/bind "M-n" (td/cmd (next-line 10)))
(td/bind "M-p" (td/cmd (previous-line 10)))

(td/bind "RET" #'newline-and-indent)

(td/bind "M-=" #'cleanup-buffer)
(td/bind "C-=" #'indent-defun)

(td/bind "M-j" #'other-window)
(td/bind "M-`" #'other-frame)
(td/bind "C-c q" #'delete-frame)
(td/bind "C-c Q" #'delete-window)
(td/bind "C-c k" #'kill-buffer-and-window)

(td/bind "C-c c" #'server-edit)
(td/bind "C-c n" #'imenu-flat)
(td/bind "C-c i" #'imenu)
(td/bind "C-c b" #'ido-switch-buffer)
(td/bind "C-c f" #'find-file)
(td/bind "C-c u" #'recentf-ido-find-file)
(td/bind "C-c l" #'ido-goto-line)
(td/bind "C-c t" #'tags-search)
(td/bind "C-x C-b" #'ibuffer
         "C-c C-b" #'ibuffer)
(td/bind "C-c w" #'whitespace-mode)
(td/bind "C-c m" #'recompile)
(td/bind "C-c SPC" #'set-rectangular-region-anchor)

(td/bind "C-c C-e" #'eval-and-replace)
(td/bind "M-J" (td/cmd (join-line -1)))
(td/bind "C-l" #'comment-or-uncomment-region-or-line)
(td/bind "C-]" #'recenter-top-bottom)
(td/bind "M-." #'find-tag-at-point)
(td/bind "M-z" #'zap-up-to-char)
(td/bind "M-Z" #'zap-to-char)
(td/bind "M-o" #'open-thing-at-point)

(td/bind "C-w" #'kill-region-or-word
         "C-c r" #'vr/query-replace
         "C-c y" #'simpleclip-paste
         "C-c C-y" #'simpleclip-copy)

;;;; general
(exec-path-from-shell-initialize)

(setq delete-by-moving-to-trash t
      ring-bell-function 'ignore
      x-select-enable-clipboard nil
      frame-title-format '("%b %+%+ %f")
      default-input-method 'vietnamese-telex
      tab-stop-list (number-sequence 2 128 2)
      history-length 256
      confirm-nonexistent-file-or-buffer nil
      comment-style 'multi-line
      require-final-newline t
      mode-require-final-newline nil)

(setq-default major-mode 'text-mode
              tab-width 2
              indicate-empty-lines nil
              indent-tabs-mode nil
              fill-column 80
              truncate-lines nil)

(td/after 'imenu
  (setq imenu-auto-rescan t))

(visual-line-mode -1)
(which-function-mode t)
(global-auto-revert-mode t)
(savehist-mode t)
(pending-delete-mode t)

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

(defun isearch-accents-fold-search ()
  "Enable accents-folding for ISearch. Support only Vietnamese accents atm.
Source: http://thread.gmane.org/gmane.emacs.devel/117003/focus=117959.
FIXME: refactor"
  (interactive)
  (let ((eqv-list '("aàáạảãăằắặẳẵâầấậẩẫAÀÁẠẢÃĂẰẮẶẲẴÂẦẤẬẨẪ"
                    "eèéẹẻẽêềếệểễEÈÉẸẺẼÊỀẾỆỂỄ"
                    "dđDĐ"
                    "iìíịỉĩIÌÍỊỈĨ"
                    "oòóọỏõôồốộổỗơờớợởỡOÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ"
                    "uùúụủũưừứựửữUÙÚỤỦŨƯỪỨỰỬỮ"
                    "yỳýỵỷỹYỲÝỴỶỸ"))
        (table (standard-case-table))
        (canon (copy-sequence (standard-case-table))))
    (mapc (lambda (s)
            (mapc (lambda (c) (aset canon c (aref s 0))) s))
          eqv-list)
    (set-char-table-extra-slot table 1 canon)
    (set-char-table-extra-slot table 2 nil)
    (set-standard-case-table table)))

(isearch-accents-fold-search)

(when (display-graphic-p)
  ;; Fallback font for Latin Extended Aditional (support Vietnamese text)
  (set-fontset-font nil '(#x1e00 . #x1eff) (font-spec :family "DejaVu Sans Mono")))


;; Insert special character -- like a boss
(setq read-quoted-char-radix 16)

;;;; backup
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      backup-directory-alist
      (list (cons "." (td/data-file "backups"))))

(setq auto-save-default nil
      auto-save-list-file-prefix
      (td/data-file "auto-saves"))

;;;; tramp
(td/after 'tramp
  (setq password-cache-expiry nil
        tramp-default-method "ftp"))

;;;; file
(defun find-file-sudo (&optional arg)
  (interactive "F")
  (unless (and buffer-file-name
               (file-writable-p buffer-file-name))
    (find-alternate-file
     (concat "/sudo:root@localhost:" buffer-file-name))))

(add-hook 'find-file-hook #'find-file-sudo)

(defun td/before-save-make-directories ()
  (let ((dir (file-name-directory buffer-file-name)))
    (when (and buffer-file-name (not (file-exists-p dir)))
      (make-directory dir t))))

(add-hook 'before-save-hook #'td/before-save-make-directories)

(defun td/after-save-auto-chmod ()
  (when (string-equal "#!" (buffer-substring-no-properties 1 4))
    (shell-command
     (format "chmod u+x %s"
             (shell-quote-argument (buffer-file-name))))))

(add-hook 'after-save-hook #'td/after-save-auto-chmod)

;;;; uniquify
(require 'uniquify)
(td/after 'uniquify
  (setq uniquify-buffer-name-style 'post-forward
        uniquify-separator " - "
        uniquify-after-kill-buffer-p t
        uniquify-ignore-buffers-re "^\\*"))

;;;; saveplace
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (td/data-file "save-places"))

;;;; recentf
(td/after 'recentf
  (add-to-list 'recentf-exclude "ido")
  (add-to-list 'recentf-exclude "elpa")
  (add-to-list 'recentf-exclude "cache")
  (add-hook 'server-visit-hook #'recentf-save-list))

(setq recentf-max-saved-items 256
      recentf-save-file (td/data-file "recentf"))

(recentf-mode t)

;;;; display
(setcdr
 (assoc 'truncation fringe-indicator-alist) nil)

(let ((display-table
       (or standard-display-table
           (setq standard-display-table (make-display-table)))))
  (set-display-table-slot display-table 'truncation ?¬)
  (set-window-display-table (selected-window) display-table))

(setq custom-theme-directory "~/.emacs.d/themes/")

(defun td/clear-themes ()
  (interactive)
  "One time I decided that I don't want theme properties propagate, however I
changed my mind and use one theme with my own custom theme now"
  (mapc #'disable-theme custom-enabled-themes))

;; (color-theme-approximate-on)
(load-theme 'junio t)
(load-theme 'td-custom t)

;;;; linum
(column-number-mode t)

(td/after 'linum
  (setq linum-format " %4d "))

;;;; hl-line
(global-hl-line-mode t)

;;;; show-paren-mode
(td/after 'paren
  (setq show-paren-delay 0))

(show-paren-mode t)

;;;; diminish
(td/after 'diminish-autoloads
  (defun td/compact-mode-line (file mode &optional lighter)
    (eval-after-load file
      `(diminish ,mode ,(when lighter (concat " " lighter)))))

  (mapc (lambda (args)
          (apply #'td/compact-mode-line args))
        '(("company" 'company-mode "CP")
          ("yasnippet" 'yas-minor-mode "Y")
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
(td/after 'ibuffer
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

  (defun td/ibuffer-hook ()
    (ibuffer-auto-mode 1)
    (ibuffer-switch-to-saved-filter-groups "Default")
    (ibuffer-vc-add-filter-groups)
    (ibuffer-do-sort-by-alphabetic))

  (add-hook 'ibuffer-mode-hook #'td/ibuffer-hook))

;;;; completion
(td/key-group td/completion "M-;"
              ";" #'end-with-semicolon
              "M-;" #'end-with-semicolon)

;;;; company
(td/after 'company-autoloads
  (global-company-mode t)

  (setq tab-always-indent 'complete
        completion-cycle-threshold 5)

  (add-to-list 'completion-styles 'initial)

  (defun td/setup-company-completion-at-point ()
    (setq completion-at-point-functions '(company-complete-common)))

  (add-hook 'prog-mode-hook #'td/setup-company-completion-at-point))

(td/after 'company
  (setq company-idle-delay nil
        company-auto-complete t
        company-selectionn-wrap-around t
        company-echo-delay 0
        company-tooltip-align-annotations t
        company-show-numbers t

        company-auto-complete-chars
        '(?\ ?\( ?\) ?. ?\" ?$ ?\' ?< ?> ?| ?!)

        company-transformers
        '(company-sort-by-occurrence)

        company-frontends
        '(company-pseudo-tooltip-unless-just-one-frontend
          company-echo-metadata-frontend
          company-preview-frontend)

        company-backends
        '((company-yasnippet
           company-dabbrev-code company-keywords
           company-cider
           company-tern
           company-go
           company-elisp
           company-css
           company-php-reflection
           company-clang)))

  (td/bind td/completion-map
           "s" #'company-yasnippet
           "f" #'company-files
           "l" #'company-lines)

  (td/bind company-active-map
           "<tab>" #'company-select-next
           "<backtab>" #'company-select-previous
           "C-n" #'company-select-next
           "C-p" #'company-select-previous
           "C-s" #'company-filter-candidates
           "C-l" #'company-show-location
           "C-j" #'company-complete-common
           "C-w" nil))

;;;; ido
(td/after 'smex-autoloads
  (setq smex-save-file (td/data-file "smex"))
  (smex-initialize)
  (td/bind "M-m" #'smex
           "C-c C-m" #'smex))

(ido-mode t)

(td/after 'ido
  (setq ido-enable-prefix nil
        ido-enable-dot-prefix t
        ido-use-virtual-buffers t
        ido-auto-merge-work-directories-length -1
        ido-create-new-buffer 'always
        ido-use-url-at-point nil
        ido-use-filename-at-point nil
        ido-ignore-extensions t
        ido-save-directory-list-file (td/data-file "ido.last")
        ido-enable-flex-matching t
        ido-case-fold t
        ido-ignore-buffers '("\\` ")
        ido-ignore-files '("ido.last" ".*-autoloads.el")
        ido-file-extensions-order '(".rb" ".py" ".clj" ".cljs" ".el"
                                    ".coffee" ".js" ".scss" ".css" ".php" ".html" t))

  ;; (setq ido-decorations
  ;;       '("\n>> " "" "\n   " "\n   ..." "[" "]"
  ;;         " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]"
  ;;         "\n>> " ""))

  (defun td/minibuffer-home ()
    (interactive)
    (if (looking-back "/")
        (insert "~/")
      (call-interactively 'self-insert-command)))

  (defun td/minibuffer-insert-word-at-point ()
    (interactive)
    (let (word beg)
      (with-current-buffer (window-buffer (minibuffer-selected-window))
        (setq word (thing-at-point 'word)))
      (insert word)))

  (defun ido-goto-line ()
    (interactive)
    (let* ((lines (split-string (buffer-string) "[\n\r]"))
           (choices (-remove (lambda (l) (zerop (length l))) lines))
           (line (ido-completing-read "Line: " choices)))
      (push-mark)
      (goto-line (+ 1 (-elem-index line lines)))))

  (defun td/ido-hook ()
    (td/bind ido-completion-map
             "C-h" #'delete-backward-char
             "ESC" #'ido-exit-minibuffer
             "C-w" #'ido-delete-backward-updir
             "C-n" #'ido-next-match
             "C-p" #'ido-prev-match
             "TAB" #'ido-complete
             "C-l" #'td/minibuffer-insert-word-at-point
             "~" #'td/minibuffer-home))

  (add-hook 'ido-setup-hook #'td/ido-hook))

(td/after 'ido-ubiquitous-autoloads
  (ido-ubiquitous-mode t))

(td/after 'ido-ubiquitous
  (setq ido-ubiquitous-enable-old-style-default nil))

(td/after 'ido-vertical-mode-autoloads
  (ido-vertical-mode t))

;;;; projectile
(td/after 'projectile-autoloads
  (projectile-global-mode)

  (add-to-list 'projectile-globally-ignored-directories "node_modules")

  (td/bind "M-l" #'projectile-find-file))

;;;; diff
(td/after 'ediff
  (setq ediff-split-window-function 'split-window-horizontally))

;;;; spell
;; (add-hook 'text-mode-hook #'turn-on-flyspell)
;; (add-hook 'prog-mode-hook #'flyspell-prog-mode)

(td/after 'flyspell
  (td/bind flyspell-mode-map "C-;" nil))

(td/after 'ispell
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

(td/bind "C-c s" #'ido-ispell-word-at-point)

(td/after 'hippie-exp
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
(td/after 'yasnippet-autoloads
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-global-mode t))

(td/after 'yasnippet
  (setq yas-prompt-functions
        '(yas-ido-prompt yas-completing-prompt yas-no-prompt))

  (td/bind yas-minor-mode-map
           "TAB" nil
           "<tab>" nil
           "SPC" #'yas-expand))

;;;; rainbow-mode
(td/after 'rainbow-mode-autoloads
  (add-hook 'css-mode-hook #'rainbow-mode))

;;;; expand-region
(td/bind "M--" #'er/expand-region)

;;;; multiple-cursors
(td/after 'multiple-cursors-autoloads
  (td/bind "M-(" #'mc/mark-previous-like-this
           "M-)" #'mc/mark-next-like-this
           "M-9" #'mc/skip-to-previous-like-this
           "M-0" #'mc/skip-to-next-like-this
           "C-c a" #'mc/mark-all-like-this))

;;;; org
(td/after 'org
  (setq org-export-allow-bind-keywords t
        org-export-latex-listings 'minted
        org-src-fontify-natively t)

  (add-to-list 'org-export-latex-packages-alist '("" "minted"))

  (setq org-agenda-files
        '("~/Dropbox/gtd.org" "~/Dropbox/archives.org"))

  (setq org-agenda-custom-commands
        '(("w" todo "WAITING" nil)
          ("n" todo "TODO" nil)
          ("d" "Agenda + Next Actions" ((agenda) (todo "TODO")))
          ("r" "Weekly Review"
           ((agenda "" ((org-agenda-ndays 7)))
            ;; type "l" in the agenda to review logged items
            (stuck "")
            (todo "PROJECT")
            (todo "MAYBE")
            (todo "WAITING")))))

  (setq org-refile-targets '(("gtd.org" :level . 1)
                             ("archives.org" :level . 1))))

(td/key-group td/org "C-c o"
              "l" #'org-store-link
              "c" #'org-capture
              "a" #'org-agenda)

;;;; rainbow-delimiters
(td/after 'rainbow-delimiters-autoloads
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode-enable)
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode-enable)
  (add-hook 'nrepl-mode-hook #'rainbow-delimiters-mode-enable))

;;;; diff-hl
(td/after 'diff-hl-autoloads
  (global-diff-hl-mode))

(td/after 'diff-hl
  (setq diff-hl-draw-borders nil
        diff-hl-fringe-bmp-function #'td/diff-hl-bmp)

  (define-fringe-bitmap 'td/diff-hl-bmp [61440] 1 16 '(top t))
  (defun td/diff-hl-bmp (type pos) 'td/diff-hl-bmp)

  (defadvice magit-mode-quit-window
    (after update-diff-hl activate)
    (mapc (lambda (buffer)
            (with-current-buffer buffer (diff-hl-update)))
          (buffer-list)))

  (defun diff-hl-overlay-modified (ov after-p beg end &optional len)
    "Markers disappear and reapear is kind of annoying to me."))

(td/after 'diff-hl-margin
  (defun td/make-diff-hl-margin-spec (type char)
    (cons (cons type 'left)
          (propertize
           "  " 'display
           `((margin left-margin)
             ,(propertize char 'face
                          (intern (format "diff-hl-%s" type)))))))
  (setq diff-hl-margin-spec-cache
        (list
         (td/make-diff-hl-margin-spec 'insert "| ")
         (td/make-diff-hl-margin-spec 'delete "| ")
         (td/make-diff-hl-margin-spec 'change "| ")
         (td/make-diff-hl-margin-spec 'unknown "| "))))

;;;; undo-tree
(td/after 'undo-tree-autoloads
  (global-undo-tree-mode t))

(td/after 'undo-tree
  (setq undo-limit (* 128 1024 1024)
        undo-strong-limit (* 256 1024 1024)
        undo-tree-auto-save-history t
        undo-tree-visualizer-relative-timestamps t
        undo-tree-visualizer-timestamps t
        undo-tree-history-directory-alist
        (list (cons "." (td/data-file "undos")))))

;;;; ace-jump-mode
(td/after 'ace-jump-mode-autoloads
  (td/bind "M-'" #'ace-jump-mode))

;;;; magit
(td/after 'magit-autoloads
  (td/bind "C-c g" #'magit-status))

(td/after 'magit
  (setq magit-restore-window-configuration t
        magit-save-some-buffers t)

  (add-hook 'magit-status-mode-hook #'delete-other-windows)

  (defun magit-quick-amend ()
    (interactive)
    (start-process-shell-command
     "*magit-commit-amend*" nil
     "git --no-pager commit --amend --reuse-message=HEAD")
    (magit-refresh))

  (td/bind magit-status-mode-map
           "C-c C-a" #'magit-quick-amend))

(td/after 'git-commit-mode
  (setq magit-commit-all-when-nothing-staged t))

(td/after 'vc-hooks
  (setq vc-follow-symlinks t))

;;;; electric
(electric-pair-mode t)

(defun td/smart-brace ()
  (when (and (eq last-command-event ?\n)
             (looking-at "[<}]"))
    (indent-according-to-mode)
    (forward-line -1)
    (end-of-line)
    (newline-and-indent)))

(defun td/smart-parenthesis ()
  (when (and (eq last-command-event ?\s)
             (or (and (looking-back "( " (- (point) 2))
                      (looking-at ")"))
                 (and (looking-back "{ " (- (point) 2))
                      (looking-at "}"))
                 (and (looking-back "\\[ " (- (point) 2))
                      (looking-at "\\]"))))
    (insert " ")
    (backward-char 1)))

(add-hook 'post-self-insert-hook #'td/smart-brace t)
(add-hook 'post-self-insert-hook #'td/smart-parenthesis t)

;;;; typewriter-sound
(autoload 'typewriter-mode
  "typewriter-mode"
  "Play typewriter sound effect when typing.")

;;;; copy-as-html-for-paste
(autoload 'copy-as-html-for-paste
  "copy-as-html-for-paste"
  "Copy region or buffer as rich HTML text for pasting.")

(td/bind "C-c h" #'copy-as-html-for-paste)

;;;; hideshow
(autoload 'hideshowvis-symbols
  "hideshowvis"
  "Will indicate regions foldable with hideshow in the fringe.")

(td/after 'hideshow
  (hideshowvis-symbols)
  (td/bind "C-c C-SPC" #'hs-toggle-hiding))

(td/after 'hideshowvis
  (defadvice display-code-line-counts
    (around hideshowvis-no-line-count activate)
    ad-do-it
    (overlay-put ov 'display " ...")))

(add-hook 'prog-mode-hook (lambda () (hs-minor-mode t)))

;;;; figlet
(defun figlet-region (beg end)
  (interactive "r")
  (let ((message (buffer-substring-no-properties beg end)))
    (kill-region beg end)
    (insert (shell-command-to-string
             (format "figlet -f%s \"%s\"" "graffiti" message)))))

;;;; whitespace
(td/after 'whitespace
  (add-to-list 'whitespace-display-mappings
               '(newline-mark ?\n [?\u00AC ?\n] [?$ ?\n]) t)
  (setq whitespace-style
        '(face
          tabs tab-mark
          spaces space-mark
          newline newline-mark
          trailing lines-tail
          space-before-tab space-after-tab)
        whitespace-line-column fill-column)

  (add-hook 'before-save-hook #'whitespace-cleanup)
  (add-hook 'before-save-hook #'delete-trailing-whitespace))

;; dired
(td/after 'dired
  (setq dired-listing-switches "-alh")

  (defun td/dired-back-to-top ()
    (interactive)
    (goto-char (point-min))
    (dired-next-line 4))

  (define-key dired-mode-map
    (vector 'remap 'beginning-of-buffer) 'td/dired-back-to-top)

  (defun td/dired-jump-to-bottom ()
    (interactive)
    (goto-char (point-max))
    (dired-next-line -1))

  (define-key dired-mode-map
    (vector 'remap 'end-of-buffer) 'td/dired-jump-to-bottom))

;; prog
(defun td/custom-font-lock-hightlights ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\(ME\\)?\\|TODO\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t)))
  (font-lock-add-keywords
   nil '(("%\\(?:[-+0-9\\$.]+\\)?[bdiuoxXDOUfeEgGcCsSpn]"
          0 font-lock-preprocessor-face t)))
  (number-font-lock-mode t))

(add-hook 'prog-mode-hook 'td/custom-font-lock-hightlights)

;;;; flycheck
(td/after 'flycheck-autoloads
  (defun turn-on-flycheck ()
    (interactive)
    (flycheck-mode t))

  (mapc (lambda (hook)
          (add-hook hook #'turn-on-flycheck))
        '(go-mode-hook
          emacs-lisp-mode-hook
          js-mode-hook
          coffee-mode-hook
          ruby-mode-hook
          rust-mode-hook
          sh-mode-hook)))

(td/after 'flycheck
  (setq flycheck-check-syntax-automatically '(mode-enabled save))
  (mapc (lambda (checker)
          (delq checker flycheck-checkers))
        '(go-build emacs-lisp-checkdoc)))

;;;; web
(td/mode 'html-mode
         "\\.html" "*twig*" "*tmpl*" "\\.erb" "\\.rhtml$" "\\.ejs$" "\\.hbs$"
         "\\.ctp$" "\\.tpl$" "/\\(html\\|view\\|template\\|layout\\)/.*\\.php$")

(td/after 'mmm-mode-autoloads
  (setq mmm-global-mode 'maybe
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

  (defun td/mmm-yaml-front-matter-verify ()
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
      :front-verify td/mmm-yaml-front-matter-verify
      :front-offset (end-of-line 1)
      :save-matches 1
      :back "^~1$"
      :submode yaml-mode)))
  (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-extensions))

(td/after 'emmet-mode-autoloads
  (add-hook 'sgml-mode-hook #'emmet-mode)
  (add-hook 'web-mode-hook #'emmet-mode)
  (add-hook 'css-mode-hook #'emmet-mode))

(td/after 'emmet-mode
  (setq emmet-indentation 2
        emmet-preview-default nil
        emmet-insert-flash-time 0.1)

  (defadvice emmet-preview
    (after emmet-preview-hide-tooltip activate)
    (overlay-put emmet-preview-output 'before-string nil)))

;;;; javascript
(td/after 'js
  (setq js-indent-level 2
        js-expr-indent-offset 2
        js-flat-functions t)

  (defun td/javascript-style ()
    (interactive)
    (c-set-offset 'arglist-cont '+))

  (add-hook 'js-mode-hook #'td/javascript-style))

(td/after 'tern-autoloads
  (add-hook 'js-mode-hook (lambda () (tern-mode t))))

;;;; typescript
(td/after 'tss-autoloads
  (td/mode 'typescript-mode "\\.ts$"))

(td/after 'typescript
  (tss-config-default))

;;;; coffee
(td/after 'coffee-mode-autoloads
  (td/mode 'coffee-mode "\\.coffee$" "Cakefile"))

;;;; css
(defun td/css-imenu-expressions ()
  (add-to-list 'imenu-generic-expression '("Section" "^.*\\* =\\(.+\\)$" 1) t))

(td/after 'css-mode
  (add-hook 'css-mode-hook #'td/css-imenu-expressions)
  (setq css-indent-offset 2))

;;;; scss
(td/after 'scss-mode
  (add-hook 'scss-mode-hook #'td/css-imenu-expressions)
  (setq scss-compile-at-save nil))

;;;; emacs lisp
(td/after 'lisp-mode
  (defun td/elisp-imenu-expressions ()
    (setq imenu-prev-index-position-function nil)
    (add-to-list 'imenu-generic-expression '("Section" "^;;;; \\(.+\\)$" 1) t))

  (add-hook 'emacs-lisp-mode-hook #'td/elisp-imenu-expressions)
  (add-hook 'emacs-lisp-mode-hook #'turn-on-eldoc-mode))

(td/after 'eldoc
  (setq eldoc-idle-delay 0
        eldoc-echo-area-use-multiline-p nil))

;;;; php
(td/after 'php-mode
  (setq php-template-compatibility nil
        php-manual-path "~/local/docs/php")

  (defun td/setup-php-mode ()
    (td/set-local 'eldoc-documentation-function #'company-php-eldoc)
    (eldoc-mode))

  (add-hook 'php-mode-hook #'php-enable-drupal-coding-style)
  (add-hook 'php-mode-hook #'td/setup-php-mode)

  (td/bind php-mode-map "C-c C-b" nil))

;;;; groovy
(td/mode 'groovy-mode "\\.gradle$")

;;;; ruby
(td/mode 'ruby-mode
         "\\.rb$" "\\.ru$" "\\.rake$"
         "Rakefile" "Guardfile" "Gemfile" "Vagrantfile")

(td/after 'ruby-mode
  (setq ruby-deep-arglist nil
        ruby-deep-indent-paren nil
        ruby-insert-encoding-magic-comment nil)

  (td/bind ruby-mode-map "C-M-f" nil)

  (add-to-list 'hs-special-modes-alist
               '(ruby-mode
                 "\\(def\\|do\\|{\\)" "\\(end\\|end\\|}\\)" "#"
                 (lambda (arg) (ruby-end-of-block)) nil)))

;;;; python
(td/after 'python
  (setq python-indent-offset 4
        python-indent-guess-indent-offset nil)

  (defun td/setup-python-mode ()
    (td/set-local tab-width 4))

  (add-hook 'python-mode-hook #'td/setup-python-mode))

;;;; c

;;;; vala
(autoload 'vala-mode "vala-mode"
  "Major mode for editing Vala files; updated for Emacs 24.")

(td/mode 'vala-mode "\\.vala$")

(td/after 'vala-mode
  (defun td/vala-style ()
    (interactive)
    (setq c-basic-offset 4
          indent-tabs-mode nil)
    (c-set-offset 'arglist-intro '+)
    (c-set-offset 'arglist-cont '+)
    (c-set-offset 'arglist-cont-nonempty '+))

  (add-hook 'vala-mode-hook #'td/vala-style))

;;;; java
(td/after 'javadoc-lookup
  (javadoc-add-roots "~/local/docs/jdk/docs/api"))

;;;; clojure
(td/after 'clojure-mode
  (define-clojure-indent
    (defroutes 'defun) (context 2)
    (GET 2) (POST 2) (PUT 2) (DELETE 2) (HEAD 2) (ANY 2)
    (run 2) (run* 2) (fresh 'defun)))

(td/after 'cider-mode
  (td/bind cider-mode-map
           "C-c C-b" nil
           "C-c C-g" 'cider-interrupt)
  (add-hook 'cider-mode-hook #'cider-turn-on-eldoc-mode))

(td/after 'cider-repl
  (setq cider-repl-popup-stacktraces t
        cider-repl-pop-to-buffer-on-connect nil))

;;;; go
(td/after 'go-mode
  (exec-path-from-shell-copy-env "GOPATH")
  (add-hook 'go-mode-hook #'go-eldoc-setup))

;;;; rust
(td/after 'rust-mode
  (setq rust-indent-offset 4))

;;;; markdown
(td/after 'markdown-mode-autoloads
  (td/mode 'markdown-mode "\\.md$" "\\.mkd$" "\\.markdown$"))

(td/after 'markdown-mode
  (setq markdown-command "redcarpet"
        markdown-enable-math t
        markdown-header-face '(:inherit font-lock-function-name-face :weight bold)
        markdown-header-face-1 '(:inherit markdown-header-face :height 2.0)
        markdown-header-face-2 '(:inherit markdown-header-face :height 1.6)
        markdown-header-face-3 '(:inherit markdown-header-face :height 1.4)
        markdown-header-face-4 '(:inherit markdown-header-face :height 1.2))

  (add-hook 'markdown-mode-hook #'turn-on-flyspell)
  (add-hook 'markdown-mode-hook #'turn-on-auto-fill)

  (td/bind markdown-mode-map
           "M-p" nil
           "M-n" nil
           "C-c C-b" nil))

;;;; sh
(td/after 'sh-script
  (setq sh-basic-offset 2
        sh-indentation 2))

;;;; popup shell
;; shamlessly copy from http://tsdh.wordpress.com/2011/10/12/a-quick-pop-up-shell-for-emacs/
(defun td/shell-popup ()
  "Toggle a shell popup buffer with the current file's directory as cwd."
  (interactive)
  (unless (get-buffer "*Popup Shell*")
    (save-window-excursion (shell "*Popup Shell*")))
  (let* ((popup-buffer (get-buffer "*Popup Shell*"))
         (win (get-buffer-window popup-buffer))
         (dir (file-name-directory
               (or (buffer-file-name) dired-directory "~/"))))
    (if win
        (quit-window nil win)
      (pop-to-buffer popup-buffer nil t)
      (comint-send-string nil (concat "cd " dir "\n")))))

(td/bind "<f12>" #'td/shell-popup)

;;;; commands
(defmacro with-region-or-current-line (&rest body)
  (declare (indent defun) (debug t))
  `(if (region-active-p) ,@body
     (progn
       (end-of-line)
       (set-mark (line-beginning-position))
       ,@body
       (deactivate-mark))))

(defun kill-region-or-word (arg)
  (interactive "*P")
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (backward-kill-word 1)))

(defun comment-or-uncomment-region-or-line (&optional args)
  (interactive "*P")
  (comment-normalize-vars)
  (with-region-or-current-line
    (comment-or-uncomment-region (region-beginning) (region-end))))

(defun open-thing-at-point ()
  (interactive)
  (-when-let (url (thing-at-point 'url))
    (browse-url url))
  (-when-let (email (thing-at-point 'email))
    (browse-url (format "mailto:%s" email)))
  (-when-let (path (thing-at-point 'filename))
    (if (file-exists-p path)
        (find-file path)
      (if (file-exists-p (concat path ".el"))
          (find-file (concat path ".el"))
        (when (y-or-n-p (format "Creat %s?" path))
          (find-file path))))))

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

(defun td/toggle-fullscreen ()
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

(defun multi-occur-same-mode-buffers ()
  "Show all lines matching pattern in buffers with the same major mode."
  (interactive)
  (multi-occur
   (same-mode-buffers)
   (car (occur-read-primary-args))))

(defun find-tag-at-point ()
  (interactive)
  (find-tag (thing-at-point 'symbol)))

;;;; advices
(defadvice save-buffers-kill-emacs
  (around no-query-kill-emacs activate)
  (cl-labels ((process-list ())) ad-do-it))
