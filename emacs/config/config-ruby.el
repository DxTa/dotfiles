
(tung/add-auto-mode 'ruby-mode
                    '("\\.rb$"
                      "Rakefile$" "Guardfile$" "Gemfile$" "Vagrantfile$"
                      "\\.ru$" "\\.rake$" "\\.gemspec$"))

(defun tung/setup-ruby-mode ()
  (interactive)
  (setq ruby-deep-arglist nil
        ruby-deep-indent-paren nil)
  (tung/setup-programming-environment))

(add-hook 'ruby-mode-hook #'tung/setup-ruby-mode)
(add-hook 'html-erb-mode-hook #'tung/setup-ruby-mode)

(eval-after-load 'surround
  '(add-hook 'ruby-mode-hook
             (lambda ()
               (push '(?= . ("<%= " . " %>")) surround-pairs-alist)
               (push '(?- . ("<% " . " %>")) surround-pairs-alist)
               (push '(?# . ("#{" . "}")) surround-pairs-alist))))


(eval-after-load 'hs-minor-mode
  '(add-to-list 'hs-special-modes-alist
                '(ruby-mode
                  "\\(def\\|do\\|{\\)" "\\(end\\|end\\|}\\)" "#"
                  (lambda (arg) (ruby-end-of-block)) nil)))


(provide 'config-ruby)
