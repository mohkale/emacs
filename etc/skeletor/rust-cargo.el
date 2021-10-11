;; -*- lexical-binding: t -*-
;; A template to bootstrap a [[https://www.rust-lang.org/][rust]] project with cargo.

(skeletor-define-constructor "rust-cargo"
  :title "Rust [cargo]"
  :requires-executables '(("rustc" . "https://www.rust-lang.org/")
                          ("cargo" . "https://doc.rust-lang.org/book/ch01-03-hello-cargo.html"))
  :initialise
  (lambda (spec)
    (let-alist spec
      (skeletor-shell-command (concat "cargo init --color never --vcs none "
                                      (if (yes-or-no-p "Create a binary template instead of a library?")
                                          "--bin "
                                        "--lib ")
                                      (let ((name (read-string "Package name: ")))
                                        (unless (string-empty-p name)
                                          (concat "--name " (shell-quote-argument name) " ")))
                                      .project-name)
                              .project-dir))))
