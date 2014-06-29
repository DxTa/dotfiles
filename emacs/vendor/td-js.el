
(defadvice js--proper-indentation (after js-my-indentation activate)
  ;; Leading comma style
  ;; (save-excursion
  ;;   (back-to-indentation)
  ;;   (if (looking-at ",")
  ;;       (re-search-backward js--declaration-keyword-re (point-min) t)
  ;;       (setq ad-return-value
  ;;             (+ (current-column) js-expr-indent-offset))))
  ;; Bracket related
  (when (nth 1 parse-status)
    (save-excursion
      (let ((continued-expr-p (js--continued-expression-p)))
        (goto-char (nth 1 parse-status))
        (if (looking-at "[({[]\\s-*\\(/[/*]\\|$\\)")
            ;; Continued expression
            (when continued-expr-p
              (skip-syntax-backward " ")
              (when (eq (char-before) ?\)) (backward-list))
              (back-to-indentation)
              (setq ad-return-value
                    (+ (current-column) js-indent-level js-expr-indent-offset)))
          ;; argslist-cont
          (setq ad-return-value
                (+ js-indent-level js-expr-indent-offset)))))))

(provide 'td-js)