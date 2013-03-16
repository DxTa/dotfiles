
(global-undo-tree-mode t)

(eval-after-load 'undo-tree
  '(progn
     (setq undo-limit (* 8 1024 1024)
           undo-tree-auto-save-history t
           undo-tree-history-directory-alist
           '(("." . "~/.emacs.d/data/undos/")))

     (defadvice undo-tree-make-history-save-file-name
       (after undo-tree activate)
       (setq ad-return-value (concat ad-return-value ".gz")))))


(provide 'config-undo-tree)
