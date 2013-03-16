
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

(provide 'config-rainbow-delimiters)
