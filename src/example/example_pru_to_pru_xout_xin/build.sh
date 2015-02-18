#!/bin/sh

example='example_pru_to_pru_xout_xin'
example_app=$example'_app'

# builds binary PRU file
pasm -b -V2 pru1_xout.p
pasm -b -V2 pru0_xin.p

# builds example app
gcc -c -o $example.o $example.c
gcc $example.o -L. -lpthread -lprussdrv -o $example_app

