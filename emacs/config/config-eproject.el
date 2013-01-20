(require 'eproject)
(require 'eproject-extras)

(eval-after-load 'eproject
  '(progn
     (setq eproject-completing-read-function
           'eproject--ido-completing-read)

     (define-project-type generic-scm (generic-git generic-hg)
       (or (look-for ".git") (look-for ".hg"))
       :irrelevant-files (".DS_Store" "tmp/" "log/" "logs/" "vendor/" "elpa/"))

     (define-project-type php (generic-scm)
       (or (look-for "composer") (look-for "composer.phar")
           (look-for "composer.json")))

     (define-project-type ruby (generic-scm)
       (or (look-for "Gemfile")
           (look-for "Rakefile")
           (look-for "config.ru"))
       :irrelevant-files '("coverage/" "doc/" "docs/" ".rbenv-version"))

     (define-project-type node-js (generic-scm)
       (or (look-for "package.json") (look-for "node_modules")
           (look-for "Cakefile"))
       :irrelevant-files '("node_modules/"))

     (define-project-type clojure (generic-scm)
       (look-for "project.clj")
       :irrelevant-files '(".class" ".jar"))


     (defun eproject-ack (pattern)
       (interactive "sAck pattern: ")
       (let* ((root (eproject-root))
              (default-directory root)
              (files (eproject-list-project-files-relative root)))
         (ack-and-a-half pattern t default-directory)))

     (defmacro ffa-finder (prefix prompt)
       `(lambda ()
          (interactive)
          (find-file (ido-completing-read
                      ,prompt
                      (mapcar #'eproject--shorten-filename
                              (eproject-list-project-files))
                      nil t
                      ,prefix))))

     (define-prefix-command 'tung/project-map)
     (tung/fill-keymap tung/project-map
                       "g" #'eproject-ack
                       "a" #'eproject-ack
                       "m" (ffa-finder "app/models/" "Model: ")
                       "c" (ffa-finder "app/controllers/" "Controller: ")
                       "v" (ffa-finder "app/views/" "View: ")
                       "t" (ffa-finder "spec/" "Spec: ")
                       "h" (ffa-finder "app/helpers/" "Helper: ")
                       "j" (ffa-finder "app/assets/javascripts/" "JS: ")
                       "s" (ffa-finder "app/assets/stylesheets/" "CSS: "))
     (global-set-key (kbd "C-c p") 'tung/project-map)

     ;; (defadvice ido-find-file
     ;;   (around tung/eproject-find-file activate)
     ;;   (if (eproject-root)
     ;;       (eproject-find-file)
     ;;     ad-do-it))

     ))

(provide 'config-eproject)
