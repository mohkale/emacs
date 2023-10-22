IT := /home/mohkale/.config/emacs/split
STRAIGHT := /home/mohkale/.cache/emacs/straight/build

$(V).SILENT:

.PHONY: clean
clean:
	@echo "[clean] $(IT)/site-lisp"
	if [ -e $(IT)/site-lisp ]; then rm -rf $(IT)/site-lisp; fi
	@echo "[clean] $(IT)/early-init.el"
	if [ -e $(IT)/early-init.el ]; then rm $(IT)/early-init.el; fi

.PHONY: tangle
tangle:
	@echo "[tangle] $(IT)"
	org-tangle -i $(IT)/index.txt $(IT)/init.org

$(IT)/index.txt: tangle

.PHONY: run
run:
	@echo "[tangle] $(IT)"
	emacs -nw --init-directory=$(IT) --debug-init

.PHONY: bytecompile
bytecompile: $(IT)/index.txt
	@set -e; for file in $$(grep -v --fixed-strings -f $(IT)/skip.txt "$^" | if [ -z "$$(cat $(IT)/keep.txt)" ]; then cat; else grep --fixed-strings -f $(IT)/keep.txt; fi); do \
	    echo "[compile] $$file"; \
	    emacs -Q --batch --load $(IT)/quick-init.el --eval '(byte-compile-disable-warning (quote lexical))' --eval '(setq load-path (append (file-expand-wildcards "$(STRAIGHT)/*") load-path))' --directory $(IT)/site-lisp -f batch-byte-compile "$$file"; \
	    echo "[native-compile] $$file"; \
	    emacs -Q --batch --load $(IT)/quick-init.el --eval '(byte-compile-disable-warning (quote lexical))' --eval '(setq load-path (append (file-expand-wildcards "$(STRAIGHT)/*") load-path))' --directory $(IT)/site-lisp -f batch-native-compile "$$file"; \
	done
