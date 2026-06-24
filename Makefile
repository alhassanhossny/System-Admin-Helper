PREFIX ?= /usr/local

.PHONY: install uninstall test syntax

install:
	./install.sh "$(PREFIX)"

uninstall:
	./uninstall.sh "$(PREFIX)"

test:
	./test/run-tests.sh

syntax:
	find . -type f -name '*.sh' -print -exec bash -n {} \;
