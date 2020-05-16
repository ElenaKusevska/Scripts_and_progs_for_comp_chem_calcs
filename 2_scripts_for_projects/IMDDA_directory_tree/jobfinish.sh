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

for i in 1 1_11  1_13  1_15  1_17  1_19  1_20  1_4  1_6  1_8 1_10  1_12  1_14  1_16  1_18  1_2   1_3   1_5  1_7  1_9
do
   for j in DMF gas o-DCB
   do
      for k in m062x b3lyp
      do
         cd $j'_'$k
         #pwd
         #cd $i'_'$j'_'$k
         if [ -d $i ]
         then
            cd $i
            #filename=$i'_'$j'_'$k'.out'
            filename=$i'.out'
            echo $filename $j $k
            if [ -f $filename ]
            then
               echo "file exists"
               if [[ -n "$(grep "Normal termination" $filename | tail -1)" ]]
               then
                  # -n, the length of string is not zero
                  echo $filename $j $k | cat >> ../../finishedjoblist
                  echo "job finished"
               else
                  echo $filename $j $k | cat >> ../../notfinishedjoblist
                  echo "job did not finish"
               fi
            else
               echo "file does not exist"
               exit
            fi
            cd ..
            cd ..
         else
            echo $i $j $k does not exist
            cd ..
         fi
         sleep 2
      done
   done
done
