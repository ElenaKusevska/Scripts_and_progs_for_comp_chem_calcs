#!/bin/bash

if [ -f optimized_geometries.xyz ]
then
   rm optimized_geometries.xyz
   echo "geometries.xyzfound and deleted"
fi

for i in TS1_birad_1  TS1_birad_2
do
   filename=$i'.out'
   echo $filename
   if [ -f $filename ]
   then
      echo $filename exists
      # print final geometries to .xyz file
      sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' |  cut -c 17-19,32-95 | cat | wc -l | cat >> optimized_geometries.xyz
      echo $i | cat >> optimized_geometries.xyz
      sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' | cut -c 17-28,32-95 | sed -n 's/^17 / Cl /g;p' | sed -n 's/^ 6 / C /g;p' | sed -n 's/^ 1 / H /g;p' | sed -n 's/^ 7 / N /g;p' | sed -n 's/^ 8 / O /g;p' | sed -n 's/^16 / S /g;p' | cat >> optimized_geometries.xyz
      sleep 1
   else
      echo $filename does not exist
   fi
done
