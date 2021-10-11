;; -*- lexical-binding: t -*-
;; The same as a Makefile project but using CMake instead of make. This is pretty
;; much the industry standard so you may as well support it (even if CMake is
;; extremely [[https://www.reddit.com/r/cmake/comments/8p43q0/questiondo_people_really_like_cmake/][ugly]]).

(skeletor-define-template "c-cmake"
  :title "C/C++ [cmake]"
  :requires-executables '(("cmake" . "https://cmake.org/"))
  :substitutions
  '(("__MAIN__" . (lambda ()
                    (read-string "Entry point [main]: " nil nil "main")))
    ("__TOOLCHAIN__" . (lambda ()
                         (completing-read "Toolchain: " '("clang" "gcc") nil t))))
  :after-creation
  (lambda (dir)
    (cl-destructuring-bind (c . cxx)
        (assoc (cdr (assoc "__TOOLCHAIN__" (assoc 'repls skeletor-project-spec)))
               '(("clang" . "clang++") ("gcc" . "g++")) #'string-equal)
      (skeletor--log-info "Initialising project using cmake with %s" c)
      (skeletor-shell-command (format "CC=%s CXX=%s cmake -B build"
                                      (shell-quote-argument c)
                                      (shell-quote-argument cxx))
                                    dir))
    (let ((default-directory dir))
      (skeletor--log-note "Creating link to compile_commands.json")
      (make-symbolic-link "./build/compile_commands.json" "compile_commands.json" t))))
