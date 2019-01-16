#!/bin/bash

if [ -f finishedjoblist ]
then
   rm finishedjoblist
   echo "finishedjoblist found and deleted"
fi

if [ -f notfinishedjoblist ]
then
   rm notfinishedjoblist
   echo "notfinishedjoblist found and deleted"
fi

if [ -f geometries.xyz ]
then
   rm geometries.xyz
   echo "geometries.xyzfound and deleted"
fi

for i in TS1_birad_1  TS1_birad_2
do
   if [ -d $i ]
   then
      cd $i
      filename=$i'.out'
      echo $filename
      if [ -f $filename ]
      then
         echo "file exists"
         if [[ -n "$(grep "Normal termination" $filename | tail -1)" ]]
         then
            # -n, the length of string is not zero
            echo $filename $j $k | cat >> ../finishedjoblist
            echo $(grep 'Frequencies' $filename | head -1) | cat >> ../finishedjoblist
            echo $(grep 'SCF Done' $filename | tail -1) | cat >> ../finishedjoblist
            echo ' ' | cat >> ../finishedjoblist
            echo "job finished"
            # print final geometries to .xyz file
            sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' |  cut -c 17-19,32-95 | cat | wc -l | cat >> ../geometries.xyz
            echo $i $j $k | cat >> ../geometries.xyz
            sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' | cut -c 17-28,32-95 | sed -n 's/^17 / Cl /g;p' | sed -n 's/^ 6 / C /g;p' | sed -n 's/^ 1 / H /g;p' | sed -n 's/^ 7 / N /g;p' | sed -n 's/^ 8 / O /g;p' | sed -n 's/^16 / S /g;p' | cat >> ../geometries.xyz
         else
            echo $filename | cat >> ../notfinishedjoblist
            echo "job did not finish"
         fi
      else
         echo "file does not exist"
         exit
      fi
      cd ../
      sleep 1
   else
      echo $i does not exist
   fi
done
