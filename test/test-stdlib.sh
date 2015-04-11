#!/bin/bash
#
# test-stdlib.sh
#   Tests stdlib.sh
#
# This software is public domain.
#

TEST_TARGET=stdlib.sh

function __TEST_die
{
    should die die
    should die die "There was an error"
    should die die "An error happened:" "More info" "Even more info"
}

function __TEST_script_error
{
    should die script_error
    should die script_error "Something happened"
    should die script_error "Errors were found" "In the code"
}

function __TEST_warn
{
    should live warn
    should live warn "Uh oh"
    should live warn "This is bad" "But not so bad"

    should set __WARNINGS 1 warn "Oops"
    should set __WARNINGS 1 warn "Oh no" "not again"

    __WARNINGS=10 should set __WARNINGS 11 warn "This is a lot of warnings"
}

function __TEST_tmp_filename
{
    should live tmp_filename
    should live tmp_filename testing

    should match "^$__TMP_DIR/stdlib-" tmp_filename
    should match "^$__TMP_DIR/testing-" tmp_filename testing

    __TMP_DIR=/usr/local/tmp should match "^/usr/local/tmp/stdlib-" tmp_filename
    __TMP_DIR=/usr/local/tmp should match "^/usr/local/tmp/testing-" tmp_filename testing
}

# TODO: __TEST_getpass (will require new support functions)

function __TEST_require_utils
{
    should live require_utils
    should live require_util

    should live require_utils ls cat ps kill
    should live require_util  ls cat ps kill
    should live require_utils /bin/bash top
    should live require_util  /bin/bash top
    should die  require_utils xxxxxxxxxxxxxxxxx /qqq/qqq/qqq/qqq/qqq
    should die  require_util  xxxxxxxxxxxxxxxxx /qqq/qqq/qqq/qqq/qqq
}

function __TEST_require_readable
{
    should live require_readable

    create_temp_file
    local FILENAME=$(latest_temp_path)

    create_temp_file
    local FILENAME2=$(latest_temp_path)

    should live require_readable "$FILENAME"
    should live require_readable "$FILENAME" "$FILENAME2"

    chmod -r "$FILENAME"
    should die require_readable "$FILENAME"
    should live require_readable "$FILENAME2"
    should die require_readable "$FILENAME" "$FILENAME2"
    chmod -r "$FILENAME2"
    should die require_readable "$FILENAME"
    should die require_readable "$FILENAME2"
    should die require_readable "$FILENAME" "$FILENAME2"
    chmod u+r "$FILENAME"
    should live require_readable "$FILENAME"
    should die require_readable "$FILENAME2"
    should die require_readable "$FILENAME" "$FILENAME2"
    chmod u+r "$FILENAME2"
    should live require_readable "$FILENAME"
    should live require_readable "$FILENAME2"
    should live require_readable "$FILENAME" "$FILENAME2"
    rm -f "$FILENAME"
    should die require_readable "$FILENAME"
    should live require_readable "$FILENAME2"
    should die require_readable "$FILENAME" "$FILENAME2"

    create_temp_dir
    local DIRNAME=$(latest_temp_path)

    should live require_readable "$DIRNAME"
    should live require_readable "$DIRNAME" "$FILENAME2"
    should die require_readable "$DIRNAME" "$FILENAME" "$FILENAME2"

    chmod -r "$DIRNAME"
    should die require_readable "$DIRNAME"
    should die require_readable "$DIRNAME" "$FILENAME2"
    should die require_readable "$DIRNAME" "$FILENAME" "$FILENAME2"
    chmod u+r "$DIRNAME"

    should live require_readable "$DIRNAME"
    should live require_readable "$DIRNAME" "$FILENAME2"
    should die require_readable "$DIRNAME" "$FILENAME" "$FILENAME2"

    rmdir "$DIRNAME"
    should die require_readable "$DIRNAME"
    should die require_readable "$DIRNAME" "$FILENAME2"
    should die require_readable "$DIRNAME" "$FILENAME"
}

