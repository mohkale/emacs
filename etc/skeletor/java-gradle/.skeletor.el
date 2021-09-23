;; -*- lexical-binding: t -*-
;; Java with gradle... the current standard build tool /but my god I hate anything java/.

(skeletor-define-template "java-gradle"
  :title "Java [gradle]"
  :requires-executables '(("javac" . "https://openjdk.java.net/")
                          ("java" . "https://openjdk.java.net/")
                          ("gradle" . "https://gradle.org/"))
  :substitutions
  '(("__MAIN-CLASS__" . (lambda ()
                          (read-string "Main class: " "Main"))))
  :after-creation
  (lambda (dir)
    ;; why /dev/null... gradle isn't very scriptable, go figure.
    (skeletor-shell-command "gradle wrapper" dir)))
