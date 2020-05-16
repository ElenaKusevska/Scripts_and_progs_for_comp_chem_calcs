#!/bin/bash 

for i in 9
do
   for j in DMF gas o-DCB
   do
      for k in m062x b3lyp
      do
         dirs=$j'_'$k
         if [ -d "$dirs" ]; then
            cd $j'_'$k
            if [ -d "$i" ]; then
               cd $i
               filename=$i'.slurm'
               echo $filename $j $k
               if [ -e $filename ]
               then
                  echo "ok"
               else
                  echo "nok"
                  exit
               fi
               #sed -i -e 's/time=72:00:00/time=17:00:00/g' $filename
               sbatch ./$filename
               cd ..
               cd ..
               #sleep 1
            else
               echo $j'_'$k'/'$i does not exist
               cd ..
            fi
         else
            echo $j'_'$k does not exist
         fi
      done
   done
done
