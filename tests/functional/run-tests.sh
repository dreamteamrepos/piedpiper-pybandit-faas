#!/bin/bash

errors=0
for test in \
	success; do

    echo "Running test $test"
	$(dirname $0)/$test/run-test.sh
	if [[ $? -ne 0 ]]; then
		errors=$((errors+1))
	fi
done

if [[ "${errors}" == 0 ]]; then
    echo "Tests ran successfully";
    exit 0;
else
    echo "Tests failed";
	exit 1;
fi
