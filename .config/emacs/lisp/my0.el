;;; Auxiliary functions
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

(provide 'my0)
