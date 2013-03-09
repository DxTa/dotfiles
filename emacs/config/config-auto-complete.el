
(require 'auto-complete-config)

(eval-after-load 'auto-complete
  '(progn
     (ac-config-default)
     (setq ac-auto-start nil
           ac-show-menu nil
           ac-use-menu-map t
           ac-candidate-limit 100
           ac-disable-inline t
           ac-use-fuzzy t
           ac-trigger-key "M-/"
           ac-comphist-file "~/.emacs.d/data/ac-comphist.dat")

     ;; (dolist (source '(ac-source-gtags))
     ;;   (delq source ac-sources))

     (setq tab-always-indent 'complete)
     (add-to-list 'completion-styles 'initials t)
     (add-hook 'auto-complete-mode-hook
               (lambda ()
                 (setq completion-at-point-functions '(auto-complete))))

     (tung/fill-keymap ac-complete-mode-map
                       "C-n" 'ac-next
                       "C-p" 'ac-previous
                       "C-l" 'ac-expand-common
                       "ESC" 'ac-stop)

     (defadvice linum-update
       (around tung/suppress-linum-update-when-popup activate)
       (unless (ac-menu-live-p)
         ad-do-it))))


(provide 'config-auto-complete)
