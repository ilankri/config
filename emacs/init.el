(require 'package)

(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (ensime company auctex))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(add-to-list 'load-path (concat user-emacs-directory "lisp"))

(require 'my)

;;; OPAM
(add-to-list 'load-path my-opam-lisp-dir)

(load (concat my-opam-lisp-dir "tuareg-site-file"))

(require 'ocp-indent)

(require 'merlin)

;;; Ispell

;; Use hunspell instead of aspell because hunspell has a better French
;; support.
(setq ispell-program-name "hunspell")

(add-hook 'text-mode-hook 'flyspell-mode)

;; Switch to French dictionary when writing mails or LaTeX files.
(my-add-hooks '(message-setup-hook LaTeX-mode-hook) 'my-flyspell-fr-on)

;;; Filling
(setq-default fill-column 72)

(setq comment-multi-line t)

(add-to-list 'fill-nobreak-predicate 'fill-french-nobreak-p)

;; auto-fill-mode is only enabled in CC mode (and not in all program
;; modes) because it seems to be the only program mode that properly
;; deals with auto-fill.
(my-add-hooks '(text-mode-hook c-mode-common-hook) 'auto-fill-mode)

;;; Mail
(setq mail-user-agent 'gnus-user-agent
      message-directory "~/.mail/"
      gnus-directory "~/.news/"
      gnus-inhibit-startup-message t
      send-mail-function 'smtpmail-send-it
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587
      message-citation-line-format "On %e %B %Y %R, %N wrote:\n"
      message-citation-line-function 'message-insert-formatted-citation-line
      message-make-forward-subject-function 'message-forward-subject-fwd)

;;; BBDB
(setq
 ;; Create a new record in BBDB without prompting.
 bbdb-update-records-p t
 ;; Update BBDB with all mail addresses of the message.
 bbdb-message-all-addresses t)

(when (featurep 'bbdb-loaddefs) (my-bbdb-initialize))

;;; Whitespace
(global-whitespace-mode 1)

;; Do not display spaces, tabs and newlines marks.
(setq whitespace-style (set-difference whitespace-style '(tabs
                                                          spaces
                                                          newline
                                                          space-mark
                                                          tab-mark
                                                          newline-mark))
      whitespace-action '(auto-cleanup))

;; Turn off whitespace-mode in Dired-like buffers.
(setq whitespace-global-modes '(not dired-mode archive-mode))

;;; Compilation
(setq compilation-scroll-output 'first-error
      compilation-context-lines 0)

(add-hook 'compilation-mode-hook 'next-error-follow-minor-mode)

;;; Ido
(ido-mode 1)

(ido-everywhere 1)

;;; Ffap
(setq ffap-machine-p-known 'reject)

;;; Auto-insert

;; This skeleton is like the one provided by default, except that we add
;; an appropriate comment after the #endif.
(define-auto-insert '("\\.\\([Hh]\\|hh\\|hpp\\)\\'" . "C / C++ guard macro")
  '((upcase (concat (file-name-nondirectory
                     (file-name-sans-extension buffer-file-name))
                    "_"
                    (file-name-extension buffer-file-name)))
    "#ifndef " str "\n#define " str "\n\n" _ "\n\n#endif /* not " str " */\n"))

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

(setq auto-insert-directory (my-prefix-by-user-emacs-directory "insert/"))
(auto-insert-mode 1)

;;; Semantic
(my-add-to-list
 'semantic-default-submodes
 '(global-semantic-stickyfunc-mode global-semantic-mru-bookmark-mode))

(semantic-mode 1)

;;; Desktop

;; We only search for local desktop files.
(setq desktop-path '("."))

(desktop-save-mode 1)

;;; CC mode
(c-add-style "my-linux" '("linux" (indent-tabs-mode . t)))

(add-hook 'c-initialization-hook 'my-c-initialization-hook-f)

;; In java-mode and c++-mode, we use C style comments and not
;; single-line comments.
(my-add-hooks '(java-mode-hook c++-mode-hook) 'my-c-trad-comment-on)

;;; Tuareg
(setq tuareg-interactive-read-only-input t)

(my-add-hook 'tuareg-mode-hook '(merlin-mode my-tuareg-mode-hook-f))

;;; Merlin
(setq merlin-command 'opam
      merlin-error-after-save nil
      merlin-completion-with-doc t)

(add-hook 'merlin-mode-hook 'my-merlin-mode-hook-f)

;;; Scala
(my-add-hook 'scala-mode-hook '(my-c-trad-comment-on my-scala-mode-hook-f))

;;; Proof general
(setq proof-splash-enable nil
      proof-three-window-mode-policy 'hybrid
      coq-one-command-per-line nil)

;;; Asm
(setq asm-comment-char ?#)

;;; Prolog
;; (setq-default prolog-system 'eclipse)

;;; LaTeX
(setq TeX-auto-save t
      TeX-parse-self t
      TeX-auto-local ".auto"
      TeX-auto-private (list (my-prefix-by-user-emacs-directory "auctex/auto"))
      LaTeX-section-hook '(LaTeX-section-heading
                           LaTeX-section-title
                           LaTeX-section-toc
                           LaTeX-section-section
                           LaTeX-section-label)
      reftex-plug-into-AUCTeX t
      reftex-enable-partial-scans t
      reftex-save-parse-info t
      reftex-use-multiple-selection-buffers t
      TeX-electric-math (cons "$" "$")
      TeX-electric-sub-and-superscript t
      font-latex-fontify-script 'multi-level)

(setq-default TeX-master nil)

(my-add-hook 'LaTeX-mode-hook
             '(TeX-PDF-mode LaTeX-math-mode TeX-source-correlate-mode
                            reftex-mode my-LaTeX-mode-hook-f))

;;; Miscellaneous settings
(setq inhibit-startup-screen t
      disabled-command-function nil
      auto-mode-case-fold nil
      load-prefer-newer t
      view-read-only t
      comint-prompt-read-only t
      auth-source-save-behavior nil
      auth-source-cache-expiry nil
      mail-signature-file (my-prefix-by-user-emacs-directory "signature")
      gnus-init-file (my-prefix-by-user-emacs-directory "gnus-init.el")
      vc-follow-symlinks t)

(setq-default require-final-newline t
              indent-tabs-mode nil)

(my-add-to-list 'completion-ignored-extensions
                '(".auto/" ".prv/" "_build/"
                  ".d" ".native" ".byte" ".pdf"
                  ".out" ".fls" ".synctex.gz" ".fdb_latexmk"
                  ".rel" ".unq" ".tns"
                  ".emacs.desktop" ".emacs.desktop.lock" "_region_.tex"))

(my-add-to-list 'auto-mode-alist
                '(("README\\'" . text-mode)
                  ;; ("\\.pl\\'" . prolog-mode)
                  ("COMMIT_EDITMSG\\'" . text-mode)
                  ("MERGE_MSG\\'" . text-mode)
                  ("\\.gitignore\\'" . conf-unix-mode)
                  ("\\.ml[ly]\\'" . tuareg-mode)
                  ("\\.top\\'" . tuareg-mode)
                  ("\\.ocamlinit\\'" . tuareg-mode)
                  ("\\.ocp-indent\\'" . conf-unix-mode)
                  ("Dockerfile\\'" . conf-space-mode)
                  ("_tags\\'" . conf-colon-mode)
                  ("_log\\'" . conf-unix-mode)
                  ("\\.merlin\\'" . conf-space-mode)
                  ("\\.mrconfig\\'" . conf-unix-mode)))

(tool-bar-mode 0)

(scroll-bar-mode 0)

(column-number-mode 1)

(global-subword-mode 1)

(electric-indent-mode 1)

(electric-pair-mode 1)

(show-paren-mode 1)

(savehist-mode 1)

(winner-mode 1)

;;; Custom global key bindings
(my-global-set-key "a" 'ff-get-other-file)

(my-global-set-key "c" 'my-compile)

(my-global-set-key "d" 'desktop-change-dir)

(my-global-set-key "g" 'revert-buffer)

(my-global-set-key "i" 'my-indent-buffer)

(my-global-set-key "m" 'man)

(my-global-set-key "n" 'gnus)

(my-global-set-key "o" 'ff-find-other-file)

(my-global-set-key "p" 'check-parens)

(my-set-spelling-key "c" 'ispell-comments-and-strings)

(my-set-spelling-key "d" 'ispell-change-dictionary)

(my-set-spelling-key "s" 'ispell)

(my-global-set-key "t" 'my-transpose-windows)

(my-global-set-key "u" 'browse-url)

(my-global-set-key "w" 'whitespace-cleanup)

(my-global-set-key "x" 'ansi-term)

;; Do not activate following in diff-mode because it can freeze Emacs.
(add-hook 'occur-mode-hook 'next-error-follow-minor-mode)

(my-add-hook 'after-init-hook '(global-company-mode my-after-init-hook-f))

;; Enable smerge-mode when necessary.
(add-hook 'find-file-hook 'my-try-smerge t)

(add-hook 'conf-mode-hook 'my-indent-tabs-mode-on)

(add-hook 'message-mode-hook 'my-message-mode-hook-f)

;;; Emacs server
(server-start)
