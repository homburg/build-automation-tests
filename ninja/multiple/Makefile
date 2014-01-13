.PHONY: all clean configure

export PATH := ../../node_modules/.bin:$(PATH)

all: configure build

clean:
	rm -rf build
	rm -f build.ninja

configure:
	lsc configure.ls

build:
	ninja

