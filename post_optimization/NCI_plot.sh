#!/bin/bash

np=1 # number of processors
m=16 # memory
i=2 # filename of original .wfn file
j='NCI_plot_'$i # name of everything for the NCIplot calculation

#------------------------------
# Prepare submit directory
#------------------------------

echo $i
mkdir $j
cp $i.wfn $j/$j.wfn
cd $j

#--------------------------------
# Prepare .nci file
#--------------------------------
echo '1' | cat >> $j.nci
echo $j.wfn | cat >> $j.nci

#-------------------------------------------
# Prepare the slurm (.sh) script:
#-------------------------------------------

echo '#!/usr/bin/bash' | cat >> $j.sh
echo '#SBATCH --time=7:00:00' | cat >> $j.sh
echo '#SBATCH --nodes=1' | cat >> $j.sh
echo '#SBATCH --ntasks=1' | cat >> $j.sh
echo '#SBATCH --cpus-per-task='$np | cat >> $j.sh
echo '#SBATCH --mem='$m'gb' | cat >> $j.sh
echo '#SBATCH --job-name='$j | cat >> $j.sh
#echo '#SBATCH --output='$j.out | cat >> $j.sh
echo '#SBATCH --partition=smp' | cat >> $j.sh
echo ' ' | cat >> $j.sh
echo 'cp /ihome/pliu/elk72/nciplot-3.0/src/* ./' | cat >> $j.sh
echo 'export NCIPLOT_HOME=/ihome/pliu/elk72/nciplot-3.0' | cat >> $j.sh
echo ./nciplot $j.nci | cat >> $j.sh
echo 'rm Make* nciplot *.f90 *.mod *.o' | cat >> $j.sh
echo ' ' | cat >> $j.sh
echo ' ' | cat >> $j.sh

cd ..

