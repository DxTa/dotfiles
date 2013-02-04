
(tung/add-auto-mode 'markdown-mode
                    '("\\.md$" "\\.mkd$" "\\.markdown$"))

(defun tung/setup-markdown-mode ()
  (interactive)
  (tung/setup-programming-environment))

(add-hook 'markdown-mode-hook #'tung/setup-markdown-mode)

(eval-after-load 'markdown-mode
  '(progn
     (setq markdown-command "pandoc -s"
         markdown-enable-math t
         markdown-header-face '(:inherit font-lock-function-name-face :weight bold :family "Helvetica Neue")
         markdown-header-face-1 '(:inherit markdown-header-face :height 2.0)
         markdown-header-face-2 '(:inherit markdown-header-face :height 1.6)
         markdown-header-face-3 '(:inherit markdown-header-face :height 1.4)
         markdown-header-face-4 '(:inherit markdown-header-face :height 1.2))))

(eval-after-load 'auto-complete
  '(add-to-list 'ac-modes 'markdown-mode))


(defun markdown-export-docx ()
  (interactive)
  (let* ((parts `(,markdown-command))
         (format "docx")
         (buf (buffer-name))
         (output-file (replace-regexp-in-string
                       (regexp-opt '("\.markdown" "\.md")) (concat "." format) buf)))
    (push (concat "--data-dir=~/cli/data") parts)
    (push (concat "-t " format) parts)
    (push (concat "-o ~/Desktop/" output-file) parts)
    (push (buffer-file-name) parts)
    (when (= 0 (shell-command (mapconcat 'identity (nreverse parts) " ")))
      (message (concat "Wrote " output-file)))))

(provide 'config-markdown)
