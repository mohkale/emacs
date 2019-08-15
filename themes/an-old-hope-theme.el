; -*- lexical-binding: t; -*-
(require 'color)

(deftheme an-old-hope
  "emacs theme inspired by a galaxy far far away...
this theme is largely just a shot for shot copy of jesseleite/an-old-hope-syntax-atom
ported to emacs because I refuse to live with an IDE that doesn't look like it XD.
This theme isn't compatible with emacs in the terminal yet, when I find an easy way
to approximate true-color colors to non-true-color colors, then I'll add support for
it.")

(defmacro css-hsl-to-color-hsl (h s l)
  "converts css style HSL values to a 'color compatible list"
  `(list (/ ,h 360.0) (/ ,s 100.0) (/ ,l 100.0)))

(defun color-hsl-to-css-rgb-hex (hsl)
  "converts 'color type HSL values to a css RGB hex string"
  (let ((rgb (apply 'color-hsl-to-rgb hsl)))
    (apply 'color-rgb-to-hex (add-to-list 'rgb 2 t))))

(defmacro color-generate-list-manipulation-function-macro (func-type color-func)
  `(defun ,(intern (concat "color-hsl-" func-type "-list")) (hsl percent)
       (apply (quote ,color-func) (add-to-list 'hsl percent t))))

(defmacro color-generate-hue-manipulate-function-macro (func-name manfunc)
  `(defun ,(intern (concat "color-hsl-" func-name "-hue")) (hsl arg)
     (let ((hsl2 (copy-list hsl))
           (scaled-arg (,manfunc (car hsl) (/ arg 360.0) )))
       (setcar hsl2 (min 1 (max 0 scaled-arg))) ;; non-negative, < 1
       hsl2))) ;; return new hsl list from function

(color-generate-list-manipulation-function-macro "lighten" color-lighten-hsl)                  ; increases lighting value
(color-generate-list-manipulation-function-macro "darken" color-darken-hsl)                    ; decreases lighting value
(color-generate-list-manipulation-function-macro "saturate" color-saturate-hsl)                ; increases saturation value
(color-generate-list-manipulation-function-macro "desaturate" color-desaturate-hsl)            ; decreases saturation value

(color-generate-hue-manipulate-function-macro "increment" +)
(color-generate-hue-manipulate-function-macro "decrement" -)

;;; Color Values Are Stored as HSL
(let* ((theme-name 'an-old-hope)
       (cls t)

       ;;; general themed definitions
       (very-light-grey-hsl (css-hsl-to-color-hsl 228 7 81)) ; shades of the millenium falcon
       (light-grey-hsl      (css-hsl-to-color-hsl 228 7 55))
       (grey-hsl            (css-hsl-to-color-hsl 228 7 44))
       (dark-grey-hsl       (css-hsl-to-color-hsl 228 7 29))
       (very-dark-grey-hsl  (css-hsl-to-color-hsl 228 7 12))

       (vader     (css-hsl-to-color-hsl 352  81 58)) ; Vader's lightsaber.
       (luke      (css-hsl-to-color-hsl  25  86 55)) ; Luke's pilot uniform.
       (threepio  (css-hsl-to-color-hsl  50  74 61)) ; Human cyborg relations.
       (yoda      (css-hsl-to-color-hsl 107  40 57)) ; Fear is the path to the dark side.
       (artoo     (css-hsl-to-color-hsl 196  64 58)) ; Whistle. Bloop.

       ;; un conventional an-old-hope colors
       (purple-hsl    (css-hsl-to-color-hsl 313  32 60))
       (turquoise-hsl (css-hsl-to-color-hsl 165  70 65))
       (black-hsl     (css-hsl-to-color-hsl 240   6 14))

       ;;; color bindings as css style hash-hex
       ;; millenium falcon colors are fine as they are
       (very-light-grey (color-hsl-to-css-rgb-hex very-light-grey-hsl))
       (light-grey      (color-hsl-to-css-rgb-hex light-grey-hsl))
       (grey            (color-hsl-to-css-rgb-hex grey-hsl))
       (dark-grey       (color-hsl-to-css-rgb-hex dark-grey-hsl))
       (very-dark-grey  (color-hsl-to-css-rgb-hex very-dark-grey-hsl))

       ;;  every color should have a regular, dimmed and an intense variant
       (red (color-hsl-to-css-rgb-hex vader))
       (red-dim (color-hsl-to-css-rgb-hex (color-hsl-desaturate-list vader 21)))
       (red-int (color-hsl-to-css-rgb-hex (color-hsl-saturate-list (color-hsl-increment-hue vader 8) 9)))

       (orange (color-hsl-to-css-rgb-hex luke))
       (orange-dim (color-hsl-to-css-rgb-hex (color-hsl-lighten-list (color-hsl-desaturate-list luke 26) 5)))
       (orange-int (color-hsl-to-css-rgb-hex (color-hsl-lighten-list luke 10)))

       (yellow (color-hsl-to-css-rgb-hex threepio))
       (yellow-dim (color-hsl-to-css-rgb-hex (color-hsl-darken-list threepio 30)))
       (yellow-int (color-hsl-to-css-rgb-hex (color-hsl-saturate-list threepio 26)))

       (green (color-hsl-to-css-rgb-hex yoda))
       (green-dim (color-hsl-to-css-rgb-hex (color-hsl-desaturate-list (color-hsl-decrement-hue yoda  7) 10)))
       (green-int (color-hsl-to-css-rgb-hex (color-hsl-saturate-list (color-hsl-increment-hue yoda 13) 10)))

       (blue (color-hsl-to-css-rgb-hex artoo))
       (blue-dim (color-hsl-to-css-rgb-hex (color-hsl-desaturate-list (color-hsl-increment-hue artoo 4) 20)))
       (blue-int (color-hsl-to-css-rgb-hex (color-hsl-lighten-list (color-hsl-saturate-list (color-hsl-increment-hue artoo 24) 20) 6)))

       (purple (color-hsl-to-css-rgb-hex purple-hsl))
       (purple-dim (color-hsl-to-css-rgb-hex (color-hsl-lighten-list purple-hsl 10)))
       (purple-int (color-hsl-to-css-rgb-hex (color-hsl-saturate-list (color-hsl-decrement-hue purple-hsl 3) 18)))

       (turquoise (color-hsl-to-css-rgb-hex turquoise-hsl))
       (turquoise-dim (color-hsl-to-css-rgb-hex (color-hsl-lighten-list (color-hsl-desaturate-list turquoise-hsl 15) 10)))
       (turquoise-int (color-hsl-to-css-rgb-hex (color-hsl-darken-list  (color-hsl-saturate-list   turquoise-hsl 20) 10)))

       (black (color-hsl-to-css-rgb-hex black-hsl))
       (black-dim (color-hsl-to-css-rgb-hex (color-hsl-lighten-list (color-hsl-saturate-list black-hsl 4) 6)))
       (black-int (color-hsl-to-css-rgb-hex (color-hsl-darken-list black-hsl 100)))

       ;;; specific color definitions for limited purposes
       (line-highlight-bg (color-hsl-to-css-rgb-hex (color-hsl-darken-list dark-grey-hsl 8)))

       ;; rainbow delimeters color list
       ;; colors taken from [here](https://github.com/gastrodia/rainbow-brackets)
       ;; colors 5-8 just recycle 1-4, maybe come up with more.
       (rainbow-delimiters-foregrounds '("#E6B422" "#C70067" "#00A960" "#FC7482"
                                         "#E6B422" "#C70067" "#00A960" "#FC7482"))

       (debug (color-hsl-to-css-rgb-hex (css-hsl-to-color-hsl 239 100 20)))) ; bright blue
  (custom-theme-set-faces
   theme-name

   ;;; basic
   `(cursor ((,cls (:background ,red))))
   `(custom-button ((,cls (:background ,very-dark-grey :foreground ,very-light-grey :box (:line-width 2 :style released-button)))))

   ;; sets the general foreground and background colors
   `(default ((,cls (:background ,very-dark-grey :foreground ,very-light-grey))))
   `(default-italic ((,cls (:italic t :inherit default))))
   `(hl-line ((,cls (:background ,line-highlight-bg)))) ; NOTE current line
   `(fringe ((,cls (:background ,black)))) ; NOTE: defines bars to the left and right, after line number when applicable
   ;; `(vi-tilde-fringe-face ((,cls ((:inherit fringe)))))
   `(vertical-border ((,cls (:foreground ,very-light-grey)))) ; NOTE seperator between windows

   ;; errors, successes and warnings and other highlights
   `(error   ((,cls (:background ,red    :distant-foreground ,red    :foreground ,very-dark-grey :inherit bold))))
   `(success ((,cls (:background ,green  :distant-foreground ,green  :foreground ,very-dark-grey :inherit bold))))
   `(warning ((,cls (:background ,yellow :distant-foreground ,yellow :foreground ,very-dark-grey :inherit bold))))
   `(highlight ((,cls (:foreground ,very-dark-grey :background ,turquoise :distant-foreground ,turquoise :inherit bold))))
   `(region ((,cls (:background ,dark-grey :weight bold)))) ; NOTE visual mode selection
   `(secondary-selection ((,cls (:inherit region)))) ; TODO no idea what this is for, document it
   `(lazy-highlight ((,cls (:background ,orange :foreground ,black-dim)))) ; color for matches for in process searches
   `(isearch ((t (:inherit lazy-highlight :weight bold)))) ; NOTE inherited by evil-ex-search
   `(shadow ((,cls (:foreground ,light-grey)))) ; shadowed text, undermines actual text
   `(header-line ((,cls (:background ,very-dark-grey :foreground ,blue)))) ; shown at the top of some buffers, including in HEXL mode and helm
   `(match ((,cls (:foreground ,green-dim)))) ; TODO no idea what this is for, document it

   ;; line numbers
   `(line-number ((,cls (:background ,black :foreground ,very-light-grey :weight normal :underline nil))))
   `(line-number-current-line ((,cls (:foreground ,blue :inherit linum))))

   ;; font locks and syntax highlighting
   `(font-lock-builtin-face ((,cls (:foreground ,blue))))
   `(font-lock-comment-face ((,cls (:foreground ,grey  :slant ,(if (and nil spacemacs-theme-comment-italic) 'italic 'normal)))))
   `(font-lock-keyword-face ((,cls (:foreground ,green :slant ,(if (and nil spacemacs-theme-keyword-italic) 'italic 'normal)))))
   `(font-lock-constant-face ((,cls (:foreground ,red :inherit bold))))
   `(font-lock-function-name-face ((,cls (:foreground ,yellow-int))))
   `(font-lock-negation-char-face ((,cls (:foreground ,red))))
   `(font-lock-preprocessor-face ((,cls (:foreground ,green-dim))))
   `(font-lock-string-face ((,cls (:foreground ,blue))))
   `(font-lock-doc-face ((,cls (:inherit font-lock-string-face))))                                     ; TODO optional bg
   `(font-lock-type-face ((,cls (:foreground ,red))))
   `(font-lock-warning-face ((,cls (:background ,yellow-int :distant-foreground ,yellow-int :foreground ,very-dark-grey :underline nil :inherit bold))))
   `(font-lock-variable-name-face ((,cls (:foreground ,yellow-int))))

   ;; rainbow delimeters are pretty
   `(rainbow-delimiters-depth-1-face ((,cls (:foreground ,(nth 0 rainbow-delimiters-foregrounds)))))
   `(rainbow-delimiters-depth-2-face ((,cls (:foreground ,(nth 1 rainbow-delimiters-foregrounds)))))
   `(rainbow-delimiters-depth-3-face ((,cls (:foreground ,(nth 2 rainbow-delimiters-foregrounds)))))
   `(rainbow-delimiters-depth-4-face ((,cls (:foreground ,(nth 3 rainbow-delimiters-foregrounds)))))
   `(rainbow-delimiters-depth-5-face ((,cls (:foreground ,(nth 4 rainbow-delimiters-foregrounds)))))
   `(rainbow-delimiters-depth-6-face ((,cls (:foreground ,(nth 5 rainbow-delimiters-foregrounds)))))
   `(rainbow-delimiters-depth-7-face ((,cls (:foreground ,(nth 6 rainbow-delimiters-foregrounds)))))
   `(rainbow-delimiters-depth-8-face ((,cls (:foreground ,(nth 7 rainbow-delimiters-foregrounds)))))

   ;; hyperlinks and path links
   `(link ((,cls (:foreground ,blue)))) ; hyperlink
   `(link-visited ((,cls (:foreground ,turquoise))))

   ;;; modeline/spaceline
   ;; NOTE mode-line faces below only affect some portions of the mode line
   ;;      these include the buffer name, the mode list & buffer percentage.
   `(mode-line ((,cls (:box (:line-width 1 :color ,very-light-grey :style none)
                            :background ,very-light-grey ; also winum color
                            :foreground ,very-dark-grey))))
   ;; TODO configure mode-line-inactive as well
   ; NOTE powerline-active-0 and powerline-inactive-0 also exist, but I have no idea what they do
   `(powerline-active1 ((,cls (:background ,black :foreground ,very-light-grey :inherit mode-line)))) ; major mode indicator
   `(powerline-active2 ((,cls (:background ,black :foreground ,very-light-grey :inherit mode-line)))) ; file-format + cursor-pos

   ;;; evil
   ;; permenent color of highlighted search results. Can be hidden using :nohlsearc
   `(evil-search-highlight-persist-highlight-face ((,cls (:background ,line-highlight-bg :foreground ,orange :inherit bold))))
   `(vimish-fold-overlay ((,cls (:background ,line-highlight-bg))))

   ;;; minibuffer & helm
   `(minibuffer-prompt ((,cls (:foreground ,yellow :weight bold)))) ; NOTE optional read only text preceding minibuffer input
   `(helm-M-x-key ((,cls (:foreground ,blue :inherit bold))))
   `(helm-source-header ((,cls (:foreground "#220833" :background ,yellow :family "sans serif" :weight bold :height 1.3)))) ; TODO use real color
   `(helm-selection ((,cls (:background ,red :distant-foreground ,black)))) ; active row
   `(helm-visible-mark ((,cls (:background ,blue-int))))
   ;;  helm buffer select
   `(helm-buffer-process ((,cls (:foreground ,turquoise-int)))) ; NOTE source for buffer
   `(helm-buffer-size ((,cls (:foreground ,orange :inherit bold))))
   ; file type based highlightings
   `(helm-buffer-directory ((,cls (:foreground ,yellow-int))))
   `(helm-buffer-archive ((,cls (:inherit helm-buffer-directory))))
   `(helm-buffer-file ((,cls (:foreground ,turquoise-int :inherit helm-buffer-directory))))
   `(helm-buffer-modified ((,cls (:foreground ,turquoise-int :inherit (bold helm-buffer-directory)))))
   `(helm-buffer-not-saved ((,cls (:foreground ,orange :inherit helm-buffer-directory))))
   `(helm-buffer-saved-out ((,cls (:foreground ,red :inherit helm-buffer-directory)))) ; NOTE saved outside of emacs
   ;; helm find file
   `(helm-ff-prefix ((,cls (:foreground ,black :background ,yellow-int)))) ; prefix for helm new file
   `(helm-ff-directory ((,cls (:inherit helm-buffer-directory))))
   `(helm-ff-dirs ((,cls (:inherit helm-ff-directory))))
   `(helm-ff-dotted-directory ((,cls (:foreground ,yellow-dim :inherit helm-ff-directory))))
   `(helm-ff-symlink ((,cls (:foreground ,grey))))
   `(helm-ff-dotted-symlink-directory ((,cls (:inherit helm-ff-symlink))))
   `(helm-ff-invalid-symlink ((,cls (:strike-through ,red-int :inherit helm-ff-symlink))))
   `(helm-ff-truename ((,cls (:foreground ,green-int :inherit helm-ff-file)))) ; NOTE shown alongside symlinks, is symlink dest
   `(helm-ff-file ((,cls (:inherit helm-buffer-file))))
   `(helm-ff-denied ((,cls (:foreground ,very-dark-grey :background ,red-int :strike-through ,red-int :inherit (bold helm-buffer-file)))))
   `(helm-ff-executable ((,cls (:inherit (bold helm-buffer-file)))))
   `(helm-ff-socket ((,cls (:foreground ,purple-int :inherit helm-buffer-file))))
   `(helm-ff-socket ((,cls (:foreground ,orange-int :inherit helm-buffer-file))))
   `(helm-ff-suid ((,cls (:foreground ,blue :inherit helm-ff-directory))))
   ;; helm grep
   `(helm-grep-cmd-line ((,cls (:inherit font-lock-type-face)))) ; NOTE grep failed cl message
   `(helm-grep-file ((,cls (:foreground ,turquoise-int :inherit bold)))) ; NOTE file in which grep matched
   `(helm-grep-finish ((,cls (:foreground ,red-int)))) ; NOTE grep info in mode line
   `(helm-grep-lineno ((,cls (:foreground ,orange-int :inherit bold))))
   `(helm-grep-match ((,cls (:foreground ,red-int :inherit bold)))) ; NOTE no affect when color=always
   ;; bookmarks
   `(helm-bookmark-addressbook ((,cls (:foreground ,orange-int))))
   `(helm-bookmark-directory ((,cls (:foreground ,yellow-int))))
   `(helm-bookmark-file ((,cls (:foreground ,turquoise-int))))
   `(helm-bookmark-file-not-found ((,cls (:foreground ,very-light-grey :strike-through ,red))))
   `(helm-bookmark-gnus ((,cls (:foreground ,purple-int))))
   `(helm-bookmark-info ((,cls (:foreground ,green-int))))
   `(helm-bookmark-man ((,cls (:foreground ,orange-dim))))
   `(helm-bookmark-w3m ((,cls (:foreground ,yellow-dim))))

   ;;; flycheck
   `(flycheck-info ((,cls (:underline (:style wave :color ,green)))))
   `(flycheck-warning ((,cls (:underline (:style wave :color ,yellow)))))
   `(flycheck-duplicate ((,cls (:underline (:style wave :color ,orange)))))
   `(flycheck-incorrect ((,cls (:underline (:style wave :color ,red)))))
   `(flycheck-fringe-info ((,cls (:foreground ,green-int :inherit fringe))))
   `(flycheck-fringe-warning ((,cls (:foreground ,yellow-int :inherit fringe))))
   `(flycheck-fringe-error ((,cls (:foreground ,red-int :inherit fringe))))

   ;;; frog jump buffer and avy
   `(avy-background-face ((,cls (:foreground ,grey))))
   `(avy-lead-face ((,cls (:background ,red-int :foreground "white"))))
   `(avy-lead-face-0 ((,cls (:background ,blue-int :foreground "white"))))
   `(avy-lead-face-1 ((,cls (:background ,very-light-grey :foreground ,very-dark-grey))))
   `(avy-lead-face-2 ((,cls (:background ,purple-int :foreground "white"))))
   `(frog-menu-border ((,cls (:background ,very-light-grey :foreground ,very-light-grey))))
   `(frog-menu-posframe-background-face ((,cls (:background ,very-light-grey))))

   ;;; company - intellisense
   ;; NOTE foreground-color  very-dark-grey
   ;;      background-color  very-light-grey
   ;;      active-foreground very-light-grey
   ;;      active-background blue
   ;;      sp-color          turquoise-int
   `(company-tooltip-mouse ((,cls (:foreground ,turquoise-int))))
   `(company-template-field ((,cls (:foreground ,turquoise-int))))

   ;; scrollbar
   `(company-scrollbar-bg ((,cls (:background ,very-light-grey :foreground ,very-light-grey))))
   `(company-scrollbar-fg ((,cls (:background ,dark-grey       :foreground ,dark-grey))))

   ;; NOTE preview is for the leading text for a the sole match on a line
   `(company-preview ((,cls (:foreground ,blue-int :weight bold :inherit hl-line))))
   `(company-preview-common ((,cls (:inherit company-preview))))
   `(company-preview-search ((,cls (:foreground ,orange-int :weight normal :inherit company-preview))))

   ;; NOTE tooltip is the drop down menu which shows up when multiple results exist
   `(company-tooltip ((,cls (:background ,very-light-grey :foreground ,very-dark-grey :inherit bold))))
   `(company-tooltip-common ((,cls (:foreground ,blue-int :inherit company-tooltip))))
   `(company-tooltip-selection ((,cls (:foreground ,very-light-grey :background ,blue-int))))
   `(company-tooltip-common-selection ((,cls (:foreground ,very-dark-grey :background ,blue-int :inherit company-tooltip-common))))
   `(company-tooltip-search ((,cls (:foreground ,orange :inherit company-tooltip))))
   `(company-tooltip-search-common ((,cls (:inherit company-tooltip-search))))
   `(company-tooltip-search-selection ((,cls (:background ,blue-int :inherit company-tooltip-search))))

   ;; NOTE annotations are extra information in stdout
   `(company-tooltip-annotation ((,cls (:weight bold :foreground ,grey))))
   `(company-tooltip-annotation-selection ((,cls (:foreground ,turquoise-int :background ,blue-int :inherit company-tooltip-annotation))))

  ;;; set spacemacs evil state fac  `(spacemacs-emacs-face ((,cls (:background ,(color-hsl-to-css-rgb-hex yoda)))))
  `(spacemacs-evilified-face ((,cls (:foreground ,very-dark-grey :background ,red))))
  `(spacemacs-hybrid-face ((,cls (:foreground ,very-dark-grey :background ,orange-dim))))
  `(spacemacs-iedit-face ((,cls (:foreground ,very-dark-grey :background ,orange))))
  `(spacemacs-iedit-insert-face ((,cls (:foreground ,very-dark-grey :background ,orange))))
  `(spacemacs-lisp-face ((,cls (:foreground ,very-dark-grey :background ,green))))
  `(spacemacs-visual-face ((,cls (:foreground ,very-dark-grey :background ,turquoise))))
  `(spacemacs-normal-face ((,cls (:foreground ,very-dark-grey :background ,yellow))))
  `(spacemacs-insert-face ((,cls (:foreground ,very-dark-grey :background ,blue))))
  `(spacemacs-motion-face ((,cls (:foreground ,very-dark-grey :background ,purple))))
  `(spacemacs-replace-face ((,cls (:foreground ,very-dark-grey :background ,very-light-grey))))

   ;;;; custom mode variants
   ;;; whitespace-mode
   `(whitespace-trailing ((,cls (:foreground "yellow" :background ,red))))
   `(whitespace-space ((,cls (:foreground ,dark-grey))))

   ;;; auto-highlight-symbol mode
   ;; Note: distant foreground is meaningless here because the faces are always given pririty
   `(ahs-definition-face ((,cls (:background ,blue-dim :distant-foreground ,blue-dim :foreground ,dark-grey))))
   `(ahs-edit-mode-face ((,cls (:background ,red-dim :distant-foreground ,red-dim :foreground ,very-light-grey))))
   `(ahs-face ((,cls (:background ,very-light-grey :foreground ,black :inherit bold)))) ; NOTE matching selections
   `(ahs-plugin-whole-buffer-face ((,cls (:background ,blue :distant-foreground ,green :foreground ,black))))
   `(ahs-plugin-bod-face ((,cls (:background ,blue-int :distant-foreground ,blue-int :foreground ,black))))
   `(ahs-plugin-defalt-face ((,cls (:background ,orange-dim :distant-foreground ,orange-dim :foreground ,black))))
   `(ahs-warning-face ((,cls (:foreground ,red-dim))))

   ;;; compilation mode
   `(compilation-line-number ((,cls (:foreground ,yellow))))
   `(compilation-column-number ((,cls (:inherit font-lock-doc-face))))
   ;; NOTE also represents value count in mode line
   ;; `(compilation-error ((,cls (:background ,red-int :distant-foreground ,red-int :foreground ,very-dark-grey))))
   ;; `(compilation-info ((,cls (:background ,green-int :distant-foreground ,green-int :foreground ,very-dark-grey))))
   ;; `(compilation-warning ((,cls (:background ,orange-int :distant-foreground ,orange-int :foreground ,very-dark-grey))))
   `(compilation-error ((,cls (:foreground ,red-int :inherit bold))))
   `(compilation-info ((,cls (:foreground ,green-int :inherit bold))))
   `(compilation-warning ((,cls (:foreground ,orange-int :inherit bold))))
   ;; NOTE theses only represent the exit status indicator
   `(compilation-mode-line-exit ((,cls (:foreground ,very-dark-grey))))
   `(compilation-mode-line-fail ((,cls (:foreground ,very-dark-grey))))
   `(compilation-mode-line-run ((,cls (:foreground ,very-dark-grey))))

   ;;; markdown-mode
   `(markdown-code-face ((,cls ())))

   ;;; org-mode
   `(org-link ((,cls (:foreground ,turquoise :inherit bold))))
   `(org-footnote ((,cls (:foreground ,blue))))
   ;; Overridden by hl-todo-keyword-faces
   `(org-todo ((,cls (:foreground ,purple-int :inherit bold))))
   `(org-done ((,cls (:foreground ,green-int :inherit bold))))
   ;; `(org-warning ((,cls (:foreground ))))
   `(org-upcoming-deadline ((,cls (:foreground ,red-dim))))
   `(org-warning ((,cls (:foreground ,orange :inherit bold))))
   `(org-scheduled-today ((,cls (:foreground ,green-int)))))

  (custom-theme-set-variables
   theme-name

   `(hl-todo-keyword-faces '(("TODO"        . ,red)
                             ("NEXT"        . ,red)
                             ("THEM"        . ,purple)
                             ("PROG"        . ,blue-int)
                             ("OKAY"        . ,blue-int)
                             ("DONT"        . ,green-int)
                             ("FAIL"        . ,red)
                             ("DONE"        . ,green-int)
                             ("NOTE"        . ,yellow-int)
                             ("KLUDGE"      . ,yellow-int)
                             ("HACK"        . ,yellow-int)
                             ("TEMP"        . ,yellow-int)
                             ("FIXME"       . ,orange)
                             ("WARN"        . ,orange)
                             ("XXX+"        . ,orange)
                             ("\\?\\?\\?+"  . ,orange))))

  (provide-theme 'an-old-hope))

