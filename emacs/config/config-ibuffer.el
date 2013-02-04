
(setq ibuffer-expert t
      ibuffer-show-empty-filter-groups nil
      ibuffer-saved-filter-groups
      '(("home"
         ("Config" (or
                    (filename . "cli/")
                    (filename . ".emacs.d/")))
         ("Programming" (or
                         (mode . c-mode)
                         (mode . java-mode)
                         (mode . emacs-lisp-mode)
                         (mode . clojure-mode)
                         (mode . python-mode)
                         (mode . php-mode)
                         (mode . ruby-mode)
                         (mode . emacs-lisp-mode)
                         (mode . slime-repl-mode)
                         (mode . js2-mode)
                         (mode . web-mode)
                         (mode . css-mode)
                         (mode . scss-mode)
                         ))
         ("Notes" (filename . "~/Dropbox/Notes"))
         ("Writting" (or
                      (mode . html-mode)
                      (mode . markdown-mode)
                      ))
         ("Org" (or
                 (mode . org-mode)
                 (mode . org-agenda-mode)
                 ))
         ("Dired" (mode . dired-mode))
         ("Shells" (or
                    (mode . eshell-mode)
                    (mode . shell-mode)
                    ))
         ("Magit" (or
                   (mode . magit-mode)
                   (name . "\\*magit-.*\\*")
                   ))
         ("Help" (or (name . "\*Help\*")
                     (name . "\*Apropos\*")
                     (name . "\*info\*")))
         ))
      )

(add-hook 'ibuffer-mode-hook
          '(lambda ()
             (ibuffer-auto-mode 1)
             (ibuffer-switch-to-saved-filter-groups "home")
             (ibuffer-vc-set-filter-groups-by-vc-root)
             (unless (eq ibuffer-sorting-mode 'alphabetic)
               (ibuffer-do-sort-by-alphabetic))))


(provide 'config-ibuffer)
