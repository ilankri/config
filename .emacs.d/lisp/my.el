(defun my-compile (&optional arg)
  (interactive "P")
  (require 'compile)
  (if arg
      (compile (compilation-read-command compile-command))
    (recompile)))

(defun my-indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

;; Inspired by https://www.emacswiki.org/emacs/TransposeWindows.
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
         (ignore-errors (car (process-lines
                              "opam" "var" "--cli=2.1" "share")))))
    (when (and opam-share (file-directory-p opam-share))
      (expand-file-name "emacs/site-lisp/" opam-share))))

;;; Auxiliary functions
(defun my-user-key (key)
  (let ((user-prefix-key "C-c"))
    (concat user-prefix-key " " key)))

(defun my-define-key (keymap key cmd)
  (define-key keymap (kbd key) cmd))

(defun my-undefine-key (keymap key)
  (my-define-key keymap key nil))

(defun my-define-user-key (keymap key cmd)
  (my-define-key keymap (my-user-key key) cmd))

(defun my-global-set-key (key cmd)
  (global-set-key (kbd (my-user-key key)) cmd))

(defun my-local-set-key (key cmd)
  (local-set-key (kbd (my-user-key key)) cmd))

(defun my-set-prefix-key (prefix key cmd &optional local)
  (let* ((key (concat prefix " " key)))
    (if local (my-local-set-key key cmd) (my-global-set-key key cmd))))

(defconst my-ispell-prefix "o")

(defun my-set-ispell-key (key cmd &optional local)
  (my-set-prefix-key my-ispell-prefix key cmd local))

(defconst my-magit-prefix "g")

(defun my-set-magit-key (key cmd &optional local)
  (my-set-prefix-key my-magit-prefix key cmd local))

(defconst my-lsp-prefix "l")

(defun my-set-lsp-key (key cmd &optional local)
  (my-set-prefix-key my-lsp-prefix key cmd local))

(defun my-add-hook (hook fs)
  (mapc (lambda (f) (add-hook hook f)) fs))

(defun my-add-to-list (l xs)
  (mapc (lambda (x) (add-to-list l x)) xs))

(defun my-add-hooks (hooks f)
  (mapc (lambda (hook) (add-hook hook f)) hooks))

(defun my-prompt-file-for-auto-insert (filename)
  (insert-file-contents
   (concat auto-insert-directory
           (ivy-completing-read "Type: " '("c" "java" "latex" "ocaml") nil t)
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

(defun my-ispell-change-to-fr-dictionary ()
  (interactive)
  (ispell-change-dictionary "fr_FR"))

(defun my-ispell (dict)
  (let ((old-dict (or ispell-local-dictionary ispell-dictionary)))
    (ispell-change-dictionary dict)
    (ispell)
    (ispell-change-dictionary old-dict)))

(defun my-ispell-fr ()
  (interactive)
  (my-ispell "fr_FR"))

(defun my-ispell-en ()
  (interactive)
  (my-ispell "en_US"))

(defun my-try-smerge ()
  (require 'smerge-mode)
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward smerge-begin-re nil t)
      (smerge-mode 1))))

;;; Hook functions
(defun my-c-initialization-hook-f ()
  (custom-set-variables '(c-default-style '((java-mode . "java")
                                            (awk-mode . "awk")
                                            (other . "my-linux")))))

(defun my-tuareg-mode-hook-f ()
  (setq-local comment-style 'indent)
  (setq-local tuareg-interactive-program
              (concat tuareg-interactive-program " -nopromptcont"))
  (let ((ext (file-name-extension buffer-file-name)))
    (when (member ext '("mll" "mly"))
      (electric-indent-local-mode 0)
      (my-undefine-key tuareg-mode-map "|")
      (my-undefine-key tuareg-mode-map ")")
      (my-undefine-key tuareg-mode-map "]")
      (my-undefine-key tuareg-mode-map "}"))
    (when (string-equal ext "mly")
      (setq-local indent-line-function 'ocp-indent-line)
      (setq-local indent-region-function 'ocp-indent-region)))
  (my-undefine-key tuareg-mode-map "C-c C-h")
  (my-undefine-key tuareg-mode-map "M-q")
  (my-define-key tuareg-mode-map "C-c ?" 'caml-help)
  (add-hook 'before-save-hook 'ocamlformat-before-save t t)
  (setq ff-other-file-alist '(("\\.mli\\'" (".ml"))
                              ("\\.ml\\'" (".mli"))
                              ("\\.eliomi\\'" (".eliom"))
                              ("\\.eliom\\'" (".eliomi")))))

(defun my-reason-mode-hook-f ()
  (setq ff-other-file-alist '(("\\.rei\\'" (".re"))
                              ("\\.re\\'" (".rei"))))
  (add-hook 'before-save-hook #'refmt t t))

(defun my-go-mode-hook-f ()
  (add-hook 'before-save-hook 'gofmt nil t))

(defun my-message-mode-hook-f ()
  (setq-local whitespace-action nil)
  (my-set-ispell-key "o" 'ispell-message t))

(defun my-tab ()
  (interactive)
  (insert-char ?\t))

(defun my-csv-mode-hook-f ()
  (setq-local whitespace-style (remove 'lines whitespace-style))
  (setq-local whitespace-action nil)
  (my-define-key csv-mode-map "TAB" 'my-tab))

(defun my-git-grep ()
  (interactive)
  (require 'grep)
  (require 'vc-git)
  (let ((current-prefix-arg '(4)))
    (vc-git-grep (grep-read-regexp) "" (vc-root-dir))))

(defun my-init-package-archives ()
  (require 'package)
  (add-to-list 'package-archives
               '("melpa-stable" . "https://stable.melpa.org/packages/") t)

  ;; Give a higher priority to the GNU ELPA repository.
  (add-to-list 'package-archive-priorities '("gnu" . 1)))

(defun my-init-packages ()
  (my-init-package-archives)
  (package-refresh-contents))

(defun my-kill-current-buffer ()
  (interactive)
  (kill-buffer))

(defun my-ansi-term ()
  (interactive)
  (ansi-term shell-file-name
             (completing-read "Name: " nil nil nil nil nil "localhost")))

(defun my-markdown-mode-hook-f ()
  (add-hook 'before-save-hook 'markdown-cleanup-list-numbers t t))

(provide 'my)
