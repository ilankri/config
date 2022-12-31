(add-to-list 'load-path (concat user-emacs-directory "lisp"))

(custom-set-variables '(load-prefer-newer t))

(require 'my)

(my-init)
