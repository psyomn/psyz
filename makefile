all: build test

build:
	zig build

test:
	zig build test

clean:
	rm -rf zig-cache/ zig-out/
