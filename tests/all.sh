#!/usr/bin/env bash

# Execute all tests
#
# Run all the files in ./tests that are .yc files

YACI_FLAGS="--norepl --verbose"

SCRIPT_DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
cd "$SCRIPT_DIR/.."

make compile >> /dev/null

FAILED=0
TOTAL=0

for file in ./tests/*.yc; do
    TOTAL=$(($TOTAL + 1)); ./yaci $file $YACI_FLAGS || FAILED=$(($FAILED + 1));
done

echo
echo "TEST SUMMARY"
echo "[failed]: $FAILED" 
echo "[passed]: $(($TOTAL - $FAILED))" 

exit $FAILED
