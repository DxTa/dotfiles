
(defun tung/setup-c-mode ()
  (interactive)
  (tung/setup-programming-environment))

(add-hook 'c-mode-hook #'tung/setup-c-mode)

(eval-after-load 'auto-complete
  '(progn
     (add-to-list 'ac-modes 'objc-mode)))


(defun tung/c-doc-function ()
  "Lookup C documentation in manpage"
  (interactive)
  (let* ((func (thing-at-point 'symbol))
         (command (format "man %s | col -b" func))
         (man (shell-command-to-string command))
         (prototype ;;(when (string-match (format "\\(%s(.*)\\);" func) man)
          (when (string-match (format "\\(%s(.*)\\);" func) man)
                      (match-string 1 man)))
         (usage
          (when (string-match (format "The %s() function \\(.*\\)" func) man)
                  (concat "\n\n" (match-string 1 man)))))
    (concat prototype usage)))


(provide 'config-c)
