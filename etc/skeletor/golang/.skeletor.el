;; -*- lexical-binding: t -*-
;; The recommended golang package structure with sub-packages for commands.

(skeletor-define-template "golang"
  :title "Golang [go]"
  :requires-executables '(("go" . "https://golang.org/"))
  :substitutions
  '(("__URL__" . (lambda ()
                   (read-string "Module url: " (concat "github.com/mohkale/project")))))
  :after-creation
  (lambda (dir)
    (skeletor-shell-command (concat "go mod init "
                                    (shell-quote-argument
                                     (alist-get "__URL__" (assoc 'repls skeletor-project-spec)
                                                nil nil #'string-equal)))
                            dir)))
