OUT = yaci
CC = cc
OBJ_DIR = obj
X = c
FLAGS = -Wall -Wextra -g -Wno-missing-field-initializers -Werror
LIBS = 
INCLUDES = -Isrc

SRC = $(wildcard src/*.c) src/lex.c
OBJ = $(patsubst src/%.c,$(OBJ_DIR)/%.o,$(SRC)) obj/lex.o
HEADERS = $(wildcard src/*.h)

.PHONY: all clean package compile test

all: compile

compile: $(OUT)

$(OUT): $(OBJ) 
	$(CC) $(FLAGS) $^ -o $@ $(LIBS)

$(OBJ_DIR)/%.o: src/%.c makefile $(HEADERS)
	@mkdir -p $(dir $@)
	$(CC) $(FLAGS) -x $(X) $(INCLUDES) -c $< -o $@ 

src/lex.c: src/lex.l $(HEADERS)
	flex -o src/lex.c src/lex.l 

clean:
	rm -rf $(OBJ_DIR) $(OUT) $(OUT).zip test

test: $(SRC) 
	make clean
	$(CC) $(FLAGS) -ggdb -DTEST $(INCLUDES) $^ -o $@ $(LIBS)
	./test && ./tests/all.sh

package: $(OUT).zip

$(OUT).zip: $(SRC) $(HEADERS) makefile README.md tests/* 
	zip $(OUT).zip $^ --update

