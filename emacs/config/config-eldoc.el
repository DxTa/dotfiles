
(defvar tung/eldoc-active t)
(setq tung/eldoc-active t)

(setq eldoc-documentation-function
      (lambda ()
        (when tung/eldoc-active
          (let (eldoc-documentation-function)
            (eldoc-print-current-symbol-info)))))

(defvar tung/eldoc-enabled-modes
  '(emacs-lisp-mode lisp-interaction-mode)
  "Modes that has eldoc enabled.")

(defun tung/eldoc-maybe-active ()
  (unless (memq major-mode tung/eldoc-enabled-modes)
    (eldoc-mode -1)))

(add-hook 'after-change-major-mode-hook #'tung/eldoc-maybe-active)

(eval-after-load 'eldoc
  '(progn
     (setq eldoc-argument-case 'downcase)))


(provide 'config-eldoc)
