for i in 1 2 3 4 5
do
   echo $i
   if [ -d "$i" ]; then
      cd $i
      filename=$i'.slurm'
      if [ -e "$filename" ]; then
         #sed -i -e 's/time=72:00:00/time=17:00:00/g' $filename
         sbatch ./$filename
         cd ..
         sleep 1
      else
         echo $filename does not exist
         exit
      fi
   else
      echo $i does not exist
   fi
done

