
(defun tung/add-to-path (paths)
  (dolist (path paths)
    (push (expand-file-name path) exec-path)
    (setenv "PATH" (concat (expand-file-name path) ":" (getenv "PATH")))))

;; System
(tung/add-to-path '("/usr/local/bin"
                    "/Applications/Xcode.app/Contents/Developer/usr/bin"))

;; Homebrew
(tung/add-to-path '("~/local/bin"
                    "~/local/share/npm/bin"))

;; User
(tung/add-to-path '("~/cli/bin"))
