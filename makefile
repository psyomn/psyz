all: build test

build:
	zig build

test:
	zig build test

release:
	zig build -Drelease-safe

clean:
	rm -rf zig-cache/ zig-out/
