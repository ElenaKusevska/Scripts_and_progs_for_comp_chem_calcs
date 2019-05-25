#!/bin/bash

#----------------------------------------------------------
# Write a .xyz file from coordinates given in a .gjf file
#----------------------------------------------------------

for i in 3
do
  echo $i
  dos2unix $i.gjf
  natoms=$(($(sed -n '/^0\|^1\|^-1/,/^$/p' $i.gjf | tail -n+2 | wc -l)-1))
  echo $natoms | cat >> $i.xyz
  echo 'random comment' | cat >> $i.xyz
  #sed -n '/^ C\|^ H\|^ N \|^ O/p' $i.gjf | cat >> $i.g16
      # print lines starting with ' C', ' H', ' N', or ' O'
  sed -n '/^0\|^1\|^-1/,/^$/p' $i.gjf | tail -n+2 | head -n-1 | cat >> $i.xyz
      # print from after multiplicity line to first blank line
      # will not work properly without dos2unix first.
      # -n - supress double printing
  sleep 2
done

