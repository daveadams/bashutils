Libraries and utilities to make Bash and the command line more efficient.

Shared bash function libraries are in `./share`:

* `stdlib.sh`: useful shared functions including error reporting, type checks, file state checks, and string matching

Useful command line utilities are in `./bin`:
* `dateseq`: `seq`, but for dates, including filtering by weekday
* `dayspast`: prints the number of days since the given date, useful with `find`
* `getip`: prints IP for a given DNS name
* `getname`: prints DNS name for a given IP
* `ipsort`: sorts IPv4 addresses numerically by octets
* `subsize`: prints the cumulative file size of each subdirectory of PWD or the specified directories
* `uc`: prints a sorted list of the frequency of unique lines in stdin or a file or set of files
* `yesterday`: prints yesterday's date, or the day before the provided date


## INSTALLATION

This command will install the utilities in `./bin` to `/usr/local/bin` and the support libraries in `./share` to `/usr/share/bashutils`:

    $ sudo make install


## USAGE

To use `stdlib.sh` in your Bash scripts, include the following line:

    source /usr/share/bashutils/stdlib.sh ||exit


## TESTING

To run the included tests:

    $ make test


## AUTHOR

David Adams, daveadams@gmail.com


## LICENSE

The software in this repository is public domain.
