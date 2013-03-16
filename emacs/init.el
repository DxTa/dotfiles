
(add-to-list 'load-path (expand-file-name "~/.emacs.d"))

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

(require 'cl)
(load "packages")
(load "vendor")
(load "private" 'noerror)
(load "helpers")

(load "appearance")
(load "modeline")

(load "env")
(when (eq system-type 'darwin)
  (load "osx" t))
(when (eq system-type 'gnu/linux)
  (load "linux" t))

(load "behavior")
(load "keys")
(load "programming")
(load "modes")


;; Startup
(setq inhibit-startup-message t)

(defun tung/fortune2scratch ()
  (let ((cookie (shell-command-to-string "fortune -a")))
    (concat
     (replace-regexp-in-string
      " *$" ""
      (replace-regexp-in-string "^" ";; " cookie))
     "\n")))

(setq initial-scratch-message (tung/fortune2scratch))

(add-hook 'emacs-startup-hook
  (lambda ()
    (message "Time needed to load: %s seconds." (emacs-uptime "%s")))
  'append)


;; Server
(require 'server)
(unless (server-running-p)
  (server-start nil))
