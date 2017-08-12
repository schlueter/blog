# Copyright 2017 Brandon Schlueter
#
# This file is part of Blog.
#
# Blog is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Blog is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Blog.  If not, see <http://www.gnu.org/licenses/>.

# For help with the syntax of this file see https://www.gnu.org/software/make/manual/make.html

# Target run when no target is specified (the name doesn't do anything, it must be the first target).
default: help

# Targets which are not the names of files (this improves performance of the makefile)
.PHONY: default dev lint lint-js edit clean watch js-index sass-index index help vars

# Variables
VARS_OLD    := $(.VARIABLES)

SRC_DIR   := src
SRC_INDEX := $(SRC_DIR)/index.html
SRC_JS    := $(shell awk '/js-concat:/,/js-concat\ fi\ /{ if (!/(js-concat:|js-concat\ fi)/)print}' $(SRC_INDEX) | sed -n 's/.*src="\(.*\)".*/\1/p')
SRC_SASS  := $(shell awk '/sass-build:/,/sass-build\ fi\ /{ if (!/(sass-build:|sass-build\ fi)/)print}' $(SRC_INDEX) | sed -n 's/.*href="\(.*\)".*/\1/p')

RELATIVE_STATIC := static
RELATIVE_CSS    := $(RELATIVE_STATIC)/$(shell sed -n 's/.*sass-build:\ \([^ ]*\)\ -->*/\1/p' $(SRC_INDEX))
RELATIVE_JS     := $(RELATIVE_STATIC)/$(shell sed -n 's/.*js-concat:\ \([^ ]*\)\ -->*/\1/p' $(SRC_INDEX))

DEST_DIR    := public
DEST_INDEX  := $(DEST_DIR)/index.html
DEST_STATIC := $(DEST_DIR)/$(RELATIVE_STATIC)
DEST_CSS    := $(DEST_DIR)/$(RELATIVE_CSS)
DEST_JS     := $(DEST_DIR)/$(RELATIVE_JS)

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR   := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))

INFO_COLOR  := '\e[0;34m'
WARN_COLOR  := '\e[1;31m'
CLEAR_COLOR := '\e[0m'

vars: ## List the variables used by this makefile with their values
	$(foreach v,                                        \
		$(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)), \
		$(info $(v) = $($(v))))
	@# Thanks Ise Wisteria (borrowed from https://stackoverflow.com/a/7119460/1054423)
	@# These comments also prevent the "make: Nothing to be done for 'vars'." message

# Help preface:
#
#^ Blog makefile
#^
#^ Usage: `make <target>`
#^
#^ Standard targets:
#^

# Help postface:
#
#$
#$ Target source and helper targets may be viewed in the makefile

help: ## Show this help
	@# print all lines from make files which begin with #^
	@sed -n 's/^#\^ \?//p' $(MAKEFILE_LIST)
	@# find all lines in make files containing ##, sort them, remove lines containing "##", then pretty print them
	@grep -h "## " $(MAKEFILE_LIST) | sort | awk -F ' ## ' ' \
		!/"##"/ { \
			gsub(":.*", "", $$1); \
			printf "%10s :: %s\n", $$1, $$2; \
	  }'
	@# print all lines from make files which begin with #$
	@sed -n 's/^#$$ \?//p' $(MAKEFILE_LIST)

dev: ## Launch a development VM and run `make watch`
	@# In case make is used from a different directory with -C
	cd $(CURRENT_DIR)
	vagrant up
	make watch

build: index ## Build the app (alias for index)

lint: lint-js ## Lint src

index: | js-index sass-index $(DEST_INDEX) ## Builds js and sass to public directory, and populates index template with relative paths to each to public index.html

clean: ## Clean up build artifacts
	rm -rf public

edit: ## Edit all src files with EDITOR
	@# Find regular files (as opposed to directories and symlinks, which are files too) and pass them as arguments ({}) to editor all at once (+)
	find src -type f -exec $$EDITOR {} +

watch: ## Run `make index` on changes to src (* not implemented)
	@# TODO needs to run `make clean build` until this makefile does incremental builds
	@echo -e $(WARN_COLOR)not implemented$(CLEAR_COLOR)

js-index: | $(DEST_JS) $(DEST_INDEX)
	@printf $(INFO_COLOR)
	@# Mixed whitespace here is for templating
	@if grep js-concat $(DEST_INDEX) >/dev/null; then \
		echo "Replacing js-concat section of index.html with load of $(RELATIVE_JS)"; \
		sed -i '/js-concat:/,/js-concat\ fi/c\
    <script type="text/javascript" src="$(RELATIVE_JS)"></script>' \
		$(DEST_INDEX); \
	fi
	@printf $(CLEAR_COLOR)

sass-index: | $(DEST_CSS) $(DEST_INDEX)
	@printf $(INFO_COLOR)
	@# Mixed whitespace here is for templating
	@if grep sass-build $(DEST_INDEX) >/dev/null; then \
		echo "Replacing build-sass section of index.html with include of $(RELATIVE_CSS)"; \
		sed -i '/sass-build:/,/sass-build\ fi/c\
    <link rel="stylesheet" type="text/css" href="$(RELATIVE_CSS)">' \
		$(DEST_INDEX); \
	fi
	@printf $(CLEAR_COLOR)

lint-js: ## Lint javascript with jshint
	jshint src/js

$(DEST_JS):
	mkdir -p $(DEST_STATIC)
	@# Set global strict policy
	@printf $(INFO_COLOR)
	@echo Prepending $(DEST_JS) with \"use strict\"
	@echo '"use strict"' >> $(DEST_JS)
	@# Wrap each the contents of each src javascript file in a closure and append to app js
	@for f in $(SRC_JS); \
	do \
		echo "Adding contents of $(SRC_DIR)/$$f to $(DEST_JS) in a closure";\
		echo ';(function () {' >> $(DEST_JS); \
		cat $(SRC_DIR)/$$f >> $(DEST_JS); \
		echo '})()' >> $(DEST_JS); \
	done
	@printf $(CLEAR_COLOR)

$(DEST_CSS):
	@echo -e $(INFO_COLOR)Building $(SRC_DIR)/$(SRC_SASS) into $(DEST_CSS)$(CLEAR_COLOR)
	@pysassc --style expanded \
		--sourcemap \
		$(SRC_DIR)/$(SRC_SASS) $(DEST_CSS)

$(DEST_INDEX):
	@echo -e $(INFO_COLOR)Copying $(SRC_INDEX) template to $(DEST_INDEX)$(CLEAR_COLOR)
	@cp $(SRC_INDEX) $(DEST_INDEX)
