
(add-to-list 'load-path (expand-file-name "~/.emacs.d/config"))

;; Major modes
(require 'config-coffee)
(require 'config-css)
(require 'config-scss)
(require 'config-emacs-lisp)
(require 'config-clojure)
(require 'config-html)
(require 'config-php)
(require 'config-js)
(require 'config-ruby)
(require 'config-c)
(require 'config-haskell)
(require 'config-markdown)
(require 'config-org)
(require 'config-shell)
; (require 'config-mmm)
; (require 'config-deft)


;; Minor modes
(require 'config-undo-tree)
(require 'config-evil)
(require 'config-ido)
(require 'config-hideshow)
(require 'config-auto-complete)
(require 'config-yasnippet)
(require 'config-eproject)

(require 'config-occur)
(require 'config-electric)
(require 'config-multiple-cursors)
(require 'config-magit)
(require 'config-simpleclip)
(require 'config-git-gutter )

;; (require 'config-autopair)
;; (require 'config-hippie-expand)
;; (require 'config-popwin)
;; (require 'config-typewriter)


;; Things that are not autoloaded
(require 'dired)
(require 'uniquify)

;; (setq nurumacs-map nil)
;; (require 'nurumacs)
