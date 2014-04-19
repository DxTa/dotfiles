
(td/after 'erc
  (setq erc-modules '(autojoin completion track))
  (erc-update-modules)

  (setq erc-autojoin-channels-alist
        '(("freenode\\.net" . ("#ubuntu-vn" "#emacs" "#clojure" "#reactjs" "#ruby"))))
  (erc-autojoin-mode t)

  (erc-spelling-mode t)
  (erc-fill-mode -1)

  (setq erc-button-url-regexp
        (concat "\\(www\\.\\|\\(s?https?\\|ftp\\|file\\|gopher\\|news\\|telnet\\|wais\\|mailto\\):\\)" ; protocol
                "\\(//[-a-zA-Z0-9_.]+:[0-9]\\)?"  ;
                "[-a-zA-Z0-9_=!?#$@~`%&*+\\/:;.,()]+[-a-zA-Z0-9_=#$@~`%&*+\\/()|]"))

  (setq erc-track-exclude-types
        '("NICK" "JOIN" "LEAVE" "QUIT" "PART"
          "301" "305" "306" "324" "329" "332" "333" "353")
        erc-hide-list '("JOIN" "PART" "QUIT" "NICK"))

  (defun td/erc-color-nick (&optional user channel-data)
    (cl-flet* ((luminance (r g b) (floor (+ (* 0.299 r) (* 0.587 g) (* 0.117 b))))
               (to-hex (r g b) (format "#%02x%02x%02x" r g b))
               (invert (r g b) (list (- 255 r) (- 255 g) (- 255 b)))
               (nick-to-rgb (nick)
                            (let ((hash (sha1 nick)))
                              (list (mod (string-to-number (substring hash 0 13) 16) 256)
                                    (mod (string-to-number (substring hash 13 26) 16) 256)
                                    (mod (string-to-number (substring hash 26 40) 16) 256))))
               (generate-color (nick)
                               (let ((rgb (nick-to-rgb nick)))
                                 (apply #'to-hex
                                        (if (< (apply #'luminance rgb) 85)
                                            (apply #'invert rgb)
                                          rgb)))))
      (when user
        (let ((nick (erc-server-user-nickname user))
              (op (and channel-data (erc-channel-user-op channel-data) "@")))
          (propertize (concat op nick) 'face (list :foreground (generate-color nick)))))))

  (setq erc-nick-uniquifier "_"
        erc-nick "tungd"
        erc-prompt (lambda ()
                     (format "[%s] @ %s>" (erc-current-nick) (erc-default-target)))
        erc-format-nick-function #'td/erc-color-nick)

  (setq erc-insert-timestamp-function #'erc-insert-timestamp-left
        erc-timestamp-format "[%H:%M:%S]"
        erc-timestamp-only-if-changed-flag nil))

(defun td/start-erc ()
  (interactive)
  (if (get-buffer "irc.freenode.net:6667")
      (erc-track-switch-buffer 1)
    (when (y-or-n-p "Start IRC? ")
      (erc :server "irc.freenode.net"
           :port 6667
           :nick "tungd"
           :full-name "Tung Dao"))))

(provide 'td-erc)
