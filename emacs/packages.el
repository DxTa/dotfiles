
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)

(defvar td/packages)
(setq td/packages
      '(ace-jump-mode
        ag
        anzu
        benchmark-init
        cider
        clojure-mode
        comment-dwim-2
        company
        diff-hl
        ;; elixir-mix
        ;; elixir-mode
        emmet-mode
        exec-path-from-shell
        expand-region
        flycheck
        flx-ido
        hideshowvis
        highlight-escape-sequences
        highlight-parentheses
        ibuffer-vc
        ido-ubiquitous
        ido-vertical-mode
        js2-mode
        json-mode
        markdown-mode
        multiple-cursors
        php-mode
        popwin
        prodigy
        projectile
        rainbow-delimiters
        rainbow-mode
        smart-mode-line
        smartparens
        scss-mode
        smex
        solarized-theme
        undo-tree
        use-package
        web-mode
        wgrep-ag
        window-numbering
        yaml-mode
        yasnippet
        ))

(defun td/install-packages ()
  (interactive)
  (package-refresh-contents)
  (dolist (p td/packages)
    (unless (package-installed-p p)
      (package-install p))))

(unless (package-installed-p 'use-package)
  (td/install-packages))

(provide 'packages)
