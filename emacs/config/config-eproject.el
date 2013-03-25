
(require 'eproject)
(require 'eproject-extras)

(eval-after-load 'eproject
  '(progn
     (setq eproject-completing-read-function
           'eproject--ido-completing-read)

     (define-key eproject-mode-map (kbd "C-c b") nil)

     ;; (require 'eproject-tags)

     (require 'eproject-tasks)
     (define-key eproject-mode-map (kbd "C-c C-t") #'eproject-tasks-run)

     (require 'eproject-clojure-leiningen)
     (require 'eproject-javascript-npm)
     (require 'eproject-php-composer)
     (require 'eproject-ruby)
     (require 'eproject-ruby-on-rails)

     (define-project-type gradle (generic)
       (look-for "build.gradle")
       :irrelevant-files ("build/"))

     (defun eproject-ack (pattern)
       (interactive "sAck pattern: ")
       (let* ((root (eproject-root))
              (default-directory root)
              (files (eproject-list-project-files-relative root)))
         (ack-and-a-half pattern t default-directory)))


     (defmacro eproject-finder (prefix prompt)
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
                       "m" (eproject-finder "app/models/" "Model: ")
                       "c" (eproject-finder "app/controllers/" "Controller: ")
                       "v" (eproject-finder "app/views/" "View: ")
                       "t" (eproject-finder "spec/" "Spec: ")
                       "h" (eproject-finder "app/helpers/" "Helper: ")
                       "j" (eproject-finder "app/assets/javascripts/" "JS: ")
                       "s" (eproject-finder "app/assets/stylesheets/" "CSS: "))
     (global-set-key (kbd "C-c p") 'tung/project-map)
     ;; (define-key eproject-mode-map (kbd "C-c p") #'eproject-tasks-run)
     ))


(provide 'config-eproject)
