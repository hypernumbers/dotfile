;; -*- Mode: Emacs-Lisp -*-
;; -*- lisp -*-

(provide 'moz-setup)

(require 'moz)

(define-minor-mode moz-reload-mode
  "Moz Reload Minor Mode"
  nil " Reload" nil
  (if moz-reload-mode
      (add-hook 'after-save-hook 'moz-firefox-reload nil t)
    (remove-hook 'after-save-hook 'moz-firefox-reload t)))

(defun moz-firefox-reload ()
  (comint-send-string (inferior-moz-process) "BrowserReload();"))
