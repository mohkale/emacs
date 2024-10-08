;;-*-coding: utf-8;-*-
(define-abbrev-table 'c++-base-mode-abbrev-table
  '(
    ("ns" "namespace" nil :count 1)
    ("us" "using" nil :count 1)
    ("coa" "co_await" nil :count 1)
    ("cor" "co_return" nil :count 1)
    ("coy" "co_yield" nil :count 1)
    ("td" "typedef" nil :count 1)
    ("tn" "typename" nil :count 1)
    ("vt" "virtual" nil :count 1)
    ("ov" "override" nil :count 1)
   ))

(define-abbrev-table 'c-base-mode-abbrev-table
  '(
    ("en" "enum" nil :count 0)
    ("st" "struct" nil :count 0)
    ))

(define-abbrev-table 'csharp-mode-abbrev-table
  '(
    ("cl" "class" nil :count 1)
    ("ns" "namespace" nil :count 1)
    ("pb" "public" nil :count 2)
    ("pv" "private" nil :count 1)
    ("us" "using" nil :count 2)
    ))

(define-abbrev-table 'go-mode-abbrev-table
  '(
    ("im" "import" nil :count 1)
    ("pk" "package" nil :count 2)
    ("st" "struct" nil :count 1)
   ))

(define-abbrev-table 'text-mode-abbrev-table
  '(
    ("bg" "background" nil :count 6)
    ("btw" "by the way" nil :count 0)
    ("def" "definition" nil :count 0)
    ("desc" "description" nil :count 3)
    ("fg" "foreground" nil :count 7)
    ("lhs" "left hand side" nil :count 0)
    ("nev" "negative" nil :count 1)
    ("nve" "negative" nil :count 1)
    ("pov" "point of view" nil :count 0)
    ("pve" "positive" nil :count 1)
    ("rhs" "right hand side" nil :count 0)
    ("teh" "the" nil :count 0)
    ("that're" "that are" nil :count 0)
    ("that've" "that have" nil :count 0)
    ("thatre" "that are" nil :count 0)
    ("thatve" "that have" nil :count 0)
   ))

(define-abbrev-table 'org-mode-abbrev-table
  '(
    ("ex" "example" nil :count 1)
   ))

(define-abbrev-table 'js-mode-abbrev-table
  '(
    ("exp" "export" nil :count 1)
    ("imp" "import" nil :count 1)
    ("req" "require" nil :count 1)
   ))

(define-abbrev-table 'python-mode-abbrev-table
  '(
    ("cont" "continue" nil :count 2)
    ("fr" "from" nil :count 1)
    ("im" "import" nil :count 1)
    ))

(define-abbrev-table 'git-commit-mode-abbrev-table+
  '(
    ("cab" "Co-Authored-By:" nil :count 1)
    ("cl" "Closes:" nil :count 1)
    ))
