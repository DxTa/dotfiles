
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

(package-initialize)
(package-refresh-contents)

;; (reverse (mapcar #'epl-package-name (epl-installed-packages)))
(defvar td/packages '(ace-jump-mode ag cider circe clojure-mode
  coffee-mode color-theme-approximate company company-c-headers
  company-inf-python dash deft diff-hl diminish emmet-mode epl
  espresso-theme evil evil-matchit evil-surround evil-visualstar
  exec-path-from-shell expand-region f flycheck git-commit-mode
  git-rebase-mode goto-chg htmlize ibuffer-vc ido-ubiquitous
  ido-vertical-mode ignoramus javadoc-lookup js-comint js2-mode
  json-mode json-reformat json-snatcher lcs lua-mode lui magit
  markdown-mode mmm-mode multiple-cursors number-font-lock-mode
  parent-mode php-mode pkg-info popwin projectile
  rainbow-delimiters rainbow-mode restclient rust-mode s
  scss-mode shorten simpleclip slamhound smartparens smex
  solarized-theme sublime-themes tern tracking undo-tree
  websocket wgrep wgrep-ag yaml-mode yasnippet))


(dolist (pkg td/packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))


(provide 'packages)
