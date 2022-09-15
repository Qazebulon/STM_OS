#!/bin/bash
as -o temp.o os.s
../utils/ld
echo 'Did you remember to reset the 103?'
read x
../utils/id
../utils/erase103
../utils/burn
../utils/term
