;; -*- lexical-binding: t -*-

(skeletor-define-constructor "haskell-stack"
  :title "Haskell [stack]"
  :requires-executables '(("ghc" . "https://www.haskell.org/")
                          ("stack" . "https://docs.haskellstack.org/en/stable/README/"))
  :no-license? t
  :initialise
  (lambda (spec)
    (let-alist spec
      (let ((template (read-string "Template: " nil nil "simple")))           ; See more at [[https://github.com/commercialhaskell/stack-templates][stack-templates]].
        (mkdir .dest t)
        (skeletor--log-info "Initialising project using stack")
        (skeletor-shell-command
         (concat "stack new " (shell-quote-argument .project-name)
                 " " (shell-quote-argument template)
                 " .")
         .dest)))))
