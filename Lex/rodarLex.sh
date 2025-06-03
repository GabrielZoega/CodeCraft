#!/bin/bash
flex lex.l
gcc lex.yy.c -o a.out
./a.out < teste.txt
