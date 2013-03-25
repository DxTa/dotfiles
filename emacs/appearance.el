
(global-font-lock-mode t)
(global-hl-line-mode t)
(column-number-mode 1)

;; Window
(unless (display-graphic-p) (menu-bar-mode -1))

(dolist (m '(tool-bar-mode scroll-bar-mode blink-cursor-mode))
  (when (fboundp m) (eval `(,m -1))))


;; Frame
(setq default-frame-alist
      '((left-fringe . 24) (right-fringe . 0))
      initial-frame-alist default-frame-alist)

(setq cursor-type '(bar . 2))

(setq screen-layouts
      '((:query (= (x-display-pixel-width) 1366)
                :height 34 :width 100 :top 0 :left (- (x-display-pixel-width) 860))
        (:query (and (<= (x-display-pixel-width) 1280) (= (x-display-screens) 2))
                :height 45 :width 100 :top 10 :left (+ (x-display-pixel-width) 200))))

(defun set-frame-size-and-position-according-to-display ()
  (interactive)
  (when (display-graphic-p)
    (dolist (layout screen-layouts)
      (when (eval (plist-get layout :query))
        (and (plist-get layout :width)
             (set-frame-width (selected-frame) (eval (plist-get layout :width))))
        (and (plist-get layout :height)
             (set-frame-height (selected-frame) (eval (plist-get layout :height))))
        (set-frame-position (selected-frame)
                            (eval (plist-get layout :left))
                            (eval (plist-get layout :top)))))))

(set-frame-size-and-position-according-to-display)

(defalias 'aa #'set-frame-size-and-position-according-to-display
  "Auto Adjust frame size according to current display")


;; Theme
(set-display-table-slot standard-display-table 0 32)

(setq custom-theme-directory "~/.emacs.d/themes/")
(load-theme 'twilight-anti-bright t)

(defun customize-faces (frame)
  (set-face-attribute 'default frame :family "M+ 1m")
  (set-face-attribute 'mode-line frame :box nil)
  (set-face-attribute 'mode-line-highlight frame :box '(:line-width 1))
  (set-face-attribute 'highlight frame :foreground nil)
  (scroll-bar-mode -1))

;; (set-face-attribute 'default nil :family "M+ 1mn")
;; (set-face-attribute 'default nil :family "M+ 1m")
;; (set-face-attribute 'default nil :family "M+ 2m")

(customize-faces nil)
(add-hook 'after-make-frame-functions #'customize-faces)

(defadvice load-theme (after apply-customize-faces activate)
  (customize-faces nil))

(defadvice load-theme (before theme-dont-propagate activate)
  (mapcar #'disable-theme custom-enabled-themes))


;; Uniquify
(eval-after-load 'uniquify
  '(setq uniquify-buffer-name-style 'post-forward
         uniquify-separator " - "
         uniquify-after-kill-buffer-p t
         uniquify-ignore-buffers-re "^\\*"))


;; Linum
(eval-after-load 'linum
  '(setq linum-format "%5d"))


;; Fillcolumn
(custom-set-variables '(fill-column 80))


;; Show parent
(eval-after-load 'paren
  '(setq show-paren-delay 0))
(show-paren-mode t)


;; Whitespace
(eval-after-load 'whitespace
  '(progn
     (setq whitespace-display-mappings
           '((newline-mark ?\n [?\u00AC ?\n] [?$ ?\n])
             (tab-mark     ?\t [?\u2192 ?\t] [?\\ ?\t])))
     (delq 'empty whitespace-style)))
