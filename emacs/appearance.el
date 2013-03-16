
(global-font-lock-mode t)
(global-hl-line-mode t)
(column-number-mode 1)

;; Window
(unless (display-graphic-p) (menu-bar-mode -1))

(dolist (m '(tool-bar-mode scroll-bar-mode blink-cursor-mode))
  (when (fboundp m) (eval `(,m -1))))


;; Frame
(setq default-frame-alist
      '((width . 110) (height . 35)
        (left-fringe . 24) (right-fringe . 0))
      cursor-type 'bar
      initial-frame-alist default-frame-alist)

(defun set-frame-size-and-position-according-to-resolution ()
  (interactive)
  (when (display-graphic-p)
    (let ((frame (selected-frame))
          (width (x-display-pixel-width))
          (height (x-display-pixel-height)))
      (set-frame-height frame (- (/ height 21) 1))
      (if (> width 1280)
          (set-frame-position frame (- width 860) 0)
      (set-frame-position frame (+ width 200) 0)))))


(defalias 'aa #'set-frame-size-and-position-according-to-resolution "Auto Adjust")

;; Theme
(set-display-table-slot standard-display-table 0 32)

(setq custom-theme-directory "~/.emacs.d/themes/")
(load-theme 'twilight-anti-bright t)

(defun customize-faces (frame)
  (set-face-attribute 'default frame :family "M+ 2m")
  (set-face-attribute 'mode-line frame :box nil)
  (set-face-attribute 'mode-line-highlight frame :box '(:line-width 1))
  (set-face-attribute 'highlight frame :foreground nil))

(customize-faces nil)
(add-hook 'after-make-frame-functions #'customize-faces)


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


;; Whitespace
(eval-after-load 'whitespace
  '(progn
     (setq whitespace-display-mappings
           '((newline-mark ?\n [?\u00AC ?\n] [?$ ?\n])
             (tab-mark     ?\t [?\u2192 ?\t] [?\\ ?\t])))
     (delq 'empty whitespace-style)))
