.PHONY: all clean

export PATH := ../../node_modules/.bin:$(PATH)

clean:
	rm -f build.ninja
	rm -f to.txt

all: configure build

configure:
	lsc configure.ls

build:
	ninja
	
