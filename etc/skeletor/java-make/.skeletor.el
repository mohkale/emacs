;; -*- lexical-binding: t -*-
;; A basic Makefile variant for java.

(skeletor-define-template "java-make"
  :title "Java [make]"
  :requires-executables '(("javac" . "https://openjdk.java.net/")
                          ("java" . "https://openjdk.java.net/")
                          ("make" . "https://www.gnu.org/software/make/"))
  :substitutions
  '(("__MAIN-CLASS__" . (lambda ()
                          (read-string "Main class: " "Main")))))
