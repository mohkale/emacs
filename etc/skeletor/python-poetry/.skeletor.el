;; -*- lexical-binding: t -*-
;; Classic python using elegant poetry for dependency management.

(skeletor-define-template "python-poetry"
  :title "Python [poetry]"
  :requires-executables '(("python3" . "https://www.python.org/")
                          ("poetry" . "https://python-poetry.org/"))
  :after-creation
  (lambda (dir)
    (skeletor-shell-command "poetry init --no-interaction --no-ansi --dev-dependency pytest" dir)))
