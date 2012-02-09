;; -*- Mode: Emacs-Lisp -*-
;; -*- lisp -*-

(provide 'color-theme-setup)

(set-face-background 'mode-line "black")
(set-face-foreground 'mode-line "white")

(add-to-list 'load-path "~/lib/dotfiles/emacs/color-theme/color-theme-6.6.0")

(require 'color-theme)
(require 'color-theme-tangotango)

(color-theme-initialize)
(color-theme-tangotango)