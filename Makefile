NODE_MODULES=ui/node_modules

GO=go
NPM=cd ui && npm
BIN=Brucheion

NODE_MODULES=ui/node_modules

.PHONY: all build build-ui test clean dev deps

all: deps test build

.PHONY: build
build: build-ui brucheion

.PHONY: brucheion
brucheion:
	pkger
	$(GO) build -o $(BIN) -v

.PHONY: build-ui
	$(NPM) run build

test:
	$(GO) test -v ./...
	cd ui && npm test

clean:
	$(GO) clean
	rm -f $(BIN)
	rm -r $(NODE_MODULES)

dev:
	$(NPM) run dev

deps: $(NODE_MODULES)

$(NODE_MODULES): ui/package.json ui/package-lock.json
	$(NPM) install
