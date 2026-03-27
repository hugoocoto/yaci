#!/usr/bin/env bash

# Execute all tests

SCRIPT_DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
cd "$SCRIPT_DIR/.."

make 

FAILED=0
TOTAL=0

TOTAL=$(($TOTAL + 1)); ./yaci ./tests/file1.yc || FAILED=$(($FAILED + 1));
TOTAL=$(($TOTAL + 1)); ./yaci ./tests/file2.yc || FAILED=$(($FAILED + 1));
TOTAL=$(($TOTAL + 1)); ./yaci ./tests/file3.yc || FAILED=$(($FAILED + 1));

if [[ -z "$FAILED" ]]; then
    echo "failed tests: $FAILD" 
else
    echo "passed tests: $TOTAL" 
fi

exit 0
