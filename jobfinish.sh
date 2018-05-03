for i in 1
do
   cd $i
   echo ' '
   echo '--------------------------------'
   echo $i:
   echo '--------------------------------'
   echo ' '
   cat *.out | tail -7
   cd ..

   sleep 5
done

