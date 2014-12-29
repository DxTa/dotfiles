
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)

(defvar td/packages)
(setq td/packages
      '(ace-jump-mode
        ag
        ant
        anzu
        async
        base16-theme
        benchmark-init
        bind-key
        cider
        clojure-mode
        comment-dwim-2
        company
        dash
        diff-hl
        diminish
        emmet-mode
        exec-path-from-shell
        expand-region
        f
        fish-mode
        flx
        flx-ido
        ;; hideshowvis
        flycheck
        flycheck-cask
        fringe-helper
        gitconfig-mode
        groovy-mode
        highlight-escape-sequences
        highlight-parentheses
        http
        ibuffer-vc
        ido-ubiquitous
        ido-vertical-mode
        js2-mode
        json-mode
        magit
        markdown-mode
        multiple-cursors
        noflet
        origami
        php-mode
        popwin
        prodigy
        projectile
        rainbow-delimiters
        rainbow-mode
        request
        s
        scss-mode
        smart-mode-line
        smartparens
        smex
        solarized-theme
        undo-tree
        use-package
        web-mode
        wgrep
        wgrep-ag
        window-numbering
        yaml-mode
        yasnippet
        ztree
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
