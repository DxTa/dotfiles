
(setq yas-snippet-dirs '("~/.emacs.d/snippets"))
(yas-global-mode t)

(eval-after-load 'yasnippet
  '(progn
     (setq yas-trigger-key "C-o"
           yas-prompt-functions '(yas-popup-isearch-prompt
                                  yas-ido-prompt
                                  yas-completing-prompt))

     (tung/fill-keymap yas-keymap
                       "C-e" #'yas-goto-end-of-active-field
                       "C-a" #'yas-goto-start-of-active-field)))

(defun yas-goto-end-of-active-field ()
  (interactive)
  (let* ((snippet (car (yas--snippets-at-point)))
         (position (yas--field-end (yas--snippet-active-field snippet))))
    (if (= (point) position)
        (move-end-of-line nil)
      (goto-char position))))

(defun yas-goto-start-of-active-field ()
  (interactive)
  (let* ((snippet (car (yas--snippets-at-point)))
         (position (yas--field-start (yas--snippet-active-field snippet))))
    (if (= (point) position)
        (move-beginning-of-line nil)
      (goto-char position))))

(defun yas-popup-isearch-prompt (prompt choices &optional display-fn)
  (unless (featurep 'popup)
    (require 'popup))
  (popup-menu*
   (mapcar (lambda (choice)
             (popup-make-item
              (or (and display-fn (funcall display-fn choice))
                  choice)
              :value choice))
           choices)
   :prompt prompt
   :isearch t))

(defun yas-region-to-snippet (begin end)
  (interactive "r")
  (let ((region (buffer-substring begin end)))
    (yas-new-snippet)
    (save-excursion
      (goto-char (point-max))
      (insert region))))

;;; Functions used in snippet transformation
(defun snippet/find-js-modules (text)
  (mapconcat #'file-name-nondirectory
             (split-string text "[ \f\t\n\r\v,\"]" t)
             ", "))


(provide 'config-yasnippet)
