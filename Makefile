all: build

build:
	node ./node_modules/jison/lib/cli.js src/made-view.y src/made-view.l
	mv ./made-view.js ./lib/parser.js