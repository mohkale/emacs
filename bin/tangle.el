#!/usr/bin/emacs --script
;; -*- coding: utf-8-unix -*-
;; scripted way to tangle an org file without having to create
;; a plain, unconfigured emacs instance first.

(require 'ob-tangle)

(org-babel-tangle-file (concat user-emacs-directory "init.org"))
