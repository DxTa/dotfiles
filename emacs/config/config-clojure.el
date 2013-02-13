
(defun tung/setup-clojure-mode ()
  (interactive)
  (tung/setup-emacs-lisp-mode))

(add-hook 'clojure-mode-hook #'tung/setup-clojure-mode)

(eval-after-load 'clojure-mode
  '(define-clojure-indent
      (defroutes 'defun)
      (GET 2)
      (POST 2)
      (PUT 2)
      (DELETE 2)
      (HEAD 2)
      (ANY 2)
      (context 2)))

;; nrepl
(eval-after-load 'nrepl
  '(progn
     (add-hook 'nrepl-mode-hook
               (lambda ()
                 (nrepl-eval "(set! *print-length* 30)")
                 (nrepl-eval "(set! *print-level* 5)")))

     (add-hook 'nrepl-mode-hook 'ac-nrepl-setup)
     (add-hook 'nrepl-interaction-mode-hook 'ac-nrepl-setup)))

(eval-after-load 'auto-complete
  '(progn
     (add-to-list 'ac-modes 'clojure-mode)
     (add-to-list 'ac-modes 'nrepl-mode)
     (add-hook 'clojure-mode-hook 'ac-nrepl-setup)))


(provide 'config-clojure)
