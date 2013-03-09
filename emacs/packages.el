
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)


(defvar tung/packages
  '(melpa

    evil surround sackspace multiple-cursors simpleclip auto-complete yasnippet
    magit zencoding-mode flycheck

    rainbow-mode rainbow-delimiters diminish smex ido-ubiquitous
    color-theme-approximate git-gutter eproject ibuffer-vc ack-and-a-half
    wgrep-ack

    apache-mode clojure-mode coffee-mode markdown-mode php-mode ruby-mode
    scss-mode lua-mode js2-mode yaml-mode haskell-mode rust-mode web-mode

    nrepl ac-nrepl skewer-mode restclient
    ))

(defun tung/install-packages ()
  (interactive)
  (package-refresh-contents)
  (dolist (p tung/packages)
    (unless (package-installed-p p)
      (package-install p))))