function __TEST_require_writable
{
    should live require_writable

    create_temp_file
    local FILENAME=$(latest_temp_path)

    create_temp_file
    local FILENAME2=$(latest_temp_path)

    should live require_writable "$FILENAME"
    should live require_writable "$FILENAME" "$FILENAME2"

    chmod -w "$FILENAME"
    should die require_writable "$FILENAME"
    should live require_writable "$FILENAME2"
    should die require_writable "$FILENAME" "$FILENAME2"
    chmod -w "$FILENAME2"
    should die require_writable "$FILENAME"
    should die require_writable "$FILENAME2"
    should die require_writable "$FILENAME" "$FILENAME2"
    chmod u+w "$FILENAME"
    should live require_writable "$FILENAME"
    should die require_writable "$FILENAME2"
    should die require_writable "$FILENAME" "$FILENAME2"
    chmod u+w "$FILENAME2"
    should live require_writable "$FILENAME"
    should live require_writable "$FILENAME2"
    should live require_writable "$FILENAME" "$FILENAME2"
    rm -f "$FILENAME"
    should die require_writable "$FILENAME"
    should live require_writable "$FILENAME2"
    should die require_writable "$FILENAME" "$FILENAME2"

    create_temp_dir
    local DIRNAME=$(latest_temp_path)

    should live require_writable "$DIRNAME"
    should live require_writable "$DIRNAME" "$FILENAME2"
    should die require_writable "$DIRNAME" "$FILENAME"

    chmod -w "$DIRNAME"
    should die require_writable "$DIRNAME"
    should die require_writable "$DIRNAME" "$FILENAME2"
    should die require_writable "$DIRNAME" "$FILENAME" "$FILENAME2"
    chmod u+w "$DIRNAME"

    should live require_writable "$DIRNAME"
    should live require_writable "$DIRNAME" "$FILENAME2"
    should die require_writable "$DIRNAME" "$FILENAME"

    rmdir "$DIRNAME"
    should die require_writable "$DIRNAME"
    should die require_writable "$DIRNAME" "$FILENAME2"
    should die require_writable "$DIRNAME" "$FILENAME"
}

function __TEST_require_executable
{
    should live require_executable

    create_temp_file
    local FILENAME=$(latest_temp_path)
    chmod +x "$FILENAME"

    create_temp_file
    local FILENAME2=$(latest_temp_path)
    chmod +x "$FILENAME2"

    should live require_executable "$FILENAME"
    should live require_executable "$FILENAME" "$FILENAME2"

    chmod -x "$FILENAME"
    should die require_executable "$FILENAME"
    should live require_executable "$FILENAME2"
    should die require_executable "$FILENAME" "$FILENAME2"
    chmod -x "$FILENAME2"
    should die require_executable "$FILENAME"
    should die require_executable "$FILENAME2"
    should die require_executable "$FILENAME" "$FILENAME2"
    chmod u+x "$FILENAME"
    should live require_executable "$FILENAME"
    should die require_executable "$FILENAME2"
    should die require_executable "$FILENAME" "$FILENAME2"
    chmod u+x "$FILENAME2"
    should live require_executable "$FILENAME"
    should live require_executable "$FILENAME2"
    should live require_executable "$FILENAME" "$FILENAME2"
    rm -f "$FILENAME"
    should die require_executable "$FILENAME"
    should live require_executable "$FILENAME2"
    should die require_executable "$FILENAME" "$FILENAME2"

    create_temp_dir
    local DIRNAME=$(latest_temp_path)

    should live require_executable "$DIRNAME"
    should live require_executable "$DIRNAME" "$FILENAME2"
    should die require_executable "$DIRNAME" "$FILENAME"

    chmod -x "$DIRNAME"
    should die require_executable "$DIRNAME"
    should die require_executable "$DIRNAME" "$FILENAME2"
    should die require_executable "$DIRNAME" "$FILENAME" "$FILENAME2"
    chmod u+x "$DIRNAME"

    should live require_executable "$DIRNAME"
    should live require_executable "$DIRNAME" "$FILENAME2"
    should die require_executable "$DIRNAME" "$FILENAME"

    rmdir "$DIRNAME"
    should die require_executable "$DIRNAME"
    should die require_executable "$DIRNAME" "$FILENAME2"
    should die require_executable "$DIRNAME" "$FILENAME"
}

