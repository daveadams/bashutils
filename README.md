Libraries and utilities to make Bash and the command line more efficient.


## COMPONENTS

Shared bash function libraries are in `./share`:

* `stdlib.sh`: useful shared functions including error reporting, type checks, file state checks, and string matching

Useful command line utilities are in `./bin`:
* `uc`: prints a sorted list of the frequency of unique lines in stdin or a file or set of files
* `subsize`: prints the cumulative file size of each subdirectory of PWD or the specified directories


## INSTALLATION

Copy the contents of `./share` to `/usr/share/bashutils`, and the contents of `./bin` to `/usr/local/bin`.


## USAGE

To use `stdlib.sh` in your Bash scripts, include the following line:

    source /usr/share/bashutils/stdlib.sh ||exit


## TESTING

To test `share/stdlib.sh`, run this command from the project root directory:

    $ test/test-stdlib.sh

To test the utilities in `./bin` along with `stdlib.sh` (on which most of them rely), specify an alternative path to the library directory using `BASHUTILS_LIB_DIR`, eg:

    $ BASHUTILS_LIB_DIR=./share bin/subsize


## AUTHOR

David Adams, daveadams@gmail.com


## LICENSE

The software in this repository is public domain.
