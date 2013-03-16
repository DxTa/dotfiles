
(defvar tung/programming-environment-hook nil)

(defun tung/setup-programming-environment ()
  (interactive)
  (setq require-final-newline t)
  (hs-minor-mode t)
  (run-hooks 'tung/programming-environment-hook))


(provide 'tung-programming-mode)
