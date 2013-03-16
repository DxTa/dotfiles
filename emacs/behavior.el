
(setq ring-bell-function 'ignore
      delete-by-moving-to-trash t
      x-select-enable-clipboard nil)


;; Which function
(which-function-mode t)


;; Recentf
(recentf-mode 1)
(setq recentf-max-saved-items 100)
(add-to-list 'recentf-exclude "ido.last")
(add-hook 'server-visit-hook 'recentf-save-list)


;; Tramp
(setq tramp-default-method "ftp"
      password-cache-expiry nil)


;; Ediff
(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain)


;; Compile time warnings
(setq byte-compile-warnings '(not cl-functions))


;; Backup
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      backup-directory-alist `((".*" . "~/.emacs.d/data/backups/")
                               (,tramp-file-name-regexp . nil)))


;; Auto save
(setq auto-save-default nil
      auto-save-file-name-transforms `((".*" "~/.emacs.d/data/auto-saves/")
                                       (,tramp-file-name-regexp nil)))


;; Auto revert
(global-auto-revert-mode t)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)


;; Save Place
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file "~/.emacs.d/data/saved-places")


;; Encoding
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(if (boundp 'buffer-file-coding-system)
    (setq-default buffer-file-coding-system 'utf-8-unix)
  (setq default-buffer-file-coding-system 'utf-8-unix))


;; Editor
(setq frame-title-format '("emacs@" system-name ": %b %+%+ %f"))
(mouse-avoidance-mode 'cat-and-mouse)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq reb-re-syntax 'string)
(setq default-input-method 'vietnamese-telex)

(auto-compression-mode t)
(transient-mark-mode t)

(setq-default major-mode 'text-mode
              tab-width 2
              c-basic-offset 2
              indicate-empty-lines nil
              indent-tabs-mode nil
              truncate-lines t
              imenu-auto-rescan t)

(let ((ratio (/ (car tab-stop-list) 2)))
  (setq tab-stop-list
        (mapcar (lambda (n) (/ n ratio)) tab-stop-list)))

(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; History based sorting is still awesome
(smex-initialize)
