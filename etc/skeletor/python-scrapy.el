;; -*- lexical-binding: t -*-
;; Generator for a scrapy project using poetry for dependency management.

(skeletor-define-constructor "python-scrapy"
  :title "Python [scrapy]"
  :requires-executables '(("python3" . "https://www.python.org/")
                          ("poetry" . "https://python-poetry.org/"))
  :initialise
  (lambda (spec)
    (let-alist spec
      (mkdir .dest t)
      (skeletor--log-info "Initialising project using poetry and installing scrapy")
      (skeletor-shell-command
       "poetry init --no-interaction --no-ansi --dependency scrapy --dev-dependency pytest" .dest)
      (skeletor-shell-command "poetry install" .dest)

      (skeletor--log-info "Bootstrapping new scrapy project")
      (skeletor-shell-command (concat "poetry run scrapy startproject "
                                      (shell-quote-argument .project-name)
                                      " .")
                              .dest))))
