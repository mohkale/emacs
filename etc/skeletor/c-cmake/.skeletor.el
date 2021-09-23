;; -*- lexical-binding: t -*-
;; A basic [[file:etc/project-skeletons/c-make/][C/C++]] project template using a Makefile and either clang or GCC.

(skeletor-define-template "c-make"
  :title "C/C++ [make]"
  :requires-executables '(("make" . "https://www.gnu.org/software/make/"))
  :substitutions
  '(("__MAIN__" . (lambda ()
                    (read-string "Entry point [main]: " nil nil "main")))
    ("__CCLD__" . (lambda ()
                  (funcall skeletor-completing-read-function "Compiler: "
                           '("clang" "clang++" "gcc" "g++"))))))
