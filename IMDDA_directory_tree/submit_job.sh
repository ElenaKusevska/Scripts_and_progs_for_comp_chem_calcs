#!/bin/bash 

for i in 9 9_1 9_2 9_3 9_4 9_5 9_6 9_7 9_8 9_9 9_10 9_11 
do
   for j in DMF gas o-DCB
   do
      for k in m062x b3lyp
      do
         cd $j'_'$k
         #cd $i'_'$j'_'$k
         cd $i
         #filename=$i'_'$j'_'$k'.slurm'
         filename=$i'.slurm'
         echo $filename $j $k
         if [ -e $filename ]
         then
            echo "ok"
         else
            echo "nok"
            exit
         fi
         sbatch ./$filename
         cd ..
         cd ..
         sleep 1
      done
   done
done
