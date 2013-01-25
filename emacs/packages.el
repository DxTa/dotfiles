
(require 'package)
;; (add-to-list 'package-archives
;;              '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)


(defvar tung/packages
  '(melpa rainbow-mode rainbow-delimiters diminish smex ido-ubiquitous

    evil evil-leader autopair sackspace surround multiple-cursors simpleclip

    auto-complete yasnippet magit zencoding-mode flycheck

    color-theme-approximate
    twilight-bright-theme twilight-anti-bright-theme

    apache-mode clojure-mode clojurescript-mode coffee-mode
    markdown-mode php-mode ruby-mode scss-mode lua-mode ;;js2-mode
    yaml-mode haskell-mode web-mode

    nrepl ac-nrepl slime restclient
    eproject))

(defun tung/install-packages ()
  (interactive)
  (package-refresh-contents)
  (dolist (p tung/packages)
    (unless (package-installed-p p)
      (package-install p))))
