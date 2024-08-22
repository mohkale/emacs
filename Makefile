MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CWD := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

TANGLE_INDEX := $(CWD)/etc/tangle/index.txt
TANGLE_SKIP := $(CWD)/etc/tangle/skip.txt
TANGLE_KEEP := $(CWD)/etc/tangle/keep.txt
FILTERED_TANGLE_INDEX := $(CWD)/etc/tangle/index2.txt

STRAIGHT_BUILD := $(XDG_CACHE_HOME)/emacs/straight/build
EMACS_CC_ARGS := \
	--load $(CWD)/quick-init.el \
	--eval '(setq create-lockfiles nil)' \
	--eval '(setq load-path (append (file-expand-wildcards "$(STRAIGHT_BUILD)/*") load-path))' \
	--eval '(setq native-comp-eln-load-path (append (list "$(CWD)/site-lisp/eln-cache") (bound-and-true-p native-comp-eln-load-path)))' \
	--directory $(CWD)/site-lisp \
	--eval '(byte-compile-disable-warning (quote lexical))' \
	--eval '(byte-compile-disable-warning (quote docstrings))'

$(V).SILENT:

.PHONY: help
help:
	@echo "Mohkales Emacs Dotfiles"
	@echo
	@echo  "   _______ _______ _______    _______ _______ _______ ______ _______ "
	@echo  "  |     __|    |  |   |   |  |    ___|   |   |   _   |      |     __|"
	@echo  "  |    |  |       |   |   |  |    ___|       |       |   ---|__     |"
	@echo  "  |_______|__|____|_______|  |_______|__|_|__|___|___|______|_______|"
	@echo
	@echo "Available targets:"
	@echo "  help"
	@echo "    Show this help message and exit"
	@echo "  clean"
	@echo "    Cleanup tangled and bytecompiled files"
	@echo "  tangle"
	@echo "    Bootstrap elisp files from init.org for my config"
	@echo "  run"
	@echo "    Run emacs in the terminal"
	@echo "  bytecompile"
	@echo "    Bytecompile elisp files produced by tangle"
	@echo "  nativecompile"
	@echo "    Native compile elc files produced by bytecompile"
	@echo $(FILTERED_TANGLE_INDEX)

.PHONY: clean
clean:
	@for file in $(CWD)/site-lisp $(CWD)/init.el $(CWD)/early-init.el $(CWD)/quick-init.el; do  \
		echo "[CLEAN] $${file}";                                                                \
		rm -rf "$${file}";                                                                      \
	done

.PHONY: tangle
tangle:
	@echo "[tangle] $(CWD)/init.org"
	org-tangle -i $(TANGLE_INDEX) $(CWD)/init.org

$(TANGLE_INDEX): tangle
$(TANGLE_SKIP):  tangle
$(TANGLE_KEEP):  tangle

$(FILTERED_TANGLE_INDEX): $(TANGLE_INDEX)
	grep -v --fixed-strings -f $(TANGLE_SKIP) "$^" |    \
	    if [ -z "$$(cat $(TANGLE_KEEP))" ]; then        \
	        cat;                                        \
	    else                                            \
	        grep --fixed-strings -f $(TANGLE_KEEP);     \
	    fi > "$@"

.PHONY: run
run:
	@echo "[run] $(CWD)"
	emacs -nw --init-directory=$(CWD) --debug-init

.PHONY: bytecompile
bytecompile: $(FILTERED_TANGLE_INDEX)
	@set -e; while read -r file; do \
	    echo "[CC] $$file"; \
	    emacs -Q --batch $(EMACS_CC_ARGS) -f batch-byte-compile "$$file"; \
	done < "$^"

.PHONY: nativecompile
nativecompile: bytecompile $(FILTERED_TANGLE_INDEX)
	@set -e; while read -r file; do \
	    echo "[NCC] $$file"; \
	    emacs -Q --batch $(EMACS_CC_ARGS) -f batch-native-compile "$$file"; \
	done < "$(FILTERED_TANGLE_INDEX)"

.PHONY: list-straight-changesets
list-straight-changesets:
	find "$$XDG_CACHE_HOME/emacs/straight/repos" -mindepth 1 -maxdepth 1 | \
	    while read -r repo; do \
	        if output=$$(git -C "$$repo" diff @ @{upstream} --name-only); then \
	            if [ -n "$$output" ]; then \
					echo "$$repo:0: info: Upstream has changes"; \
                fi; \
            else \
                echo "$$repo:0: error: Failed to query upstream"; \
	        fi \
	    done
