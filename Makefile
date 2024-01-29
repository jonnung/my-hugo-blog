.PHONY: start
start:
	hugo server --disableLiveReload --minify --gc -D
.PHONY: build
build:
	hugo

.PHONY: update
update:
	hugo mod clean
	hugo mod get
	hugo mod tidy

.PHONY: install
install:
	hugo mod npm pack
	npm install

.PHONY: search
search:
	algolia objects import prod_jonnung_blog -F ./public/algolia.ndjson -p 'default'
	
