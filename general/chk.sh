#!/bin/bash

# Program to add checkpoint line to input file

#------------------------------------
# Make sure 1 command line argument
# (filename) is provided:
#------------------------------------

if [ $# -ne 1 ]; then
   echo ' '
   echo 'use script like: ./chk filename (only one argument)'
   echo ' '
   exit 1
fi

input=$1
temp=$1'temp.g09'
inputname=$1'.g09'

#----------------------------------
# Add checkpoint line:
#----------------------------------

echo 'chk='$(pwd)'/'$input'.chk' >> $temp
cat $inputname >> $temp
mv -f "$1temp.g09" "$1.g09"
