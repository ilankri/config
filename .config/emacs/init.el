(add-to-list 'load-path (concat user-emacs-directory "lib"))

(custom-set-variables '(load-prefer-newer t))

(require 'my)

(my-init)
