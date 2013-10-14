
;; Bootstrap Emacs on first run.
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;;;;
(defvar td-packages
  '(ac-nrepl ace-jump-mode ack-and-a-half alert auto-complete clojure-mode coffee-mode
             color-theme-approximate dash diff-hl diminish emmet-mode evil evil-visualstar
             exec-path-from-shell expand-region f flx flx-ido flycheck fringe-helper git-commit-mode
             git-rebase-mode go-autocomplete go-eldoc go-mode groovy-mode ibuffer-vc ido-ubiquitous
             ido-vertical-mode inf-php inf-ruby javadoc-lookup js-comint log4e magit markdown-mode
             melpa multiple-cursors nodejs-repl nrepl number-font-lock-mode php-mode pkg-info popup
             projectile rainbow-delimiters rainbow-mode restclient ruby-dev rust-mode s scala-mode2
             scss-mode simpleclip smex solarized-theme sublime-themes surround tern
             tern-auto-complete tss twilight-theme undo-tree w3m wgrep yaml-mode yasnippet
             yaxception)
  "Packages that I used. Generated with: (reverse (mapcar #'car package-alist))")

(defun td-install-package (pkg)
  (unless (package-installed-p pkg)
    (package-install pkg)))

(defun td-install-packages ()
  (interactive)
  (package-refresh-contents)
  (mapc #'td-install-package td-packages))

;;;;
(package-refresh-contents)

(package-install 'melpa)
(mapc #'td-install-package td-packages)
