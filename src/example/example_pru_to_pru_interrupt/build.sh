#!/bin/sh

example='example_pru_to_pru_interrupt'
example_app=$example'_app'

# builds binary PRU file
pasm -b pru1_send_interrupt.p
pasm -b pru0_receive_interrupt.p

# builds example app
gcc -c -o $example.o $example.c
gcc $example.o -L. -lpthread -lprussdrv -o $example_app

