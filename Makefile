# Makefile
#
# This software is public domain
#

test:
	@libexec/test-stdlib.sh

install:
	@mkdir -p /usr/share/bashutils
	@cp -i share/* /usr/share/bashutils
	@cp -i bin/* /usr/local/bin