function __TEST_require_dirs
{
    should live require_dirs
    should live require_dir
    should live require_directory
    should live require_directories

    create_temp_dir
    local DIR1=$(latest_temp_path)
    create_temp_dir
    local DIR2=$(latest_temp_path)

    should live require_dirs "$DIR1"
    should live require_dir "$DIR1"
    should live require_directory "$DIR1"
    should live require_directories "$DIR1"

    should live require_dirs "$DIR2"
    should live require_dir "$DIR2"
    should live require_directory "$DIR2"
    should live require_directories "$DIR2"

    should live require_dirs "$DIR1" "$DIR2"
    should live require_dir "$DIR1" "$DIR2"
    should live require_directory "$DIR1" "$DIR2"
    should live require_directories "$DIR1" "$DIR2"

    should live require_dirs "$DIR2" "$DIR1"
    should live require_dir "$DIR2" "$DIR1"
    should live require_directory "$DIR2" "$DIR1"
    should live require_directories "$DIR2" "$DIR1"

    rmdir "$DIR2"
    should live require_dirs "$DIR1"
    should live require_dir "$DIR1"
    should live require_directory "$DIR1"
    should live require_directories "$DIR1"

    should die require_dirs "$DIR2"
    should die require_dir "$DIR2"
    should die require_directory "$DIR2"
    should die require_directories "$DIR2"

    should die require_dirs "$DIR1" "$DIR2"
    should die require_dir "$DIR1" "$DIR2"
    should die require_directory "$DIR1" "$DIR2"
    should die require_directories "$DIR1" "$DIR2"

    should die require_dirs "$DIR2" "$DIR1"
    should die require_dir "$DIR2" "$DIR1"
    should die require_directory "$DIR2" "$DIR1"
    should die require_directories "$DIR2" "$DIR1"

    rmdir "$DIR1"
    should die require_dirs "$DIR1"
    should die require_dir "$DIR1"
    should die require_directory "$DIR1"
    should die require_directories "$DIR1"

    should die require_dirs "$DIR1" "$DIR2"
    should die require_dir "$DIR1" "$DIR2"
    should die require_directory "$DIR1" "$DIR2"
    should die require_directories "$DIR1" "$DIR2"

    should die require_dirs "$DIR2" "$DIR1"
    should die require_dir "$DIR2" "$DIR1"
    should die require_directory "$DIR2" "$DIR1"
    should die require_directories "$DIR2" "$DIR1"
}

function __TEST_require_user
{
    local THIS_USER=$(whoami)

    should die  require_user
    should die  require_user ""

    should live require_user "$THIS_USER"
    should live require_user daemon "$THIS_USER" nobody root
    should live require_user root "$THIS_USER" daemon "$THIS_USER"

    should die  require_user "not$THIS_USER"
    should die  require_user "${THIS_USER}1" "anti$THIS_USER"
}

function __TEST_require_host
{
    local THIS_HOST=$(hostname -s)

    should die  require_host
    should die  require_host ""

    should live require_host "$THIS_HOST"
    should live require_host www "$THIS_HOST" mail
    should live require_host jupiter "$THIS_HOST" neptune "$THIS_HOST"

    should die  require_host "not$THIS_HOST"
    should die  require_host "${THIS_HOST}1" "anti$THIS_HOST"
}

function __TEST_inc
{
    X=100  should live       inc X
    X=abc  should die        inc X
    X=123  should succeed    inc X
    X=100  should set X 101  inc X
    X=44   should set X 46   inc X 2
    X=947  should set X 1940 inc X 993
    X=-25  should set X -24  inc X
    X=-999 should set X 1001 inc X 2000
    X=-1   should set X 0    inc X
    X=     should set X 1    inc X
    X=     should set X 97   inc X 97

    X=9338402743995 \
        should set X 9338402743996 \
        inc X

    X=100 \
        should set X 840473957611 \
        inc X 840473957511
}

