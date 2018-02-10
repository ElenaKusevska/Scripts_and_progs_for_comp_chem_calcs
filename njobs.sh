#!/bin/bash

# How many jobs do I have running?

squeue | grep 'kusevska' > file
j=$(wc -l < file)
rm file
echo njobs, $j

