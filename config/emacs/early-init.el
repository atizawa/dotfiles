;;; early-init.el --- Early Emacs configuration -*- lexical-binding: t; -*-

;; init.elで明示的にパッケージを初期化する
(setq package-enable-at-startup nil
      frame-inhibit-implied-resize t)

;; GUIの装飾を起動時から非表示にする
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;;; early-init.el ends here
