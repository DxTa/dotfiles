
(require 'ido)

(defun ido-sort-mtime--sort (a b)
  (let ((a-tramp-file-p (string-match-p ":\\'" a))
        (b-tramp-file-p (string-match-p ":\\'" b)))
    (cond
     ((and a-tramp-file-p b-tramp-file-p)
      (string< a b))
     (a-tramp-file-p nil)
     (b-tramp-file-p t)
     (t (time-less-p
         (nth 5 (file-attributes (concat ido-current-directory b)))
         (nth 5 (file-attributes (concat ido-current-directory a))))))))

(defun ido-sort-mtime--dot-filep (f)
  (and (char-equal (string-to-char f) ?.) f))

(defun ido-sort-mtime ()
  (setq ido-temp-list
        (sort ido-temp-list #'ido-sort-mtime--sort))
  (ido-to-end  ;; move . files to end (again)
   (delq nil (mapcar #'ido-sort-mtime--dot-filep ido-temp-list))))

(add-hook 'ido-make-file-list-hook #'ido-sort-mtime)
(add-hook 'ido-make-dir-list-hook #'ido-sort-mtime)

(provide 'ido-sort-mtime)
