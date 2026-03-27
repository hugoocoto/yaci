OUT = yaci
CC = cc
OBJ_DIR = obj
X = c
FLAGS = -Wall -Wextra -g
LIBS = 
INCLUDES = -Isrc

SRC = $(wildcard src/*.c)
OBJ = $(patsubst src/%.c,$(OBJ_DIR)/%.o,$(SRC))
HEADERS = $(wildcard src/*.h)

.PHONY: all clean package compile test

all: compile

compile: $(OUT)

$(OUT): $(OBJ) 
	$(CC) $(FLAGS) $^ -o $@ $(LIBS)

$(OBJ_DIR)/%.o: src/%.c makefile $(HEADERS)
	@mkdir -p $(dir $@)
	$(CC) $(FLAGS) -x $(X) $(INCLUDES) -c $< -o $@ 

clean:
	rm -rf $(OBJ_DIR) $(OUT) $(OUT).zip test

test: $(SRC)
	$(CC) $(FLAGS) -ggdb -DTEST $(INCLUDES) $^ -o test $(LIBS)

package: $(OUT).zip

$(OUT).zip: $(SRC) $(HEADERS) makefile README.md tests/* 
	zip $(OUT).zip $^ --update

