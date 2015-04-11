# stdlib.sh
#   A standard library for Bash
#
# This software is public domain.
#
# Usage:
#   source /usr/share/bashutils/stdlib.sh ||exit
#

function die
# print error and exit
{
    {
        echo ERROR
        while [ $# -gt 0 ]
        do
            echo "$1"
            shift
        done |sed 's/^/  /'
    } >&2
    exit 1
}

function script_error
{
    die "Script Error: $@" "(in call to '${FUNCNAME[1]}': line ${BASH_LINENO[1]} of ${BASH_SOURCE[2]})"
}

__WARNINGS=${__WARNINGS:-0}
function warn
# print warning message and increment __WARNINGS, but don't stop program
{
    inc __WARNINGS
    {
        echo WARNING
        while [ $# -gt 0 ]
        do
            echo "$1"
            shift
        done |sed 's/^/  /'
    } >&2
}

__TMP_DIR=${__TMP_DIR:-/tmp}
function tmp_filename
# usage tmp_filename [key]
# if key is specified it is prefixed to the filename
# otherwise "stdlib" is used
{
    local KEY="${1:-stdlib}"
    local EXT=$(date +%Y%m%d%H%M%S)-$$

    # just in case the filename exists
    # unlikely unless one script is calling this several times
    while [ -e "${__TMP_DIR}/$KEY-$EXT" ]; do EXT=${EXT}x; done

    echo "${__TMP_DIR}/$KEY-$EXT"
}

function getpass
# usage: getpass ["prompt string"] [VARNAME]
{
    local PROMPT_STRING="${1:-Password:}"
    local VARNAME="${2:-__PASSWORD}"

    read -s -p "$PROMPT_STRING " $VARNAME
    echo >&2
}

function require_utils
# usage: require_utils perl ruby rlwrap ...
# dies if any argument is not found in the path
{
    local -a FAILED
    local -i FAIL_COUNT=0

    while [ $# -gt 0 ]
    do
        local UTIL="$1"
        if [ -z "$(which $UTIL 2>/dev/null)" ]
        then
            FAILED[$FAIL_COUNT]="$UTIL"
            inc FAIL_COUNT
        fi
        shift
    done

    if [ "$FAIL_COUNT" -eq 1 ]
    then
        die "Required utility '$FAILED[0]' was not found in your PATH."
    elif [ "$FAIL_COUNT" -gt 1 ]
    then
        die "These required utilities could not be found in your PATH:" "${FAILED[@]}"
    fi
}

function require_util
# alternate spelling
{
    require_utils "$@"
}

function require_readable
{
    while [ $# -gt 0 ]
    do
        if [ ! -e "$1" ]; then die "Required file or directory '$1' does not exist."; fi
        if [ ! -r "$1" ]; then die "Required file or directory '$1' is not readable."; fi
        shift
    done
}

function require_writable
{
    while [ $# -gt 0 ]
    do
        if [ ! -e "$1" ]; then die "Required file or directory '$1' does not exist."; fi
        if [ ! -w "$1" ]; then die "Required file or directory '$1' is not writable."; fi
        shift
    done
}

function require_executable
{
    while [ $# -gt 0 ]
    do
        if [ ! -e "$1" ]; then die "Required file '$1' does not exist."; fi
        if [ ! -x "$1" ]; then die "Required file '$1' is not executeable."; fi
        shift
    done
}

function require_dirs
{
    while [ $# -gt 0 ]
    do
        if [ ! -e "$1" ]; then die "Required directory '$1' does not exist."; fi
        if [ ! -d "$1" ]; then die "Required directory '$1' is not a directory."; fi
        shift
    done
}
function require_dir { require_dirs "$@"; }
function require_directory { require_dirs "$@"; }
function require_directories { require_dirs "$@"; }

function require_user
{
    local VALID_USER=
    local THIS_USER=$(downcase "$(whoami)")

    for VALID_USER in "$@"
    do
        [ "$(downcase "$VALID_USER")" = "$THIS_USER" ] && return
    done

    [ "$#" -gt 1 ] && die "This script must be run by one of the following users:" "$@"

    die "This script must by run by user '$1'"
}

function require_host
{
    local VALID_HOST=
    local THIS_HOST=$(downcase "$(hostname -s)")

    for VALID_HOST in "$@"
    do
        [ "$(downcase "$VALID_HOST")" = "$THIS_HOST" ] && return
    done

    die "This script must be run on one of these hosts:" "$@"
}


function inc
# usage: inc <varname> [<size>]
#
#   # increment VARNAME by one
#   inc VARNAME
#   # increment VARNAME by 5
#   inc VARNAME 5
{
    local -i ADD=1
    is_integer "$2" && ADD="$2"

    if [ -n "$1" ]
    then
        if eval "test -z \$$1"
        then
            eval "$1=0"
        fi

        if eval "is_integer \"\$$1\""
        then
            eval "$1=\$(( \$$1 + $ADD ))"
        else
            script_error "Variable '$1' is not an integer"
        fi
    fi
}

function dec
{
    local SUB=1
    is_integer "$2" && SUB="$2"

    if [ -n "$1" ]
    then
        if eval "test -z \$$1"
        then
            eval "$1=0"
        fi

        if eval "is_integer \"\$$1\""
        then
            eval "$1=\$(( \$$1 - $SUB ))"
        else
            script_error "Variable '$1' is not an integer"
        fi
    fi
}

function downcase
{
    tr 'A-Z' 'a-z' <<< "$1"
}

function upcase
{
    tr 'a-z' 'A-Z' <<< "$1"
}

# capitalize the first letter of the string, and make the rest lowercase
function capitalize
{
    downcase "$1" |sed 's/^\([a-z]\)/\U\1/'
}

# perl-like 'split', sort of
#   Usage: bashsplit '|' 'one|two|three' UNO DOS TRES
function bashsplit
{
    local SEP="$1"
    local INPUT="$2"
    shift; shift

    IFS="$SEP" read "$@" <<< "$INPUT"
}

function is_integer
{
    grep -qE '^-?[0-9]+$' <<< "$1"
}

function require_integer
{
    is_integer "$1" || die "${2:-Value '$1' must be an integer.}"
}

function is_numeric
{
    grep -qE '^-?([0-9]+\.?|\.)([0-9]+)?$' <<< "$1"
}

function require_numeric
{
    is_numeric "$1" || die "${2:-Value '$1' must be numeric.}"
}

function is_ipv4_address
{
    local IP="$1"
    grep -qE "^(([12]?[0-9])?[0-9]\.){3}([12]?[0-9])?[0-9]$" <<< "$IP" ||return 1

    bashsplit "." "$IP" A B C D
    for OCTET in $A $B $C $D
    do
        is_integer $OCTET && [ $OCTET -le 255 ] && [ $OCTET -ge 0 ] ||return 1
    done
}

function require_ipv4_address
{
    is_ipv4_address "$1" || die "${2:-Value '$1' must be a valid IP address.}"
}

function is_uuid
{
    grep -qE '^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$' <<< "$(downcase "$1")"
}

function require_uuid
{
    is_uuid "$1" || die "${2:-Value '$1' must be a valid UUID}"
}

# if __QUIET is 1 do nothing, else call echo with the same arguments
function say
{
    if [ -z "$__QUIET" ] || [ "$__QUIET" != "1" ]
    then
        echo "$@"
    fi
}

######################################################################
# string matching functions

function starts_with
{
    [ "${1:0:${#2}}" = "$2" ]
}

function ends_with
{
    [ "${1:(-${#2})}" = "$2" ]
}

function contains
{
    grep -qF -- "$2" <<< "$1"
}

# return the maximum length of strings passed as arguments
function max_length
{
    local MAX=0

    for ARG in "$@"
    do
        [ "${#ARG}" -gt "$MAX" ] && MAX=${#ARG}
    done

    echo $MAX
}

# return the minimum length of strings passed as arguments
function min_length
{
    local MIN=

    for ARG in "$@"
    do
        if [ -z "$MIN" ]
        then
            MIN=${#ARG}
            continue
        fi

        [ "${#ARG}" -lt "$MIN" ] && MIN=${#ARG}
    done

    echo ${MIN:-0}
}

function percentage
{
    local PORTION="$1"
    local TOTAL="$2"

    if ! is_integer "$PORTION" || ! is_integer "$TOTAL"
    then
        script_error "Both arguments to 'percentage' must be integers"
    fi

    if [ "$PORTION" = "0" ]
    then
        echo "0.00"
    else
        local ANSWER="$(printf "%03d" "$(( ( $PORTION * 10000 ) / $TOTAL ))")"
        echo "${ANSWER:0:-2}.${ANSWER:(-2)}"
    fi
}
