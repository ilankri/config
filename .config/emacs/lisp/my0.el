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

(defun my-prefix-by-user-emacs-directory (file)
  (concat user-emacs-directory file))

;;; Auxiliary functions
(defun my-prompt-file-for-auto-insert (filename)
  (insert-file-contents
   (concat auto-insert-directory
           (completing-read "Type: " '("c" "java" "latex" "ocaml") nil t)
           "/" filename)))

(defun my-makefile-auto-insert ()
  (my-prompt-file-for-auto-insert "Makefile"))

(defun my-gitignore-auto-insert ()
  (my-prompt-file-for-auto-insert "gitignore"))

(defun my-c-trad-comment-on ()
  (setq-local comment-start "/* ")
  (setq-local comment-end " */"))

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

;;; Hook functions
(defun my-tuareg-mode-hook-f ()
  (setq-local comment-style 'indent)
  (setq-local tuareg-interactive-program
              (concat tuareg-interactive-program " -nopromptcont"))
  (let ((ext (file-name-extension buffer-file-name)))
    (when (member ext '("mll" "mly"))
      (electric-indent-local-mode 0)))
  (local-unset-key (kbd "C-c C-h"))
  (local-set-key (kbd "C-c ?") 'caml-help))

(defun my-reason-mode-hook-f ()
  (setq ff-other-file-alist '(("\\.rei\\'" (".re"))
                              ("\\.re\\'" (".rei")))))

(defun my-git-grep ()
  (interactive)
  (require 'grep)
  (require 'vc-git)
  (let ((current-prefix-arg '(4)))
    (vc-git-grep (grep-read-regexp) "" (vc-root-dir))))

(defun my-kill-current-buffer ()
  (interactive)
  (kill-buffer))

(defun my-init ()
  (require 'debian-el)

  ;; Tuareg
  (custom-set-variables '(tuareg-interactive-read-only-input t))

  (add-hook 'tuareg-mode-hook 'my-tuareg-mode-hook-f)

  ;; Reason
  (add-hook 'reason-mode-hook 'my-reason-mode-hook-f))

(provide 'my0)
