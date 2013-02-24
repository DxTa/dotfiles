
(tung/add-auto-mode 'js2-mode '("\\.js$" "\\.json$"))

(defun tung/setup-js-mode ()
  (interactive)
  (tung/setup-programming-environment))

(add-hook 'js2-mode-hook #'tung/setup-js-mode)
(add-hook 'js-mode-hook #'tung/setup-js-mode)

(eval-after-load 'auto-complete
  '(progn
     (add-to-list 'ac-modes 'js2-mode)
     (add-to-list 'ac-modes 'js-mode)))

(eval-after-load 'js
  '(progn
     (setq js-indent-level 2
           js-curly-indent-offset 2
           js-expr-indent-offset 2
           js-flat-functions t
           js-enabled-frameworks '(javascript dojo))))

(eval-after-load 'js2-mode
  '(setq js2-idle-timer-delay 1
         js2-auto-indent-p t
         js2-enter-indents-newline t

         js2-language-version 180
         js2-include-gears-externs nil
         js2-include-rhino-externs nil
         js2-include-node-externs t
         js2-global-externs '("console" "$" "jQuery" "define" "require")

         js2-allow-keywords-as-property-names nil
         js2-allow-rhino-new-expr-initializer nil
         js2-missing-semi-one-line-override t
         js2-strict-missing-semi-warning nil

         (define-key js2-mode-map (kbd "M-j") nil)
         ))


;; Slime
;; (add-hook 'js2-mode-hook (lambda () (slime-js-minor-mode t)))
;; (add-hook 'js-mode-hook (lambda () (slime-js-minor-mode t)))

;; (eval-after-load 'auto-complete
;;   '(progn
;;      (add-hook 'slime-js-minor-mode 'set-up-slime-ac)
;;      (add-hook 'slime-mode-hook 'set-up-slime-ac)
;;      (add-hook 'slime-repl-mode-hook 'set-up-slime-ac)))

(eval-after-load 'slime
  '(progn
     (setq slime-protocol-version 'ignore
           slime-net-coding-system 'utf-8-unix)
     (slime-setup '(slime-repl slime-js))))

(eval-after-load 'slime-js
  '(progn
     (tung/fill-keymap slime-js-minor-mode-map
                       "C-x C-e" 'slime-js-eval-region-or-line
                       "C-c C-e" 'slime-js-eval-and-replace
                       "C-c C-b" 'slime-js-eval-buffer)

     (defun slime-js--echo-result (result &rest _)
       (message result))

     (defun slime-js--replace-with-result (replacement beg end)
       (save-excursion
         (goto-char beg)
         (delete-char (- end beg))
         (insert replacement)))

     (defun slime-js-eval-line (&optional lines)
       (interactive "P")
       (slime-js-eval-region
        (line-beginning-position)
        (line-end-position lines)))

     (defun slime-js-eval-region (beg end &optional func)
       (interactive)
       (lexical-let ((func (or func 'slime-js--echo-result))
                     (beg beg)
                     (end end))
         (slime-flash-region beg end)
         (slime-js-eval
          (buffer-substring-no-properties beg end)
          #'(lambda (s) (funcall func (cadr s) beg end)))))

     (defun slime-js-eval-region-or-line (&optional lines)
       (interactive "P")
       (if (use-region-p)
           (slime-js-eval-region (point) (mark))
         (slime-js-eval-line lines)))

     (defun slime-js-eval-buffer ()
       (interactive)
       (slime-js-eval-region (point-min) (point-max)))

     (defun slime-js-eval-and-replace (&optional lines)
       (interactive "P")
       (let ((point (if (use-region-p)
                        (point) (line-beginning-position)))
             (mark (if (use-region-p)
                       (mark) (line-end-position lines))))
         (slime-js-eval-region point mark 'slime-js--replace-with-result)))

     (tung/fill-keymap slime-js-minor-mode-map "<f6>" 'slime-js-reload)

     (add-hook 'css-mode-hook
               (lambda ()
                 (slime-js-minor-mode t)
                 (tung/fill-keymap css-mode-map "<f5>" 'slime-js-refresh-css)))))


(provide 'config-js)
