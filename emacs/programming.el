
(defvar tung/programming-environment-hook nil)

(defun tung/setup-programming-environment ()
  (interactive)
  (setq require-final-newline t)
  (hl-line-mode t)
  (git-gutter-mode t)
  (run-hooks 'tung/programming-environment-hook))

(provide 'tung-programming-mode)
