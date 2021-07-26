#     _                    __  __       _         __ _ _
#    | | __ ___   ____ _  |  \/  | __ _| | _____ / _(_) | ___
# _  | |/ _` \ \ / / _` | | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
#| |_| | (_| |\ V / (_| | | |  | | (_| |   <  __/  _| | |  __/
# \___/ \__,_| \_/ \__,_| |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
#
# A simple java Makefile project template.
#
# Use this when you want to make a java project that doesn't need dependency management
# or other eccentricities. Just compile and run. The project is divided as you'd expect.
# Source code files go into `./src/`, configuration into `./etc/` and any external java
# libraries should be placed into `./lib/` as jar files. These libraries will be copied
# into the `./bin/` directory after compilation. Make sure to update your projects Jar
# [[https://stackoverflow.com/a/21777294][manifest]] files classpath whenever you add a new library. If the class-path entry gets
# too long you can spread it over [[https://stackoverflow.com/a/3057862][multiple]] lines.

.POSIX:

BIN_DIR := bin
SRC_DIR := src
OBJ_DIR := obj
ETC_DIR := etc
LIB_DIR := lib
TARGET  := $(BIN_DIR)/__PROJECT-NAME__.jar

MANIFEST_FILE := $(ETC_DIR)/manifest.mf

SRC := $(shell find $(SRC_DIR) -type f -iname "*.java")
OBJ := $(SRC:$(SRC_DIR)/%.java=$(OBJ_DIR)/%.class)
LIB := $(shell [ -e "$(LIB_DIR)" ] && find $(LIB_DIR) -type f -iname "*.jar")

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

CC := javac
CCFLAGS := -classpath $(SRC_DIR):$(subst $(SPACE),:,$(LIB)):$(CLASSPATH)
undefine CLASSPATH

LD := jar
LDFLAGS :=

JAVA_OPTIONS := $(_JAVA_OPTIONS)
undefine _JAVA_OPTIONS

all: $(TARGET)

.PHONY: all clean run rebuild rebuild-run
$(V).SILENT:

$(OBJ_DIR)/%.class: $(SRC_DIR)/%.java
	[ -e "$(OBJ_DIR)" ] || mkdir -p "$(OBJ_DIR)"
	@echo CC $<
	$(CC) $(CCFLAGS) -d $(OBJ_DIR) $<

$(BIN_DIR)/%.jar: $(LIB_DIR)/%.jar
	@echo CP $< $@
	cp $< $@

$(TARGET): $(MANIFEST_FILE) $(OBJ) $(LIB:$(LIB_DIR)/%.jar=$(BIN_DIR)/%.jar)
	[ -e "$(BIN_DIR)" ] || mkdir -p "$(BIN_DIR)"
	@echo LINK $@
	$(LD) $(LDFLAGS) -cfm $@ $(MANIFEST_FILE) $(OBJ:$(OBJ_DIR)/%=-C $(OBJ_DIR) %)

clean:
	@echo CLEAN $(OBJ_DIR)
	rm -rf main $(OBJ_DIR)/*
	@echo CLEAN $(BIN_DIR)
	rm -rf main $(BIN_DIR)/*

run: $(TARGET)
	java $(CCFLAGS) $(JAVA_OPTIONS) -jar $^

rebuild: clean all
rebuild-run: rebuild run
