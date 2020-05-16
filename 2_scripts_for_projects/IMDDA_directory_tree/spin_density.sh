#!/bin/bash

np=2 # number of processors
m=8 # memory
i=2

for i in 1
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
               echo $i $j $k
               rm *.out *.chk *.g16 *.log *.wfn *.gjf *.slurm
               
               #-------------------------------------------
               # Prepare the slurm script:
               #-------------------------------------------
               
               echo '#!/usr/bin/env bash' | cat >> $i.slurm
               echo '#SBATCH --time=2:00:00' | cat >> $i.slurm
               echo '#SBATCH --nodes=1' | cat >> $i.slurm
               echo '#SBATCH --ntasks=1' | cat >> $i.slurm
               echo '#SBATCH --cpus-per-task='$np | cat >> $i.slurm
               echo '#SBATCH --mem='$m'gb' | cat >> $i.slurm
               echo '#SBATCH --job-name='$i | cat >> $i.slurm
               echo '#SBATCH --output='$i.out | cat >> $i.slurm
               echo '#SBATCH --partition=smp' | cat >> $i.slurm
               echo ' ' | cat >> $i.slurm
               echo module purge | cat >> $i.slurm
               echo module load gaussian/16-A.03 | cat >> $i.slurm
               echo ' ' | cat >> $i.slurm
               echo ulimit -s unlimited | cat >> $i.slurm
               echo export LC_COLLATE=C | cat >> $i.slurm
               echo ' ' | cat >> $i.slurm
               echo cubegen $np Spin=SCF $i.fchk $i.cube 100 h | cat >> $i.slurm
               echo ' ' | cat >> $i.slurm
               echo ' ' | cat >> $i.slurm
               
               cd ..
               cd ..
               sleep 1
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
