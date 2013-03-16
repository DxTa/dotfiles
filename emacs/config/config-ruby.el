
(tung/add-auto-mode 'ruby-mode
                    '("\\.rb$"
                      "Rakefile$" "Guardfile$" "Gemfile$" "Vagrantfile$"
                      "\\.ru$" "\\.rake$" "\\.gemspec$"))

(add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))

(defun tung/setup-ruby-mode ()
  (interactive)
  (tung/setup-programming-environment)
  (push '(?= . ("<%= " . " %>")) surround-pairs-alist)
  (push '(?- . ("<% " . " %>")) surround-pairs-alist)
  (push '(?# . ("#{" . "}")) surround-pairs-alist))

(add-hook 'ruby-mode-hook #'tung/setup-ruby-mode)
(add-hook 'html-erb-mode-hook #'tung/setup-ruby-mode)

(eval-after-load 'hs-minor-mode
  '(add-to-list 'hs-special-modes-alist
                '(ruby-mode
                  "\\(def\\|do\\|{\\)" "\\(end\\|end\\|}\\)" "#"
                  (lambda (arg) (ruby-end-of-block)) nil)))


(provide 'config-ruby)
