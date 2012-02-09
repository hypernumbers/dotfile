;; -*- Mode: Emacs-Lisp -*-
;; -*- lisp -*-

(provide 'erlang-setup)

(setq load-path (cons "~/lib/dotfiles/emacs/erlang/erlware-mode" load-path))
(require 'erlang-start)
(add-to-list 'auto-mode-alist '("\\.escript?$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.erl?$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.hrl?$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.yrl?$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.xrl?$" . erlang-mode))

(add-to-list 'load-path "~/lib/dotfiles/emacs/erlang/distel/elisp")
(require 'distel)
(distel-setup)
(setq derl-cookie "nocookie")
(setq erl-nodename-cache (make-symbol "n_0@127.0.0.1"))
