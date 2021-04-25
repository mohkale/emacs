CC := go
BUILD := bin/__PROJECT-NAME__

.PHONY: build run

build: $(BUILD)
run: build
	./$(BUILD)

$(BUILD): $(shell find cmd/__PROJECT-NAME__ pkg/ -type f)
	@echo "CC $@"
	$(CC) build -o $@ ./cmd/__PROJECT-NAME__

$(V).SILENT: # Assign the V environment variable to not be silent
