(add-to-list 'load-path (concat user-emacs-directory "lib/my"))

(custom-set-variables '(load-prefer-newer t))

(require 'my)

(my-init)
