for i in 1
do
   if [ -d $i ]; then
      cd $i
      echo ' '
      echo '--------------------------------'
      echo $i:
      echo '--------------------------------'
      echo ' '
      cat *.out | tail -
      echo ' '
      grep 'SCF Done' *out | tail -1
      echo ' '
      cd ..

      sleep 5
   fi
done

