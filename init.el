;; if package isn't found use - M-x package-refresh-contents

;; This makes my Emacs startup time ~35% faster.
;;(setq gc-cons-threshold 100000000)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;PACKAGES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
(setq package-enable-at-startup nil)

;; https://emacs.stackexchange.com/a/2989
(setq package-archives
      '(("elpa"     . "https://elpa.gnu.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("melpa"        . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("melpa-stable" . 10)
        ("elpa"     . 5)
        ("melpa"        . 0)))

(package-initialize)

;; Bootstrap `use-package`
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Some global key bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key [f1] 'byte-compile-file)
(global-set-key [f7] (lambda () (interactive) (find-file user-init-file)))
(global-set-key [f5] (lambda () (interactive) (find-file "~/work")))
(global-set-key [f12] (lambda () (interactive) (find-file "/home/samz/Dropbox/orgfiles")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BASH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq-default sh-basic-offset 8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;C PROGAMMING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
         (column (c-langelem-2nd-pos c-syntactic-element))
         (offset (- (1+ column) anchor))
         (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Add kernel style
            (c-add-style
             "linux-tabs-only"
             '("linux" (c-offsets-alist
                        (arglist-cont-nonempty
                         c-lineup-gcc-asm-reg
                         c-lineup-arglist-tabs-only))))))

