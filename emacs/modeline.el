
;; Shorter Minor mode
(loop for (file mode lighter)
      in '(("yasnippet" 'yas-minor-mode "Y")
           ("eldoc" 'eldoc-mode "Doc")
           ("flycheck" 'flycheck-mode "F")
           ("eproject" 'eproject-mode "Proj")
           ("hideshow" 'hs-minor-mode)
           ("undo-tree" 'undo-tree-mode)
           ("rainbow-mode" 'rainbow-mode)
           ("isearch-mode" 'isearch-mode)
           ("abbrev" 'abbrev-mode)
           ("autopair" 'autopair-mode "P")
           ("git-gutter" 'git-gutter-mode))
      do
      (eval-after-load file
        `(diminish ,mode ,(when lighter (concat " " lighter)))))

;; Modeline
(setq eol-mnemonic-dos " dos "
      eol-mnemonic-mac " mac "
      eol-mnemonic-unix " unix "
      eol-mnemonic-undecided " - ")


;; Evil current mode indicator
(defvar evil-mode-line-modified nil)
(eval-after-load 'evil
  '(progn
     (unless evil-mode-line-modified
       (setq-default mode-line-format
                     (cons '(evil-mode ("" evil-mode-line-tag)) mode-line-format))
       (setq evil-mode-line-modified t))))


(provide 'tung-modeline)
