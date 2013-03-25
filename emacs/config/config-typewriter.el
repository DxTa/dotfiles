
(defvar play-typewriter-sound-enabled nil)

(defun play-typewriter-sound ()
  (let ((sound-file "~/cli/linux/typewriter-key.wav")
        (play-sound-command (cond ((eq system-type 'darwin) "play")
                                  ((eq system-type 'gnu/linux) "aplay"))))
    (start-process-shell-command
     "play-typewriter-sound" nil
     (format "%s %s" play-sound-command sound-file))))

(defun toggle-typewriter-sound (&optional enable)
  (interactive)
  (let* ((state (not (if enable t play-typewriter-sound-enabled)))
         (command (if state 'remove-hook 'add-hook)))
    (funcall command 'post-self-insert-hook #'play-typewriter-sound)
    (setq play-typewriter-sound-enabled state)))

;; (toggle-typewriter-sound t)

(eval-after-load 'evil
  '(progn
     (add-hook 'evil-insert-state-entry-hook (lambda () (toggle-typewriter-sound t)))
     (add-hook 'evil-insert-state-exit-hook (lambda () (toggle-typewriter-sound nil)))))

(provide 'config-typewriter)
