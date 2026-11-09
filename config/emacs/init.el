;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(require 'package)
(require 'seq)
(require 'use-package)

;; 言語と文字コード
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8-unix)

;; Emacsが生成するファイルを設定本体から分離する
(defconst my-state-directory
  (expand-file-name "var/" user-emacs-directory))
(defconst my-backup-directory
  (expand-file-name "backups/" my-state-directory))
(defconst my-auto-save-directory
  (expand-file-name "auto-save/" my-state-directory))

(dolist (directory (list my-state-directory
                         my-backup-directory
                         my-auto-save-directory))
  (make-directory directory t))

(setq custom-file (expand-file-name "custom.el" my-state-directory)
      backup-directory-alist `(("." . ,my-backup-directory))
      auto-save-file-name-transforms `((".*" ,my-auto-save-directory t))
      auto-save-list-file-prefix (expand-file-name ".saves-" my-auto-save-directory)
      savehist-file (expand-file-name "savehist" my-state-directory)
      recentf-save-file (expand-file-name "recentf" my-state-directory)
      save-place-file (expand-file-name "places" my-state-directory))
(load custom-file 'noerror 'nomessage)

;; パッケージはGNU ELPA、NonGNU ELPA、MELPAから導入する
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu" . 30)
        ("nongnu" . 20)
        ("melpa" . 10)))
(package-initialize)

(defconst my-selected-packages
  '(company
    flycheck
    diff-hl
    exec-path-from-shell
    inf-ruby
    magit
    markdown-mode
    php-mode
    projectile
    projectile-rails
    rspec-mode
    swift-mode
    web-mode
    yaml-mode
    yasnippet
    zenburn-theme))
(setq package-selected-packages my-selected-packages)

(defun my-install-missing-packages ()
  "Install packages listed in `my-selected-packages' when missing."
  (let ((missing-packages
         (seq-filter (lambda (item) (not (package-installed-p item)))
                     my-selected-packages)))
    (when missing-packages
      (package-refresh-contents)
      (dolist (item missing-packages)
        (package-install item)))))

;; 検証時はネットワークアクセスを抑止できる
(unless (getenv "DOTFILES_EMACS_SKIP_PACKAGE_INSTALL")
  (my-install-missing-packages))

;; 基本動作
(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function #'ignore
      use-short-answers t
      frame-title-format "%f"
      sentence-end-double-space nil
      tab-always-indent 'complete
      completion-ignore-case t
      read-file-name-completion-ignore-case t)
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 100)

(column-number-mode 1)
(size-indication-mode 1)
(display-time-mode 1)
(global-auto-revert-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(fido-vertical-mode 1)
(when (fboundp 'repeat-mode)
  (repeat-mode 1))
(when (fboundp 'which-key-mode)
  (which-key-mode 1))

(setq show-paren-delay 0
      show-paren-style 'expression)

;; ターミナルなど行番号が不要なモードでは非表示にする
(dolist (hook '(term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                vterm-mode-hook
                help-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode -1))))

;; Hack Nerd Fontが利用できる場合だけGUIフレームへ適用する
(defun my-apply-font (&optional frame)
  "Apply the preferred font to FRAME when available."
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (when-let* ((family (seq-find
                           (lambda (candidate)
                             (member candidate (font-family-list)))
                           '("Hack Nerd Font Mono" "Hack Nerd Font" "Hack"))))
        (set-face-attribute 'default nil :family family :height 140)))))

(my-apply-font)
(add-hook 'after-make-frame-functions #'my-apply-font)

;; キーバインド
(global-set-key (kbd "C-m") #'newline-and-indent)
(global-set-key (kbd "C-t") #'other-window)
(global-set-key (kbd "C-c l") #'toggle-truncate-lines)
(global-set-key (kbd "C-c <left>") #'windmove-left)
(global-set-key (kbd "C-c <down>") #'windmove-down)
(global-set-key (kbd "C-c <up>") #'windmove-up)
(global-set-key (kbd "C-c <right>") #'windmove-right)
(global-set-key (kbd "C-x ?") #'help-command)
(define-key key-translation-map (kbd "¥") (kbd "\\"))

(defun my-project-dired ()
  "Open Dired at the current project root or prompt for a directory."
  (interactive)
  (let ((project (project-current)))
    (if project
        (dired (project-root project))
      (call-interactively #'dired))))

(global-set-key (kbd "C-c n") #'my-project-dired)

(add-hook 'before-save-hook #'delete-trailing-whitespace)
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

;; パッケージ設定
(use-package zenburn-theme
  :config
  (load-theme 'zenburn t))

(use-package exec-path-from-shell
  :if (or (daemonp) (memq window-system '(mac ns)))
  :config
  (dolist (variable '("SSH_AUTH_SOCK" "LANG" "LC_CTYPE"))
    (add-to-list 'exec-path-from-shell-variables variable))
  (exec-path-from-shell-initialize))

(use-package editorconfig
  :ensure nil
  :config
  (editorconfig-mode 1))

(use-package company
  :hook (after-init . global-company-mode)
  :custom
  (company-idle-delay 0.2)
  (company-minimum-prefix-length 2)
  (company-selection-wrap-around t))

(use-package flycheck
  :hook (after-init . global-flycheck-mode))

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package projectile
  :init
  (projectile-mode 1)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :custom
  (projectile-enable-caching t)
  :config
  (add-to-list 'projectile-globally-ignored-directories "node_modules"))

(use-package projectile-rails
  :after projectile
  :config
  (projectile-rails-global-mode 1))

(use-package diff-hl
  :hook
  ((after-init . global-diff-hl-mode)
   (dired-mode . diff-hl-dired-mode))
  :bind
  (("C-c v p" . diff-hl-previous-hunk)
   ("C-c v n" . diff-hl-next-hunk)))

(use-package markdown-mode
  :mode "\\.md\\'")

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package web-mode
  :mode ("\\.html?\\'"
         "\\.css\\'"
         "\\.jsx?\\'"
         "\\.tsx?\\'"
         "\\.vue\\'"
         "\\.erb\\'"
         "\\.tpl\\.php\\'")
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2))

(use-package php-mode
  :mode "\\.php\\'"
  :hook
  (php-mode . (lambda ()
                (setq-local c-basic-offset 4
                            indent-tabs-mode nil))))

(use-package inf-ruby
  :hook (ruby-mode . inf-ruby-minor-mode))

(use-package rspec-mode
  :hook (ruby-mode . rspec-mode))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode))

(use-package swift-mode
  :mode "\\.swift\\'")

(use-package eglot
  :ensure nil
  :hook (swift-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               '(swift-mode . ("xcrun" "sourcekit-lsp"))))

(require 'tramp)
(setq tramp-default-method "ssh")

;;; init.el ends here
