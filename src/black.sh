#!/bin/bash
as -o temp.o os.s
../utils/ld
echo 'Did you remember to reset the 411?'
read x
../utils/id
../utils/erase411
echo 'Reset the 411'
read x
../utils/id
../utils/burn
../utils/term
