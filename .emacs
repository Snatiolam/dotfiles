(setq custom-file "~/.emacs.custom.el")

;(package-initialize)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(global-display-line-numbers-mode)


(global-hl-line-mode)

; Theme installation
(package-install 'dracula-theme)
(load-theme 'dracula t)

; Font configuration
(add-to-list 'default-frame-alist `(font . "MonaspiceNe Nerd Font-14"))

;(package-install 'gruber-darker-theme)
;(load-theme 'gruber-darker)

(setq inhibit-splash-screen t
      make-backup-files nil
      tab-width 4)