(add-hook 'c-mode-hook
          (lambda ()
            (let ((filename (buffer-file-name)))
              ;; Enable kernel mode for the appropriate files
              (when (and filename
                         (string-match (expand-file-name "~/src/linux-trees")
                                       filename))
                (setq indent-tabs-mode t)
                (setq show-trailing-whitespace t)
                (c-set-style "linux-tabs-only")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;HOUSEKEEPING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This should ensure the X clipboard contents isn’t lost during normal editing.
(setq save-interprogram-paste-before-kill t)
(setq ag-highlight-search t)
(setq ring-bell-function 'ignore) ;; Don't ring the bell
(defalias 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(setq initial-scratch-message nil)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-visual-line-mode 1)
;; (setq column-number-mode t)
(global-hl-line-mode t) ;; Highlight the line we are currently on
(global-set-key (kbd "C-c w") 'whitespace-mode) ;; show white space characters
(global-set-key (kbd "C-x C-b") 'ibuffer) ;; another buffer viewer to something more explained
(setq gdb-many-windows t)
(setq make-backup-files nil) ;; stop creating backup~ files
(setq auto-save-default nil) ;; stop creating #autosave# files
(show-paren-mode 1)
(windmove-default-keybindings)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tabs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default indent-tabs-mode t); ; make tab key call indent command or insert tab character, depending on cursor position
(setq tab-width 4)

(use-package ido-completing-read+
  :ensure t
  :config
  (ido-ubiquitous-mode t))


;; ;; make characters after column 80 purple
;; (setq whitespace-style
;;   (quote (face trailing tab-mark lines-tail)))
;; (add-hook 'find-file-hook 'whitespace-mode)

(setq-default show-trailing-whitespace t)

;; whitespace cleanup
(use-package ws-butler
  :ensure t
  :diminish ws-butler-mode
  :config
  (progn
    (ws-butler-global-mode)
    (setq ws-butler-keep-whitespace-before-point nil)))

;; Settings for searching
(setq-default case-fold-search t ;case insensitive searches by default
              search-highlight t) ;highlight matches when searching

(setq sentence-end-double-space nil)
(setq vc-follow-symlinks t)

;; Pair-wise colored parens.
(use-package rainbow-delimiters
  :ensure t
  :init
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ivy | Counsel | Swiper | Dired
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package counsel
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :defer 0.1
  :diminish
  :bind (("C-c C-r" . ivy-resume)
         ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (ivy-count-format "(%d/%d) ")
  (ivy-use-virtual-buffers t)
  :config (ivy-mode))

(use-package swiper
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

(global-set-key (kbd "C-s") 'swiper)  ;; replaces i-search with swiper
(global-set-key (kbd "M-x") 'counsel-M-x) ;; Gives M-x command counsel features
(global-set-key (kbd "C-x C-f") 'counsel-find-file) ;; gives C-x C-f counsel feat

;; Better dired.
(use-package dired-x
  ;; built-in
  :demand t
  :init
  (add-hook 'dired-mode-hook 'dired-hide-details-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Undo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode
  :init
  (global-undo-tree-mode 1)
  :config
  (defalias 'redo 'undo-tree-redo)
  :bind (("C-z" . undo)     ; Zap to character isn't helpful
         ("C-S-z" . redo)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; copy stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (list (line-beginning-position) (line-beginning-position 2)))))

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position) (line-beginning-position 2)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Org Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org-bullets
  :ensure t
  :commands (org-bullets-mode)
  :init (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(setq org-startup-with-inline-images t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;THEMES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq custom-safe-themes t) ;; stop annoying safety questions

;; (use-package doom-themes
;;   :ensure t
;; )

;;(use-package material-theme :ensure t :config (load-theme 'material t))
(if (display-graphic-p) ;; if we are not in a terminal
    (load-theme 'dracula)
  (load-theme 'wheatgrass))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Git stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package magit-popup
  :ensure t
)

;; Git interface.
(use-package magit
  :ensure t
  :diminish auto-revert-mode
  :commands (magit-status magit-checkout)
  :bind (("C-x g" . magit-status))
  :init
  (setq magit-revert-buffers 'silent
        magit-push-always-verify nil
        git-commit-summary-max-length 80))

;; Function to push to gerrit
(defun magit-push-to-gerrit ()
  (interactive)
  (magit-git-command-topdir "git push gerrit HEAD:refs/for/master"))
;; Add it to the push menu

(with-eval-after-load 'magit-remote
(magit-define-popup-action 'magit-push-popup ?m
  "Push to gerrit"
  'magit-push-to-gerrit))

(use-package git-gutter
  :ensure t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function global-git-gutter-mode "git-gutter.el"))
  :config
  ;; If you enable global minor mode
  (global-git-gutter-mode t)
  ;; Auto update every 5 seconds
  (custom-set-variables
   '(git-gutter:update-interval 5))

  ;; Set the foreground color of modified lines to something obvious
  (set-face-foreground 'git-gutter:modified "purple")
  )

;; Show a small popup with the blame for the current line only.
(use-package git-messenger
  :ensure t
  :bind ("C-c g p" . git-messenger:popup-message)
  :init
  (setq git-messenger:show-detail t)
  :config
  (progn
    (define-key git-messenger-map (kbd "RET") 'git-messenger:popup-close)))

(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Email
;;
;; mu4e
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'mu4e nil t)
(setq mu4e-mu-binary "/usr/bin/mu")
(setq mu4e-sent-messages-behavior 'delete)
(setq mu4e-get-mail-command "offlineimap")
(setq mu4e-attachment-dir  "~/Downloads")
(setq mu4e-view-show-addresses 't)
(require 'org-mu4e nil t)
(require 'starttls)
(setq starttls-use-gnutls t)
(setq mu4e-get-mail-command "offlineimap -o"
      mu4e-update-interval  300)

;; I want my format=flowed thank you very much
;; mu4e sets up visual-line-mode and also fill (M-q) to do the right thing
;; each paragraph is a single long line; at sending, emacs will add the
;; special line continuation characters.
(setq mu4e-compose-format-flowed t)
;; every new email composition gets its own frame! (window)
(setq mu4e-compose-in-new-frame t)

;; don't keep message buffers around
(setq message-kill-buffer-on-exit t)

;; HTML
(require 'mu4e-contrib)
(setq mu4e-html2text-command 'mu4e-shr2text)
(add-hook 'mu4e-view-mode-hook
          (lambda()
            ;; try to emulate some of the eww key-bindings
            (local-set-key (kbd "<tab>") 'shr-next-link)
            (local-set-key (kbd "<backtab>") 'shr-previous-link)))


(setq mu4e-maildir-shortcuts
      '(("/INBOX"             . ?i)
        ("/[Gmail].Sent Mail" . ?s)
        ("/[Gmail].Trash"     . ?t)))

(require 'smtpmail)
(setq send-mail-function            'smtpmail-send-it
      message-send-mail-function    'smtpmail-send-it
      smtpmail-auth-credentials     (expand-file-name "~/.authinfo.gpg")
      smtpmail-stream-type          'tls
      smtpmail-smtp-server          "smtp.gmail.com"
      smtpmail-smtp-service         465)

(setq send-mail-function  'smtpmail-send-it
      message-send-mail-function    'smtpmail-send-it
      smtpmail-auth-credentials     (expand-file-name "~/.authinfo.gpg")
      smtpmail-smtp-server  "smtp.office365.com"
      smtpmail-stream-type  'starttls
      smtpmail-smtp-service 587)

(setq starttls-use-gnutls t)
(setq smtpmail-debug-info t)
(setq smtpmail-debug-verb t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modes - Highlighting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :ensure t
  :mode (".md" ".markdown"))

(use-package handlebars-mode
  :ensure t
  :mode (".hbs" . handlebars-mode)
  )

(use-package web-mode
  :ensure t
  :mode (("\\.phtml\\'" . web-mode)
         ("\\.tpl\\.php\\'" . web-mode)
         ("\\.[agj]sp\\'" . web-mode)
         ("\\.as[cp]x\\'" . web-mode)
         ("\\.erb\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.djhtml\\'" . web-mode)
         ("\\.html?\\'" . web-mode))
  )

(use-package lua-mode
  :ensure t
  :mode (".lua"))


(use-package yaml-mode
  :ensure t
  :mode (".yml" ".yaml" ".raml"))

(use-package json-mode
  :ensure t
  :mode (".json" ".imp"))

(use-package asm-mode
  :mode ("\\.s\\'"))

(use-package nyan-mode
  :if window-system
  :ensure t
  :config
  (nyan-mode)
  (nyan-start-animation)
  )

(use-package bitbake
  :ensure t
  :defer t
  :mode (("\\.bb" . bitbake-mode)
         ("\\.inc" . bitbake-mode)
         ("\\.bbappend" . bitbake-mode)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("6b2636879127bf6124ce541b1b2824800afc49c6ccd65439d6eb987dbf200c36" "ecba61c2239fbef776a72b65295b88e5534e458dfe3e6d7d9f9cb353448a569e" "fe666e5ac37c2dfcf80074e88b9252c71a22b6f5d2f566df9a7aa4f9bea55ef8" "6b289bab28a7e511f9c54496be647dc60f5bd8f9917c9495978762b99d8c96a0" "cd736a63aa586be066d5a1f0e51179239fe70e16a9f18991f6f5d99732cabb32" default)))
 '(git-gutter:update-interval 5)
 '(ivy-count-format "(%d/%d) ")
 '(ivy-use-virtual-buffers t)
 '(package-selected-packages
   (quote
    (lua-mode zerodark-theme ido-completing-read+ bb-mode dracula-theme mu4e doom-themes ws-butler undo-tree bitbake yaml-mode web-mode use-package swiper-helm org-bullets nyan-mode markdown-mode magit json-mode handlebars-mode counsel))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )



;; HELM

;; (use-package helm
;;   :ensure t
;;   :diminish helm-mode
;;   :bind (("M-x" . helm-M-x)
;;          ("C-x C-f" . helm-find-files)
;;          ("C-x b" . helm-buffers-list))
;;   :init
;;   (setq helm-M-x-fuzzy-match t
;;         helm-buffers-fuzzy-matching t
;;         helm-display-header-line nil)
;;   :config
;;   ;; No idea why here find-file is set to nil (so it uses the native find-file
;;   ;; for Emacs. This makes stuff like (find-file (read-file-name ...)) work with
;;   ;; Helm again.
;;   (helm-mode 1)
;;   (helm-autoresize-mode 1)
;;   (add-to-list 'helm-completing-read-handlers-alist '(find-file . helm-completing-read-symbols)))

;; (use-package helm-ag
;;   :ensure t
;;   :bind ("C-c a g" . helm-do-ag-project-root))
;; ;; For popup search window
;; (use-package swiper-helm
;;   :ensure t
;;   :bind ("C-s" . swiper-helm))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package mu4e
;;   :ensure t
;;   :custom
;;   (mu4e-attachment-dir "~/Downloads")
;;   (mu4e-compose-signature-auto-include nil)
;; ;;  (mu4e-drafts-folder "/gmail/Drafts")
;;   (mu4e-get-mail-command "offlineimap")
;;   (mu4e-maildir "~/Maildir")
;;   ;; (mu4e-refile-folder "/gmail/Archive")
;; ;;  (mu4e-sent-folder "/gmail/Sent Mail")
;;   ;; (mu4e-maildir-shortcuts
;;   ;;  '(("/gmail/INBOX" . ?i)
;;   ;;    ("/gmail/All Mail" . ?a)
;;   ;;    ("/gmail/Deleted Items" . ?d)
;;   ;;    ("/gmail/Drafts" . ?D)
;;   ;;    ("/gmail/Important" . ?i)
;;   ;;    ("/gmail/Sent Mail" . ?s)
;;   ;;    ("/gmail/Starred" . ?S)))
;;   ;; (mu4e-trash-folder "/gmail/Trash")
;;   (mu4e-update-interval 300)
;;   (mu4e-use-fancy-chars t)
;;   (mu4e-view-show-addresses t)
;;   (mu4e-view-show-images t))

;; Auto-wrap at 80 characters
;(setq-default auto-fill-function 'do-auto-fill)
;;(setq-default fill-column 80)
;(turn-on-auto-fill)