function __TEST_dec
{
    X=100  should live        dec X
    X=abc  should die         dec X
    X=123  should succeed     dec X
    X=100  should set X 99    dec X
    X=44   should set X 42    dec X 2
    X=947  should set X 4     dec X 943
    X=-25  should set X -26   dec X
    X=999  should set X -1001 dec X 2000
    X=-55  should set X -156  dec X 101
    X=     should set X -1    dec X
    X=     should set X -58   dec X 58

    X=9338402743995 \
        should set X 9338402743994 \
        dec X

    X=100 \
        should set X -840473957511 \
        dec X 840473957611
}

function __TEST_downcase
{
    should live downcase ""

    should print "qwertyuiop"         downcase "QwErTyUiOp"
    should print "qwertyuiop"         downcase "qwertyuiop"
    should print "asdfghjkl"          downcase "ASDFGHJKL"
    should print "12345"              downcase "12345"
    should print "1zx2xc3cv4vb5bn6nm" downcase "1ZX2xC3cv4Vb5Bn6NM"
    should print "happy feet"         downcase "HAPPY FEET"
    should print "banana grams "      downcase "Banana GRaMS "
    should print "isn't that neat?"   downcase "Isn't THAT neat?"
    should print "x.y,z*q%v#@"        downcase "X.y,z*Q%v#@"
    should print "     "              downcase "     "
    should print " a b c d e "        downcase " A b C D E "
    should print "when in the course of human events" \
        downcase "When in the COURSE of hUmAn evENTS"
}

function __TEST_upcase
{
    should live upcase ""

    should print "QWERTYUIOP"         upcase "QwErTyUiOp"
    should print "QWERTYUIOP"         upcase "qwertyuiop"
    should print "ASDFGHJKL"          upcase "ASDFGHJKL"
    should print "12345"              upcase "12345"
    should print "1ZX2XC3CV4VB5BN6NM" upcase "1ZX2xC3cv4Vb5Bn6NM"
    should print "HAPPY FEET"         upcase "happy feet"
    should print "BANANA GRAMS "      upcase "Banana grAms "
    should print "ISN'T THAT NEAT?"   upcase "Isn't thAt Neat?"
    should print "X.Y,Z*Q%V#@"        upcase "X.y,z*Q%v#@"
    should print "     "              upcase "     "
    should print " A B C D E "        upcase " a B c d e "
    should print "WHEN IN THE COURSE OF HUMAN EVENTS" \
        upcase "When in the COURSE of hUmAn evENTS"
}

function __TEST_capitalize
{
    should live capitalize ""

    should print "A"            capitalize "a"
    should print "Q"            capitalize "Q"
    should print "Capital"      capitalize "capital"
    should print "Uncapitalize" capitalize "UNCAPITALIZE"
    should print "Italicize"    capitalize "ItAlIcIzE"
    should print "Monument"     capitalize "moNUmeNT"
    should print "1408"         capitalize "1408"
    should print " capital"     capitalize " capital"
    should print ""             capitalize ""
    should print "     "        capitalize "     "
    should print "X.y,z*q%v#@"  capitalize "x.Y,z*Q%v#@"
    should print "When in the course of human events" \
        capitalize "WHEN in the COURSE of HUMAN eVENTS"
}

function __TEST_bashsplit
{
    X=1,20,400     should set B "20"      'bashsplit , "$X" A B C'
    X=20,30,40     should set Z "30,40"   'bashsplit , "$X" Y Z'
    IP=10.2.14.183 should set A "10"      'bashsplit . "$IP" A B C D'
    IP=10.2.14.183 should set B "2"       'bashsplit . "$IP" A B C D'
    IP=10.2.14.183 should set C "14"      'bashsplit . "$IP" A B C D'
    IP=10.2.14.183 should set D "183"     'bashsplit . "$IP" A B C D'
    P="1|xyz|33"   should set A "1"       'bashsplit "|" "$P" A B C'
    S="**Q****R"   should set F1 ""       'bashsplit "*" "$S" F1 F2 F3 F4'
    S="**Q****R"   should set F2 ""       'bashsplit "*" "$S" F1 F2 F3 F4'
    S="**Q****R"   should set F3 "Q"      'bashsplit "*" "$S" F1 F2 F3 F4'
    S="**Q****R"   should set F4 "***R"   'bashsplit "*" "$S" F1 F2 F3 F4'
    N="a:b:c:d:e:" should set A "a"       'bashsplit ":" "$N" A B C'
    N="a:b:c:d:e:" should set C "c:d:e:"  'bashsplit ":" "$N" A B C'
}

