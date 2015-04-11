# test/lib/run-tests.sh
#   Include this file at the tail end of a test suite
#
# This software is public domain.
#

source "$(dirname "$BASH_SOURCE")/../../$TEST_TARGET" ||exit

GOOD_TESTS=0
BAD_TESTS=0
TOTAL_TESTS=0

function should
{
    local VERB="$1"
    shift

    TOTAL=$(( $TOTAL + 1 ))

    if ( eval "should_$VERB \"\$@\"" )
    then
        OK=$(( $OK + 1 ))
        echo -n .
    else
        FAIL=$(( $FAIL + 1 ))
        echo -n F
    fi
}

function should_fail
{
    local COMMAND="$1"
    shift

    ( ! eval "$COMMAND \"\$@\"" &>/dev/null )
}

function should_succeed
{
    local COMMAND="$1"
    shift

    ( eval "$COMMAND \"\$@\"" &>/dev/null )
}

function should_set
{
    local VARNAME="$1"
    local VALUE=$(sed s/\"/\\\"/g <<< "$2")
    shift
    shift

    (
        eval "$@" &>/dev/null
        eval "test \"\$$VARNAME\" = \"$VALUE\""
    )
}

function should_exit_with_status
{
    local STATUS="$1"
    shift
    local COMMAND="$1"
    shift
    local RESULT

    RESULT=$(eval "$COMMAND \"\$@\"" &>/dev/null; echo; echo did-not-exit)
    [ "$?" -eq "$STATUS" ] \
        && ! grep -qFx did-not-exit <<< "$(tail -n 1 <<< "$RESULT")"
}

function should_die
{
    local COMMAND="$1"
    shift
    local RESULT

    RESULT=$(eval "$COMMAND \"\$@\"" 2> >(sed s/^/stderr:/); echo; echo did-not-exit)
    [ "$?" -eq 1 ] \
        && grep -q 'stderr:ERROR$' <<< "$RESULT" \
        && ! grep -qFx did-not-exit <<< "$(tail -n 1 <<< "$RESULT")"
}

function should_live
{
    local COMMAND="$1"
    shift
    local RESULT

    RESULT=$(eval "$COMMAND \"\$@\"" &>/dev/null; echo; echo did-not-exit)
    [ "$?" -eq 0 ] \
        && grep -qFx did-not-exit <<< "$(tail -n 1 <<< "$RESULT")"
}

function should_print
{
    local EXPECTED="$1"
    shift

    local COMMAND="$1"
    shift
    local RESULT="$(eval "$COMMAND \"\$@\"" 2>/dev/null)"

    [ "$RESULT" = "$EXPECTED" ]
}

function should_match
{
    local EXPECTED="$1"
    shift

    local COMMAND="$1"
    shift
    local RESULT="$(eval "$COMMAND \"\$@\"" 2>/dev/null)"

    grep -qE -- "$EXPECTED" <<< "$RESULT"
}

readonly __TEST_TMP_PREFIX=/tmp/bashutils-test-
declare -i __TEST_TMP_COUNTER=0
__TEST_LAST_TEMP_PATH=
function create_temp_file
{
    local FILENAME="${__TEST_TMP_PREFIX}file.$__TEST_TMP_COUNTER"
    __TEST_TMP_COUNTER=$(( $__TEST_TMP_COUNTER + 1 ))

    __TEST_LAST_TEMP_PATH="$FILENAME"
    touch "$FILENAME" || { echo ERROR: Could not create temp file >&2; exit 1; }
}

function create_temp_dir
{
    local DIRNAME="${__TEST_TMP_PREFIX}dir.$__TEST_TMP_COUNTER"
    __TEST_TMP_COUNTER=$(( $__TEST_TMP_COUNTER + 1 ))

    __TEST_LAST_TEMP_PATH="$DIRNAME"
    mkdir "$DIRNAME" || { echo ERROR: Could not create temp dir >&2; exit 1; }
}

function latest_temp_path
{
    echo "$__TEST_LAST_TEMP_PATH"
}

function cleanup_temp
{
    local TMPFILE=

    __TEST_LAST_TEMP_PATH=
    for TMPFILE in ${__TEST_TMP_PREFIX}*
    do
        rm -rf "$TMPFILE"
    done
}

echo "Testing $TEST_TARGET:"
TEST_FUNCTIONS=$(declare -F |cut -d' ' -f3 |grep ^__TEST_)

# formatting details
MAXLEN=0
for TEST_FUNCTION in $TEST_FUNCTIONS
do
    if [ "${#TEST_FUNCTION}" -gt "$MAXLEN" ]
    then
        MAXLEN=${#TEST_FUNCTION}
    fi
done

MAXLEN=$(( $MAXLEN - 7 ))

for TEST_FUNCTION in $TEST_FUNCTIONS
do
    OK=0
    FAIL=0
    TOTAL=0
    TOTAL_TESTS=$(( $TOTAL_TESTS + 1 ))

    printf "  %-${MAXLEN}s  " "${TEST_FUNCTION#__TEST_}"
    eval "$TEST_FUNCTION"
    echo -n " $OK/$TOTAL "
    if [ "$OK" = "$TOTAL" ]
    then
        GOOD_TESTS=$(( $GOOD_TESTS + 1 ))
        echo "OK"
    else
        BAD_TESTS=$(( $BAD_TESTS + 1 ))
        echo "ERRORS"
    fi
done

echo
echo "$GOOD_TESTS/$TOTAL_TESTS tests succeeded"

cleanup_temp

if [ "$BAD_TESTS" -gt 0 ]
then
    return 1
fi
