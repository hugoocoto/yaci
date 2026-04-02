OUT = yaci
CC = cc
OBJ_DIR = obj
FLAGS = -Wall -Wextra -g -Werror `pkg-config --cflags readline`
LIBS = -lm -lffi `pkg-config --libs readline`
INCLUDES = -Isrc

SRC = $(wildcard src/*.c) src/lex.c src/parser.tab.c
OBJ = $(patsubst src/%.c,$(OBJ_DIR)/%.o,$(SRC)) obj/lex.o obj/parser.tab.o
HEADERS = $(wildcard src/*.h) 

.PHONY: all clean package compile test cleanall

all: compile 

compile: $(OUT)

$(OUT): $(OBJ) 
	@if ! pkg-config --exists readline; then echo "readline not found!"; exit 1; fi
	$(CC) $(FLAGS) $^ -o $@ $(LIBS)

$(OBJ_DIR)/%.o: src/%.c makefile $(HEADERS) src/parser.tab.h
	@mkdir -p $(dir $@)
	$(CC) $(FLAGS) $(INCLUDES) -c $< -o $@ 

src/lex.c: src/lex.l $(HEADERS) src/parser.tab.h
	flex -o src/lex.c src/lex.l 

src/parser.tab.c: src/parser.tab.h src/parser.y $(HEADERS) 
	bison -bsrc/parser -d src/parser.y 

src/parser.tab.h: src/parser.y $(HEADERS) 
	bison -bsrc/parser -d src/parser.y 

clean:
	rm -rf $(OBJ_DIR) test ./src/parser.tab.* ./src/lex.c

cleanall: clean
	rm -rf $(OUT) $(OUT).zip readline

test: 
	./tests/all.sh

package: $(OUT).zip

$(OUT).zip: $(SRC) $(HEADERS) makefile README.md tests/* 
	zip $(OUT).zip $^ --update

# -------- Build readline --------

install-readline: readline/Makefile
	cd readline && make 
	cd readline && sudo make install 1>/dev/null

readline/Makefile: 
	[[ -d "readline" ]] || git clone --depth 1 https://git.savannah.gnu.org/git/readline.git
	cd readline && ./configure
