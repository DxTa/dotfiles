
;; Cleanup
(setq inhibit-startup-message t)

(dolist (m '(tool-bar-mode scroll-bar-mode blink-cursor-mode))
  (when (fboundp m) (eval `(,m -1))))


;; Uniquify
(setq uniquify-buffer-name-style 'post-forward
      uniquify-separator " - "
      uniquify-after-kill-buffer-p t
      uniquify-ignore-buffers-re "^\\*")


;; Linum
(setq linum-format "%5d")


;; Fillcolumn
(custom-set-variables '(fill-column 80))


;; Show parent
(setq show-paren-delay 0)
(show-paren-mode t)


;; Mode-line format
(load "modeline")


;; Whitespace
(setq whitespace-display-mappings
      '((newline-mark ?\n [?\u00AC ?\n] [?$ ?\n])
        (tab-mark     ?\t [?\u2192 ?\t] [?\\ ?\t])))


;; History based sorting is still awesome
(smex-initialize)


;; Theme
(global-font-lock-mode t)
(column-number-mode 1)
(hl-line-mode t)

;; (setq jit-lock-defer-time 0.05)

(setq default-frame-alist
      '((width . 100) (height . 36)
        (left-fringe . 0) (right-fringe . 0))
      cursor-type 'bar)

;; Color Theme don't accumulate
(defadvice load-theme (before tung/color-theme-dont-accumulate activate)
  (dolist (theme (custom-available-themes))
    (disable-theme theme)))

(setq custom-theme-directory "~/.emacs.d/themes/")
(load-theme 'tung t)

(set-face-attribute 'mode-line nil :box nil)
(set-face-attribute 'mode-line-highlight nil :box '(:line-width 1))

(eval-after-load 'rainbow-delimiters
  '(progn
     (defun set-up-rainbow-delimiter-faces ()
       (set-face-attribute 'rainbow-delimiters-depth-1-face nil :foreground "#d97a35")
       (set-face-attribute 'rainbow-delimiters-depth-2-face nil :foreground "#deae3e")
       (set-face-attribute 'rainbow-delimiters-depth-3-face nil :foreground "#81af34")
       (set-face-attribute 'rainbow-delimiters-depth-4-face nil :foreground "#4e9f75")
       (set-face-attribute 'rainbow-delimiters-depth-5-face nil :foreground "#11535F")
       (set-face-attribute 'rainbow-delimiters-depth-6-face nil :foreground "#00959e")
       (set-face-attribute 'rainbow-delimiters-depth-7-face nil :foreground "#8700ff")
       (set-face-attribute 'rainbow-delimiters-unmatched-face nil :background "#d13120"))
     (defadvice load-theme (after tung/rainbow-delimiter-faces activate)
       (set-up-rainbow-delimiter-faces))
     (set-up-rainbow-delimiter-faces)))