function __TEST_is_integer
{
    should live is_integer ""
    should fail is_integer ""
    should fail is_integer abc
    should fail is_integer 10q
    should fail is_integer 1.5
    should fail is_integer -p

    should succeed is_integer 1
    should succeed is_integer 0
    should succeed is_integer -15885
    should succeed is_integer 450238499573279230404
    should succeed is_integer -958347204504000482
}

function __TEST_require_integer
{
    should die require_integer ""
    should die require_integer abc
    should die require_integer 10q
    should die require_integer 1.5
    should die require_integer -p

    should live    require_integer 1
    should succeed require_integer 1
    should live    require_integer 0
    should succeed require_integer 0
    should live    require_integer -15885
    should succeed require_integer -15885
    should live    require_integer 450238499573279230404
    should succeed require_integer 450238499573279230404
    should live    require_integer -958347204504000482
    should succeed require_integer -958347204504000482
}

function __TEST_is_numeric
{
    should live is_numeric ""

    should fail is_numeric abc
    should fail is_numeric 1.q
    should fail is_numeric 77v88
    should fail is_numeric " 10"
    should fail is_numeric ""

    should succeed is_numeric 1
    should succeed is_numeric -7
    should succeed is_numeric 1.4
    should succeed is_numeric 0.00
    should succeed is_numeric -.9
    should succeed is_numeric .0440
    should succeed is_numeric .73
}

function __TEST_require_numeric
{
    should die require_numeric ""

    should die require_numeric abc
    should die require_numeric 1.q
    should die require_numeric 77v88
    should die require_numeric " 10"
    should die require_numeric ""

    should live    require_numeric 1
    should succeed require_numeric 1
    should live    require_numeric -7
    should succeed require_numeric -7
    should live    require_numeric 0.00
    should succeed require_numeric 0.00
    should live    require_numeric -.9
    should succeed require_numeric -.9
    should live    require_numeric .0440
    should succeed require_numeric .0440
}

function __TEST_is_uuid
{
    should live is_uuid ""

    should fail is_uuid asdfjkl
    should fail is_uuid aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa
    should fail is_uuid aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaaa
    should fail is_uuid 0123456789abcdef0a0aabcedffdecba
    should fail is_uuid 01234567--89ab-cdef-0a0a-abcedffdecba
    should fail is_uuid 0123456789-abcdef-0a0a--abcedffdecba
    should fail is_uuid ""

    should succeed is_uuid aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
    should succeed is_uuid 11111111-1111-1111-1111-111111111111
    should succeed is_uuid 01234567-89ab-cdef-0a0a-abcedffdecba
    should succeed is_uuid 01234567-89ab-CDEF-0a0a-abcedffdecba
    should succeed is_uuid 01234567-89AB-CDEF-0A0A-ABCEDFFDECBA
}

function __TEST_say
{
    __QUIET=     should print "hello world"  say "hello world"
    __QUIET=xyz  should print "hello world"  say "hello world"
    __QUIET=1    should print ""             say "hello world"
}

function __TEST_starts_with
{
    should live starts_with "sample" "s"
    should live starts_with "sample" "X"
    should live starts_with "sample" "sampler"
    should live starts_with "sample" ""
    should live starts_with "" "sample"
    should live starts_with "" ""

    should fail starts_with "banana" "BAN"
    should fail starts_with " enid" "eni"
    should fail starts_with "12345" "234"
    should fail starts_with ".x77ff?" "fx77"
    should fail starts_with "hello world" ".*"
    should fail starts_with "hello" "hello world"

    should succeed starts_with "Banana" "Bana"
    should succeed starts_with " enid" " e"
    should succeed starts_with "12345" "123"
    should succeed starts_with "apricots" "apricots"
    should succeed starts_with "hello world" "hello w"
    should succeed starts_with "a.*xy" "a.*x"
    should succeed starts_with "-xF" "-x"
}

