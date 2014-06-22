
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(when (eq 0 (length package-alist))
  (package-refresh-contents)
  (dolist
      (pkg '(ace-jump-mode
             ag
             cider
             circe
             clojure-mode
             coffee-mode
             color-theme-approximate
             company
             company-c-headers
             dash
             diff-hl
             diminish
             emmet-mode
             epl
             evil
             evil-matchit
             evil-surround
             evil-visualstar
             exec-path-from-shell
             expand-region
             f
             flycheck
             htmlize
             ibuffer-vc
             ido-ubiquitous
             ido-vertical-mode
             ignoramus
             javadoc-lookup
             lua-mode
             magit
             markdown-mode
             mmm-mode
             multiple-cursors
             number-font-lock-mode
             package-filter
             php-mode
             popwin
             projectile
             rainbow-delimiters
             rainbow-mode
             restclient
             rust-mode
             s
             scss-mode
             simpleclip
             slamhound
             smex
             solarized-theme
             sublime-themes
             tern
             undo-tree
             websocket
             wgrep
             wgrep-ag
             yasnippet))
    (unless (package-installed-p pkg)
      (package-install pkg))))


(provide 'td-package)
