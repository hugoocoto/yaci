CC = cc

all: pollNotWindowShouldClose.so

pollNotWindowShouldClose.so: pollNotWindowShouldClose.c raylib/src/libraylib.so
	$(CC) -shared -Wall -Wextra -ggdb -fPIC -o $@ pollNotWindowShouldClose.c  

raylib/src/libraylib.so:
	if [[ ! -d "raylib" ]]; then git clone --depth 1 https://github.com/raysan5/raylib.git raylib; fi
	cd raylib/src/ && make PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=SHARED


cleanall:
	rm -rf raylib pollNotWindowShouldClose.so