function __TEST_ends_with
{
    should live ends_with "sample" "e"
    should live ends_with "sample" "Q"
    should live ends_with "sample" "sampler"
    should live ends_with "sample" ""
    should live ends_with "" "sample"
    should live ends_with "" ""

    should fail ends_with "banana" "ANA"
    should fail ends_with "enid " "nid"
    should fail ends_with "12345" "234"
    should fail ends_with ".x77ff?" "77ff"
    should fail ends_with "hello world" ".*"
    should fail ends_with "hello" "hello world"

    should succeed ends_with "BananA" "nanA"
    should succeed ends_with "enid " "d "
    should succeed ends_with "12345" "345"
    should succeed ends_with "apricots" "apricots"
    should succeed ends_with "hello world" "o world"
    should succeed ends_with "a.*xy" ".*xy"
    should succeed ends_with "q-xF" "-xF"
}

function __TEST_contains
{
    should live contains "sample" "mp"
    should live contains "sample" "123"
    should live contains "sample" "essampler"
    should live contains "sample" ""
    should live contains "" "sample"
    should live contains "" ""

    should fail contains "banana" "ANA"
    should fail contains "en id" "ni"
    should fail contains "12345" "2.4"
    should fail contains ".x77ff?" "x7f"
    should fail contains "hello world" ".*"
    should fail contains "hello" "shello world"

    should succeed contains "BaNanA" "aNa"
    should succeed contains "en id " "n i"
    should succeed contains "12345" "234"
    should succeed contains "apricots" "apricots"
    should succeed contains "hello world" "llo wor"
    should succeed contains "a.*xy" ".*x"
    should succeed contains "q-xF" "-x"

    should succeed contains "BananA" "nanA"
    should succeed contains "enid " "d "
    should succeed contains "12345" "345"
    should succeed contains "apricots" "apricots"
    should succeed contains "hello world" "o world"
    should succeed contains "a.*xy" ".*xy"
    should succeed contains "q-xF" "-xF"

    should succeed contains "Banana" "Bana"
    should succeed contains " enid" " e"
    should succeed contains "12345" "123"
    should succeed contains "apricots" "apricots"
    should succeed contains "hello world" "hello w"
    should succeed contains "a.*xy" "a.*x"
    should succeed contains "-xF" "-x"
}

function __TEST_max_length
{
    should live max_length a ab abc
    should live max_length

    should print 0  max_length
    should print 0  max_length "" "" "" ""
    should print 3  max_length abc
    should print 3  max_length x yz pqr
    should print 5  max_length hello world
    should print 10 max_length a b c d e fgh ijklmnopqr stuvwxyz
    should print 3  max_length "  " " " "   " "   " "" " "
}

function __TEST_min_length
{
    should live min_length a ab abc
    should live min_length

    should print 0  min_length
    should print 0  min_length "" "" "" ""
    should print 3  min_length abc
    should print 1  min_length x yz pqr
    should print 5  min_length hello world
    should print 1  min_length a b c d e fgh ijklmnopqr stuvwxyz
    should print 0  min_length "  " " " "   " "   " "" " "
}

function __TEST_percentage
{
    should live percentage 100 200
    should die  percentage
    should die  percentage ""
    should die  percentage "" ""
    should die  percentage 10 abc
    should die  percentage xyz 30
    should die  percentage . ^

    should print  50.00 percentage 100 200
    should print  75.00 percentage 3 4
    should print   0.04 percentage 38402 90483217
    should print  -4.14 percentage -38 917
    should print  -4.14 percentage 38 -917
    should print   4.14 percentage 38 917
    should print   4.14 percentage -38 -917
    should print 429.86 percentage 16700391 3885051
}


source "$(dirname "$BASH_SOURCE")/lib/run-tests.sh"
