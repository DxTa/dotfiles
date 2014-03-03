
(deftheme td-custom
  "My custom faces that fix some theme annoyances.")

(custom-theme-set-faces
 'td-custom
 ;; Some theme define modeline with boxed border and small font :(
 `(mode-line ((t :box nil :inherit 'unspecified :height ,(cdr (assoc :height (face-all-attributes 'default))))))
 `(mode-line-highlight ((t :box nil)))

 `(rainbow-delimiters-depth-1-face ((t :foreground "#d97a35")))
 `(rainbow-delimiters-depth-2-face ((t :foreground "#deae3e")))
 `(rainbow-delimiters-depth-3-face ((t :foreground "#81af34")))
 `(rainbow-delimiters-depth-4-face ((t :foreground "#4e9f75")))
 `(rainbow-delimiters-depth-5-face ((t :foreground "#11535F")))
 `(rainbow-delimiters-depth-6-face ((t :foreground "#00959e")))
 `(rainbow-delimiters-depth-7-face ((t :foreground "#8700ff")))
 `(rainbow-delimiters-unmatched-face ((t :background "#d13120" :underline t)))

 `(diff-hl-insert ((t :inherit 'unspecified :background "unspecified" :foreground "#81af34")))
 `(diff-hl-delete ((t :inherit 'unspecified :background "unspecified" :foreground "#ff0000")))
 `(diff-hl-change ((t :inherit 'unspecified :background "unspecified" :foreground "#deae3e")))
 `(diff-hl-unknown ((t :inherit 'unspecified :background "unspecified" :foreground "#81af34")))

 `(whitespace-space ((t :background "unspecified")))
 `(whitespace-tab ((t :background "unspecified")))

 `(emmet-preview-input ((t :box nil)))

 `(hl-line ((t :inherit 'unspecified :underline nil :foreground nil)))

 `(org-level-1 ((t :height 1.3)))
 `(org-level-2 ((t :height 1.2)))
 `(org-level-3 ((t :height 1.1)))
 )

(provide-theme 'td-custom)
