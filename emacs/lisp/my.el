(defun my-compile (&optional arg)
  (interactive "P")
  (require 'compile)
  (if arg
      (compile (compilation-read-command compile-command))
    (recompile)))

(defun my-indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun my-transpose-windows (count)
  (interactive "p")
  (let* ((ws (window-list))
         (w1 (car ws))
         (w1buf (window-buffer w1))
         (w1start (window-start w1))
         (w1pt (window-point w1))
         (w2 (nth (mod count (count-windows)) ws))
         (w2buf (window-buffer w2))
         (w2start (window-start w2))
         (w2pt (window-point w2)))
    (set-window-buffer-start-and-point w1 w2buf w2start w2pt)
    (set-window-buffer-start-and-point w2 w1buf w1start w1pt)))

(defun my-indent-tabs-mode-on ()
  (setq indent-tabs-mode t))

(defun my-prefix-by-user-emacs-directory (file)
  (concat user-emacs-directory file))

;;; OPAM

;; Directory name (depends on the active OPAM switch when Emacs was
;; started) where OPAM stores Emacs Lisp files.

(defconst my-opam-lisp-dir
  (let ((opam-share
         (ignore-errors (car (process-lines "opam" "config" "var" "share")))))
    (when (and opam-share (file-directory-p opam-share))
      ;; Register Merlin
      (expand-file-name "emacs/site-lisp/" opam-share))))

;;; Auxiliary functions
(defun my-user-key (key)
  (let ((user-prefix-key "C-c"))
    (kbd (concat user-prefix-key " " key))))

(defun my-define-key (keymap key cmd)
  (define-key keymap (kbd key) cmd))

(defun my-undefine-key (keymap key)
  (my-define-key keymap key nil))

(defun my-define-user-key (keymap key cmd)
  (my-define-key keymap (my-user-key key) cmd))

(defun my-global-set-key (key cmd)
  (global-set-key (my-user-key key) cmd))

(defun my-local-set-key (key cmd)
  (local-set-key (my-user-key key) cmd))

(defun my-set-spelling-key (key cmd &optional local)
  (let* ((spelling-prefix-key "s")
         (key (concat spelling-prefix-key " " key)))
    (if local (my-local-set-key key cmd) (my-global-set-key key cmd))))

(defun my-add-hook (hook fs)
  (mapc (lambda (f) (add-hook hook f)) fs))

(defun my-add-to-list (l xs)
  (mapc (lambda (x) (add-to-list l x)) xs))

(defun my-add-hooks (hooks f)
  (mapc (lambda (hook) (add-hook hook f)) hooks))

(defun my-prompt-file-for-auto-insert (filename)
  (insert-file-contents
   (concat auto-insert-directory
           (ido-completing-read "Type: " '("c" "java" "latex" "ocaml") nil t)
           "/" filename)))

(defun my-makefile-auto-insert ()
  (my-prompt-file-for-auto-insert "Makefile"))

(defun my-gitignore-auto-insert ()
  (my-prompt-file-for-auto-insert "gitignore"))

(defun my-ocp-indent-auto-insert ()
  (insert-file-contents "~/.ocp/ocp-indent.conf"))

(defun my-c-trad-comment-on ()
  (setq-local comment-start "/* ")
  (setq-local comment-end " */"))

(defun my-flyspell-fr-on ()
  (ispell-change-dictionary "fr_FR")
  (flyspell-mode 1))

(defun my-try-smerge ()
  (require 'smerge-mode)
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward smerge-begin-re nil t)
      (smerge-mode 1))))

(defun my-bbdb-initialize ()
  (bbdb-initialize 'gnus 'message)
  ;; Update BBDB only when sending mails.
  (bbdb-mua-auto-update-init 'message))

;;; Hook functions
(defun my-after-init-hook-f ()
  (setq smtpmail-smtp-user user-mail-address))

(defun my-c-initialization-hook-f ()
  (setq c-default-style '((java-mode . "java")
                          (awk-mode . "awk")
                          (other . "my-linux"))))

(defun my-tuareg-mode-hook-f ()
  (setq-local tuareg-interactive-program
              (concat tuareg-interactive-program " -nopromptcont"))
  (let ((ext (file-name-extension buffer-file-name)))
    (when (member ext '("mll" "mly"))
      (electric-indent-local-mode 0))
    (when (string-equal ext "mly")
      (setq-local indent-line-function 'ocp-indent-line)
      (setq-local indent-region-function 'ocp-indent-region)))
  (my-undefine-key tuareg-mode-map "C-c C-h")
  (my-local-set-key "h" 'caml-help)
  (my-local-set-key "l" 'ocaml-add-path)
  (my-local-set-key "a" 'tuareg-find-alternate-file))

(defun my-merlin-mode-hook-f ()
  (my-undefine-key merlin-mode-map "C-c C-r")
  (my-local-set-key "o" 'merlin-switch-to-mli))

(defun my-scala-mode-hook-f ()
  (setq scala-indent:default-run-on-strategy 1))

(defun my-LaTeX-mode-hook-f ()
  (add-to-list 'TeX-style-path "/usr/share/doc/texlive-doc/latex/curve/"))

(defun my-message-mode-hook-f ()
  (my-set-spelling-key "s" 'ispell-message t))

(provide 'my)
