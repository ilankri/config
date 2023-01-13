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

(defconst my-eglot-prefix "l")

(defun my-set-eglot-key (key cmd &optional local)
  (my-set-prefix-key my-eglot-prefix key cmd local))

(defun my-add-hook (hook fs)
  (mapc (lambda (f) (add-hook hook f)) fs))

(defun my-add-to-list (l xs)
  (mapc (lambda (x) (add-to-list l x)) xs))

(defun my-add-hooks (hooks f)
  (mapc (lambda (hook) (add-hook hook f)) hooks))

(defun my-prompt-file-for-auto-insert (filename)
  (insert-file-contents
   (concat auto-insert-directory
           (completing-read "Type: " '("c" "java" "latex" "ocaml") nil t)
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
  (setq ff-other-file-alist '(("\\.mli\\'" (".ml"))
                              ("\\.ml\\'" (".mli"))
                              ("\\.eliomi\\'" (".eliom"))
                              ("\\.eliom\\'" (".eliomi")))))

(defun my-reason-mode-hook-f ()
  (setq ff-other-file-alist '(("\\.rei\\'" (".re"))
                              ("\\.re\\'" (".rei")))))

(defun my-scala-mode-hook-f ()
  (setq-local indent-line-function 'indent-relative)
  (remove-hook 'post-self-insert-hook
               'scala-indent:indent-on-special-words t)
  ;; Hacks for Scala 3

  (my-c-trad-comment-on))

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
               '("melpa-stable" . "https://stable.melpa.org/packages/") t))

(defun my-init-packages ()
  (my-init-package-archives)
  (package-refresh-contents))

(defun my-kill-current-buffer ()
  (interactive)
  (kill-buffer))

(defun my-ansi-term ()
  (interactive)
  (ansi-term (getenv "ESHELL")
             (completing-read "Name: " nil nil nil nil nil "localhost")))

(defun my-markdown-mode-hook-f ()
  (add-hook 'before-save-hook 'markdown-cleanup-list-numbers t t))

(defun my-init ()
  (my-init-package-archives)

  (custom-set-variables '(package-selected-packages '(magit
                                                      reason-mode
                                                      debian-el
                                                      csv-mode
                                                      rust-mode
                                                      go-mode
                                                      markdown-mode
                                                      scala-mode
                                                      gnu-elpa-keyring-update
                                                      eglot
                                                      yaml-mode
                                                      tuareg
                                                      ocp-indent
                                                      dune
                                                      dockerfile-mode
                                                      auctex)))

  (package-initialize)

  ;; Ensure that packages are installed.
  (package-install-selected-packages)

  ;; APT
  (require 'apt-sources)           ; To force update of `auto-mode-alist'.

  (require 'ocp-indent)

  (require 'dune)

  ;; Eglot
  (defun my-eglot-format-buffer-before-save ()
    (defun my-eglot-maybe-format-buffer ()
      (when (eglot-managed-p) (eglot-format-buffer)))
    (add-hook 'before-save-hook 'my-eglot-maybe-format-buffer t t))

  (my-add-hook 'prog-mode-hook
               '(eglot-ensure my-eglot-format-buffer-before-save))

  (custom-set-variables
   '(eglot-autoshutdown t)
   '(eglot-ignored-server-capabilities '(:documentHighlightProvider)))

  (setq eglot-stay-out-of '(flymake))

  ;; Ispell

  ;; Use hunspell instead of aspell because hunspell has a better French
  ;; support.
  (custom-set-variables '(ispell-program-name "hunspell"))

  (add-hook 'text-mode-hook 'flyspell-mode)

  ;; Switch to French dictionary when writing mails or LaTeX files.
  (my-add-hooks '(message-mode-hook LaTeX-mode-hook)
                'my-ispell-change-to-fr-dictionary)

  ;; Filling
  (custom-set-variables '(fill-column 72))

  (custom-set-variables '(comment-multi-line t))

  (add-to-list 'fill-nobreak-predicate 'fill-french-nobreak-p)

  ;; auto-fill-mode is only enabled in CC mode (and not in all program
  ;; modes) because it seems to be the only program mode that properly
  ;; deals with auto-fill.
  (my-add-hooks '(text-mode-hook c-mode-common-hook) 'auto-fill-mode)

  ;; Mail
  (custom-set-variables
   '(mail-header-separator
     "-=-=-=-=-=-=-=-=-=# Don't remove this line #=-=-=-=-=-=-=-=-=-"))

  ;; Whitespace
  (global-whitespace-mode 1)

  ;; Do not display spaces, tabs and newlines marks.
  (custom-set-variables
   '(whitespace-style (cl-set-difference whitespace-style '(tabs
                                                            spaces
                                                            newline
                                                            space-mark
                                                            tab-mark
                                                            newline-mark)))
   '(whitespace-action '(auto-cleanup)))

  ;; Turn off whitespace-mode in Dired-like buffers.
  (custom-set-variables
   '(whitespace-global-modes '(not dired-mode archive-mode git-rebase-mode)))

  ;; Auto-Revert
  (global-auto-revert-mode 1)

  ;; Compilation
  (custom-set-variables '(compilation-scroll-output 'first-error)
                        '(compilation-context-lines 0))

  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

  (defun my-scala3-end-column ()
    (+ (string-to-number (match-string 3)) 1))

  (defconst my-scala-compilation-error-regexp-matchers
    '(("^\\[error\\] \\(.+\\):\\([0-9]+\\):\\([0-9]+\\):" 1 2 3 2)
      ("^\\[warn\\] \\(.+\\):\\([0-9]+\\):\\([0-9]+\\):" 1 2 3 1)
      ;; sbt with Scala 2

      (".*Error: \\(.+\\):\\([0-9]+\\):\\([0-9]+\\)" 1 2 my-scala3-end-column 2)
      (".*Warning: \\(.+\\):\\([0-9]+\\):\\([0-9]+\\)"
       1 2 my-scala3-end-column 1)
      ;; Scala 3
      ))

  (require 'compile)

  (my-add-to-list 'compilation-error-regexp-alist
                  my-scala-compilation-error-regexp-matchers)

  ;; Ffap
  (custom-set-variables '(ffap-machine-p-known 'reject))

  ;; Auto-insert

  ;; This skeleton is like the one provided by default, except that we add
  ;; an appropriate comment after the #endif.
  (define-auto-insert '("\\.\\([Hh]\\|hh\\|hpp\\)\\'" . "C / C++ guard macro")
    '((upcase (concat (file-name-nondirectory
                       (file-name-sans-extension buffer-file-name))
                      "_"
                      (file-name-extension buffer-file-name)))
      "#ifndef " str "\n#define " str "\n\n" _ "\n\n#endif /* not " str
      " */\n"))

  ;; This skeleton is like the one provided by default, except that it
  ;; does the inclusion for .hpp file too.
  (define-auto-insert '("\\.\\([Cc]\\|cc\\|cpp\\)\\'" . "C / C++ source")
    '(nil "#include \""
          (let
              ((stem
                (file-name-sans-extension buffer-file-name)))
            (cond
             ((file-exists-p
               (concat stem ".h"))
              (file-name-nondirectory
               (concat stem ".h")))
             ((file-exists-p
               (concat stem ".hh"))
              (file-name-nondirectory
               (concat stem ".hh")))
             ((file-exists-p
               (concat stem ".hpp"))
              (file-name-nondirectory
               (concat stem ".hpp")))))
          & 34 | -10))

  ;; Prompt the user for the appropriate Makefile type to insert.
  (define-auto-insert '("[Mm]akefile\\'" . "Makefile") 'my-makefile-auto-insert)

  (define-auto-insert '(".gitignore\\'" . ".gitignore file")
    'my-gitignore-auto-insert)

  (define-auto-insert '(".ocp-indent\\'" . ".ocp-indent file")
    'my-ocp-indent-auto-insert)

  (custom-set-variables
   '(auto-insert-directory (my-prefix-by-user-emacs-directory "insert/")))
  (auto-insert-mode 1)

  ;; Semantic
  (my-add-to-list
   'semantic-default-submodes
   '(global-semantic-stickyfunc-mode global-semantic-mru-bookmark-mode))

  (semantic-mode 1)

  ;; CC mode
  (c-add-style "my-linux" '("linux" (indent-tabs-mode . t)))

  (add-hook 'c-initialization-hook 'my-c-initialization-hook-f)

  ;; In java-mode and c++-mode, we use C style comments and not
  ;; single-line comments.
  (my-add-hooks '(java-mode-hook c++-mode-hook) 'my-c-trad-comment-on)

  ;; Tuareg
  (custom-set-variables '(tuareg-interactive-read-only-input t))

  (add-hook 'tuareg-mode-hook 'my-tuareg-mode-hook-f)

  ;; Reason
  (add-hook 'reason-mode-hook 'my-reason-mode-hook-f)

  ;; Scala
  (custom-set-variables '(scala-indent:default-run-on-strategy 1))

  (add-hook 'scala-mode-hook 'my-scala-mode-hook-f)

  ;; Proof general
  (custom-set-variables '(proof-splash-enable nil)
                        '(proof-three-window-mode-policy 'hybrid)
                        '(coq-one-command-per-line nil))

  ;; Asm
  (custom-set-variables '(asm-comment-char ?#))

  ;; LaTeX
  (custom-set-variables '(TeX-auto-save t)
                        '(TeX-parse-self t)
                        '(LaTeX-section-hook '(LaTeX-section-heading
                                               LaTeX-section-title
                                               LaTeX-section-toc
                                               LaTeX-section-section
                                               LaTeX-section-label))
                        '(reftex-plug-into-AUCTeX t)
                        '(reftex-enable-partial-scans t)
                        '(reftex-save-parse-info t)
                        '(reftex-use-multiple-selection-buffers t)
                        '(TeX-electric-math (cons "$" "$"))
                        '(TeX-electric-sub-and-superscript t)
                        '(font-latex-fontify-script 'multi-level))

  (custom-set-variables '(TeX-master nil))

  (my-add-hook 'LaTeX-mode-hook
               '(TeX-PDF-mode LaTeX-math-mode TeX-source-correlate-mode
                              reftex-mode))

  ;; Magit
  (require 'magit)

  (custom-set-variables '(git-commit-summary-max-length fill-column)
                        '(magit-diff-refine-hunk t))

  ;; Markdown
  (custom-set-variables '(markdown-command "pandoc")
                        '(markdown-asymmetric-header t)
                        '(markdown-fontify-code-blocks-natively t))

  (add-hook 'markdown-mode-hook 'my-markdown-mode-hook-f)

  ;; Miscellaneous settings
  (setq disabled-command-function nil)

  (custom-set-variables '(inhibit-startup-screen t)
                        '(custom-file
                          (my-prefix-by-user-emacs-directory ".custom.el"))
                        '(auto-mode-case-fold nil)
                        '(track-eol t)
                        '(completions-format 'one-column)
                        '(enable-recursive-minibuffers t)
                        '(view-read-only t)
                        '(eldoc-echo-area-use-multiline-p nil)
                        '(comint-prompt-read-only t)
                        '(term-buffer-maximum-size 0)
                        '(vc-follow-symlinks t)
                        '(vc-command-messages t)
                        '(require-final-newline t)
                        '(scroll-up-aggressively 0)
                        '(scroll-down-aggressively 0)
                        '(indent-tabs-mode nil))

  (my-add-to-list 'completion-ignored-extensions
                  '("auto/" ".prv/" "_build/" "_opam/" "target/"
                    "_client/" "_deps/" "_server/" ".sass-cache/"
                    ".d" ".native" ".byte" ".bc" ".exe" ".pdf"
                    ".out" ".fls" ".synctex.gz" ".rel" ".unq" ".tns"
                    ".emacs.desktop" ".emacs.desktop.lock" "_region_.tex"))

  ;; Hack to open files like Makefile.local or Dockerfile.test with the
  ;; right mode.
  (add-to-list 'auto-mode-alist '("\\.[^\\.].*\\'" nil t) t)

  (my-add-to-list 'auto-mode-alist
                  '(("README\\'" . text-mode)
                    ("dune-project\\'" . dune-mode)
                    ("dune-workspace\\'" . dune-mode)
                    ("bash-fc\\'" . sh-mode)
                    ("\\.bash_aliases\\'" . sh-mode)
                    ("\\.gitignore\\'" . conf-unix-mode)
                    ("\\.dockerignore\\'" . conf-unix-mode)
                    ("\\.ml[ly]\\'" . tuareg-mode)
                    ("\\.top\\'" . tuareg-mode)
                    ("\\.ocamlinit\\'" . tuareg-mode)
                    ("\\.ocp-indent\\'" . conf-unix-mode)
                    ("_tags\\'" . conf-colon-mode)
                    ("_log\\'" . conf-unix-mode)
                    ("\\.merlin\\'" . conf-space-mode)
                    ("\\.mrconfig\\'" . conf-unix-mode)
                    ("\\.eml\\'" . message-mode)))

  (tool-bar-mode 0)

  (menu-bar-mode 0)

  (scroll-bar-mode 0)

  (toggle-frame-fullscreen)

  (column-number-mode 1)

  (global-subword-mode 1)

  (delete-selection-mode 1)

  (electric-indent-mode 1)

  (electric-pair-mode 1)

  (show-paren-mode 1)

  (savehist-mode 1)

  (winner-mode 1)

  (fido-vertical-mode 1)

  (minibuffer-depth-indicate-mode 1)

  ;; Custom global key bindings
  (my-global-set-key "a" 'ff-get-other-file)

  (my-global-set-key "b" 'windmove-left)

  (my-global-set-key "c" 'my-compile)

  (my-global-set-key "f" 'windmove-right)

  (global-set-key (kbd "C-x g") 'magit-status)

  (global-set-key (kbd "C-x M-g") 'magit-dispatch-popup)

  (my-set-magit-key "f" 'magit-find-file)

  (my-set-magit-key "4 f" 'magit-find-file-other-window)

  (my-global-set-key "h" 'man)

  (my-global-set-key "i" 'my-indent-buffer)

  (my-global-set-key "j" 'browse-url)

  (my-global-set-key "k" 'my-kill-current-buffer)

  (my-set-eglot-key "a" 'eglot-code-actions)

  (my-set-eglot-key "r" 'eglot-rename)

  (my-global-set-key "m" 'imenu)

  (my-global-set-key "n" 'windmove-down)

  (my-set-ispell-key "c" 'ispell-comments-and-strings)

  (my-set-ispell-key "d" 'ispell-change-dictionary)

  (my-set-ispell-key "e" 'my-ispell-en)

  (my-set-ispell-key "f" 'my-ispell-fr)

  (my-set-ispell-key "o" 'ispell)

  (my-global-set-key "p" 'windmove-up)

  (my-global-set-key "s" 'my-git-grep)

  (my-global-set-key "t" 'my-transpose-windows)

  (my-global-set-key "u" 'winner-undo)

  (my-global-set-key "x" 'switch-to-completions)

  (my-global-set-key "v" 'my-ansi-term)

  (my-global-set-key "w" 'whitespace-cleanup)

  (my-global-set-key "y" 'blink-matching-open)

  ;; Enable smerge-mode when necessary.
  (add-hook 'find-file-hook 'my-try-smerge t)

  (add-hook 'conf-mode-hook 'my-indent-tabs-mode-on)

  (add-hook 'message-mode-hook 'my-message-mode-hook-f)

  (add-hook 'csv-mode-hook 'my-csv-mode-hook-f)

  (load-theme 'modus-operandi)

  ;; Emacs server
  (server-start))

(provide 'my)
