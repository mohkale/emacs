.POSIX:

BIN_DIR = bin
SRC_DIR = src
OBJ_DIR = obj
INC_DIR = includes
TARGET  = __MAIN__

TARGET_BIN = $(BIN_DIR)/$(TARGET)

CC = __CCLD__
CCFLAGS = $(shell cat compile_flags.txt)
LDFLAGS = -Wall -pedantic

SRC = $(shell find $(SRC_DIR) -type f -iname "*.cc")
OBJ = $(SRC:$(SRC_DIR)/%.cc=$(OBJ_DIR)/%.o)

all: $(TARGET_BIN)

.PHONY: all clean run rebuild rebuild-run
.SECONDEXPANSION:
$(V).SILENT:

# You can specify any other possible dependencies for each input
# file like so.
# $(SRC_DIR)/main.cc: $(INC_DIR)/foo.hh

# Source files may have optional header file in the includes
# directory which matches their file name.
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cc $$(wildcard $(INC_DIR)/*.hh)
	[ -e "$(OBJ_DIR)" ] || mkdir -p "$(OBJ_DIR)"
	@echo CC $<
	$(CC) $(CCFLAGS) -c $< -o $@

$(TARGET_BIN): $(OBJ)
	[ -e "$(BIN_DIR)" ] || mkdir -p "$(BIN_DIR)"
	@echo LINK $@
	$(CC) $(LDFLAGS) -o $@ $^

clean:
	@echo "CLEAN $(OBJ_DIR)"
	rm -f main $(OBJ_DIR)/*
	@echo "CLEAN $(BIN_DIR)"
	rm -f main $(BIN_DIR)/*

run: $(TARGET_BIN); $^

rebuild: clean all
rebuild-run: rebuild run
