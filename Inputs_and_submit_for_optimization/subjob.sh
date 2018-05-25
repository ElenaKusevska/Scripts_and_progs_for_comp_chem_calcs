for i in 1 2 3 4 5
do
   cd $i

   sbatch ./$i.slurm

   cd ..

   sleep 5

done

