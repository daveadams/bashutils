Libraries and utilities to make Bash and the command line more efficient.


## LIBRARIES

Bash function libraries are in `./share`. Utility scripts are in `./bin`.


## INSTALLATION

Copy the contents of `./share` to `/usr/share/bashutils`, and the contents of `./bin` to `/usr/local/bin`.


## USAGE

To use `stdlib.sh` in your Bash scripts, include the following line:

    source /usr/share/bashutils/stdlib.sh ||exit


## TESTING

To test `share/stdlib.sh`, run this command from the project root directory:

    $ test/test-stdlib.sh


## AUTHOR

David Adams, daveadams@gmail.com


## LICENSE

The software in this repository is public domain.
