.PHONY: all watch

all:
	./node_modules/.bin/mocha --compilers ls:LiveScript *.ls

watch:
	./node_modules/.bin/mocha --compilers ls:LiveScript --watch *.ls
