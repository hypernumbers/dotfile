; -*- Mode: Emacs-Lisp -*-
;; -*- lisp -*-

(add-to-list 'load-path "~/.emacs_lib")
(add-to-list 'load-path "~/.emacs_lib/moz")
(add-to-list 'load-path "/usr/share/emacs/site-lisp/js2-mode")
(add-to-list 'load-path "~/.emacs_lib/json-mode")

;; json mode
(add-to-list 'auto-mode-alist '("\\.json?$" . json-mode))
(require 'json-mode)

;;(autoload 'espresso-mode "espresso")
(autoload 'moz-minor-mode "moz" "Mozilla Minor and Inferior Mozilla Modes" t)

;; Save sessions and stuff
;(desktop-load-default)
;(desktop-save-mode 1)

;; Enable modes
(ido-mode 1)
(cua-mode 1)
(line-number-mode 1)
(column-number-mode 1)

(setq kill-whole-line t)
;; Disable some ui
;;(menu-bar-mode 0)
;;(scroll-bar-mode 0)
;;(tool-bar-mode 0)

;; Set the font
(set-face-attribute 'default nil :height 90 :weight 'bold)
;(set-face-background 'mode-line "black")
;(set-face-foreground 'mode-line "white")

;; Stop making ~ files, get rid of startup message
(setq inhibit-startup-message 0)
;(setq make-backup-files         nil)
(setq auto-save-list-file-name  nil)

;; Use clipboard
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;; Use spaces to indent, 4 by default.
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq tab-width 2)
(setq c-basic-indent 2)
(setq espresso-indent-level 2)
(setq js2-indent-level 2)

;; Fancy auto complete box
;(require 'auto-complete)
;(global-auto-complete-mode 1)

;; delete trailing white space
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Make pretty colours
(add-to-list 'load-path "~/.emacs_lib/color-theme-6.6.0")
(require 'color-theme)
(color-theme-initialize)
;(color-theme-midnight)

;; Espresso-mode for javascript
(autoload 'js2-mode "js2" nil t)
;;(add-to-list 'auto-mode-alist '("\\.js$" . espresso-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; Erlware-mode for erlang
(setq load-path (cons "~/.emacs_lib/erlang/erlware-mode" load-path))
(require 'erlang-start)

(add-to-list 'auto-mode-alist '("\\.escript?$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.erl?$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.hrl?$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.yrl?$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.xrl?$" . erlang-mode))

;;(add-hook 'erlang-mode-hook
;;          '(lambda ()
;;             (flymake-mode)
;;             (local-set-key (kbd "M-'") 'erlang-flymake-next-error)
;;             ))

;; Distel also for erlang
;;(add-to-list 'load-path "~/.emacs_lib/distel/elisp")
;;(require 'distel)
;;(distel-setup)
;;(setq derl-cookie "abc")
;;(setq erl-nodename-cache (make-symbol "dale@localhost"))

(defun my-js2-indent-function ()
  (interactive)
  (save-restriction
    (widen)
    (let* ((inhibit-point-motion-hooks t)
           (parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (espresso--proper-indentation parse-status))
           node)

      (save-excursion

        ;; I like to indent case and labels to half of the tab width
        (back-to-indentation)
        (if (looking-at "case\\s-")
            (setq indentation (+ indentation (/ espresso-indent-level 2))))

        ;; consecutive declarations in a var statement are nice if
        ;; properly aligned, i.e:
        ;;
        ;; var foo = "bar",
        ;;     bar = "foo";
        (setq node (js2-node-at-point))
        (when (and node
                   (= js2-NAME (js2-node-type node))
                   (= js2-VAR (js2-node-type (js2-node-parent node))))
          (setq indentation (+ 4 indentation))))

      (indent-line-to indentation)
      (when (> offset 0) (forward-char offset)))))

(defun my-indent-sexp ()
  (interactive)
  (save-restriction
    (save-excursion
      (widen)
      (let* ((inhibit-point-motion-hooks t)
             (parse-status (syntax-ppss (point)))
             (beg (nth 1 parse-status))
             (end-marker (make-marker))
             (end (progn (goto-char beg) (forward-list) (point)))
             (ovl (make-overlay beg end)))
        (set-marker end-marker end)
        (overlay-put ovl 'face 'highlight)
        (goto-char beg)
        (while (< (point) (marker-position end-marker))
          ;; don't reindent blank lines so we don't set the "buffer
          ;; modified" property for nothing
          (beginning-of-line)
          (unless (looking-at "\\s-*$")
            (indent-according-to-mode))
          (forward-line))
        (run-with-timer 0.5 nil '(lambda(ovl)
                                   (delete-overlay ovl)) ovl)))))


(defun my-js2-mode-hook ()
  (require 'espresso)
  (setq espresso-indent-level 4
        indent-tabs-mode nil
        c-basic-offset 8)
  (c-toggle-auto-state 0)
  (c-toggle-hungry-state 1)
  (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
  (define-key js2-mode-map [(meta control |)] 'cperl-lineup)
  (define-key js2-mode-map [(meta control \;)]
    '(lambda()
       (interactive)
       (insert "/* -----[ ")
       (save-excursion
         (insert " ]----- */"))
       ))
  (define-key js2-mode-map [(return)] 'newline-and-indent)
  (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
  (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
  (define-key js2-mode-map [(control meta q)] 'my-indent-sexp)
  (if (featurep 'js2-highlight-vars)
    (js2-highlight-vars-mode))
  (message "My JS2 hook"))

(add-hook 'js2-mode-hook
          'my-js2-mode-hook
          )

;; (require 'flymake-jslint)
;; (add-hook 'js2-mode-hook
;;           'my-js2-mode-hook
;;           '(lambda () (flymake-mode t)))

;; Example - you may want to add hooks for your own modes.
;; I also add this to python-mode when doing django development.
;; (add-hook 'html-mode-hook 'auto-reload-firefox-on-after-save-hook)
;; (add-hook 'css-mode-hook 'auto-reload-firefox-on-after-save-hook)
;; (add-hook 'js2-mode-hook 'auto-reload-firefox-on-after-save-hook)

;; (define-minor-mode moz-save-mode
;;   "Moz Save Reload Minor Mode"
;;   nil " Reload" nil
;;   (if moz-save-mode
;;       Edit hook buffer-locally.
;;       (add-hook 'post-command-hook 'moz-reload nil t)
;;     (remove-hook 'post-command-hook 'moz-reload t)))

;; (defun auto-reload-firefox-on-after-save-hook ()
;;   (add-hook 'after-save-hook
;;             '(lambda ()
;;                (interactive)
;;                (comint-send-string (inferior-moz-process)
;;                                    "BrowserReload();"))
;;             'append 'local)) buffer-local

;;; Usage
;; Run M-x moz-reload-mode to switch moz-reload on/off in the
;; current buffer.
;; When active, every change in the buffer triggers Firefox
;; to reload its current page.
(require 'moz)

(define-minor-mode moz-reload-mode
  "Moz Reload Minor Mode"
  nil " Reload" nil
  (if moz-reload-mode
      (add-hook 'after-save-hook 'moz-firefox-reload nil t)
    (remove-hook 'after-save-hook 'moz-firefox-reload t)))

(defun moz-firefox-reload ()
  (comint-send-string (inferior-moz-process) "BrowserReload();"))

;; (defun moz-reload ()
;;   (when (buffer-saved)
;;     (moz-firefox-reload)))

(defun hypernumbers-hn (hn-type)
  (format "in -hn")
  (cd "/home/gordon/hypernumbers/")
  (compile (concat "./hn " hn-type))
  (other-window 1)
  (goto-char (point-max))
  (other-window -1))

(defun hypernumbers-quick ()
  (interactive)
  (format "in quick")
  (hypernumbers-hn "quick"))

(defun hypernumbers-lexer-parser ()
  (interactive)
  (hypernumbers-hn "lexer-parser"))

(defun hypernumbers-build ()
  (interactive)
  (hypernumbers-hn "build"))

(global-set-key [f12] 'hypernumbers-quick)
(global-set-key [f11] 'hypernumbers-lexer-parser)
(global-set-key [f10] 'hypernumbers-build)
(global-set-key [f9] 'moz-firefox-reload)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(cua-mode t nil (cua-base))
 '(show-paren-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight bold :height 98 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))
