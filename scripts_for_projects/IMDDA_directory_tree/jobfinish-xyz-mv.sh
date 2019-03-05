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

if [ -f optimized_geometries.xyz ]
then
   rm optimized_geometries.xyz
   echo "optimized_geometries.xyzfound and deleted"
fi

mkdir failed_jobs

for i in TS1_birad_1  TS1_birad_2
do
   for j in DMF gas o-DCB
   do
      for k in m062x b3lyp
      do
         dirs=$j'_'$k
         if [ -d "$dirs" ]
         then
            cd $j'_'$k
            if [ -d $i ]
            then
               cd $i
               filename=$i'.out'
               echo $filename $j $k
               if [ -f $filename ]
               then
                  echo "file exists"
                  if [[ -n "$(grep "Normal termination" $filename | tail -1)" ]]
                  then
                     # -n, the length of string is not zero
                     # if $i.out exists, and the job completed
                     # successfully (the output of grep "Normal termination"
                     # is not zero):
                     echo $filename $j $k | cat >> ../../finishedjoblist
                     echo $(grep 'Frequencies' $filename | head -1) | cat >> ../../finishedjoblist
                     echo $(grep 'SCF Done' -A2 $filename | tail -3) | cat >> ../../finishedjoblist
                     echo ' ' | cat >> ../../finishedjoblist
                     echo "job finished"
                     # print final geometries to .xyz file
                     sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' |  cut -c 17-19,32-95 | cat | wc -l | cat >> ../../optimized_geometries.xyz
                     echo $i $j $k | cat >> ../../optimized_geometries.xyz
                     sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' | cut -c 17-28,32-95 | sed -n 's/^17 / Cl /g;p' | sed -n 's/^ 6 / C /g;p' | sed -n 's/^ 1 / H /g;p' | sed -n 's/^ 7 / N /g;p' | sed -n 's/^ 8 / O /g;p' | sed -n 's/^16 / S /g;p' | cat >> ../../optimized_geometries.xyz
                  cd ..
                  cd ..
                  else
                     # if $i.out exists, but the job did not
                     # complete successfully:
                     cd ../
                     echo $filename $j $k | cat >> ../notfinishedjoblist
                     echo "job did not finish"
                     mkdir ../failed_jobs/$j'_'$k 2>/dev/null 
                     mv $i ../failed_jobs/$j'_'$k
                     cd ../
                  fi
               else
                  echo "file does not exist"
                  exit
               fi
            else
               echo $i $j $k does not exist
               cd ../
            fi
            sleep 1
         else
            echo $j $k does not exist
         fi
      done
   done
done
