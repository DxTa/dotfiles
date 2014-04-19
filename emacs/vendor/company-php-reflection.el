
(require 'company)

(defvar company-php--builtin-symbols nil)

(defun company-php--exec (cmd)
  (split-string
   (shell-command-to-string
    (format "php -r 'echo implode(\";\", %s);'" cmd))
   ";" t))

(defun company-php--get-builtin-symbols ()
  (or company-php--builtin-symbols
      (setq company-php--builtin-symbols
            (append
             (company-php--exec "get_defined_functions()[\"internal\"]")
             (company-php--exec "get_declared_classes()")
             (company-php--exec "array_keys(get_defined_constants())")))))

(defun company-php--get-meta (fn)
  (let ((args
         (company-php--exec
          (format "
array_map(function ($p) {
  if ($p->isPassedByReference()) return \"&$\". $p->getName();
  if ($p->isOptional()) return \"[$\". $p->getName() .\"]\";
  return \"$\". $p->name;
},(new ReflectionFunction(\"%s\"))->getParameters())
" fn))))
    (format "%s: (%s)"
            (propertize fn 'face 'font-lock-function-name-face)
            (s-join " " args))))

;;;###autoload
(defun company-php-eldoc ()
  (let* ((fn (thing-at-point 'symbol))
         (test (format "php -r 'echo function_exists(\"%s\");'" fn)))
    (when (string= "1" (shell-command-to-string test))
      (company-php--get-meta fn))))

;;;###autoload
(defun company-php-reflection (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-php-reflection))
    (prefix (and (eq major-mode 'php-mode)
                 (company-grab-symbol)))
    (candidates (all-completions
                 arg
                 (company-php--get-builtin-symbols)))
    (meta (company-php--get-meta arg))))

(provide 'company-php-reflection)
