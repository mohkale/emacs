;; -*- lexical-binding: t -*-

(require 'cl)

;; disable both package.el autloads
;; and selected packages in custom.
(setq package-enable-at-startup nil
      package--init-file-ensured t)

(package-initialize)

(let ((package-sources `(("melpa" . "https://melpa.org/packages/")
                         ;; ("org"       . "http://orgmode.org/elpa/")
                         ;; ("marmalade" . "http://marmalade-repo.org/packages/"))
                         ("gnu"       . "http://elpa.gnu.org/packages/"))))
  (dolist (source package-sources)
    (add-to-list 'package-archives source t)))

(defvar mohkale/package-list-refreshed nil
  "whether package-list-refreshed has been invoked since startup.
don't invoke it until doing so is absolutely essential. Waiting for a
network connection is a huge pain if you restart emacs often enough.")
(setq mohkale/package-list-refreshed nil) ;; reset to nil on refresh

(defvar mohkale/mohkale-config-file (expand-file-name "~/.emacs.d/mohkale.new.org")
  "path to my custom (org-mode) user config file.")
(defvar mohkale/mohkale-el-config-file (concat (file-name-sans-extension mohkale/mohkale-config-file)
					       ".el")
  "path to my custom user config file after being tangled into emacs lisp")

;; ensure packages needed to setup emacs from
;; scratch are installed and usable.
(let ((startup-requires `(use-package
			  general)))
  (dolist (package startup-requires)
    ;; iterate for all required packages
    (unless (package-installed-p package)
      (unless mohkale/package-list-refreshed
	(package-refresh-contents)
	(setq mohkale/package-list-refreshed t))

      (package-install package))
    (require package)))

;; don't store customisations in here. They're really ugly :(
(let ((custom-file-path (expand-file-name "~/.emacs.d/custom.el")))
  (setq custom-file custom-file-path)
  (if (file-exists-p custom-file-path)
      (load custom-file-path)))

(org-babel-load-file mohkale/mohkale-config-file)
