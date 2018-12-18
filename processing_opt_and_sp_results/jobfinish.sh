#!/bin/bash

if [ -f finishedjoblist ]; then
   rm finishedjoblist
   echo "finishedjoblist found and deleted"
fi

if [ -f notfinishedjoblist ]; then
   rm notfinishedjoblist
   echo "notfinishedjoblist found and deleted"
fi

for i in 10  11  12  2  3  4  6  7  8  9_11
do
   if [ -d $i ]; then
      cd $i
      filename=$i'.out'
      echo $filename
      if [ -f $filename ]; then
         echo "file exists"
         if [[ -n "$(grep "Normal termination" $filename | tail -1)" ]]; then
            # -n, the length of string is not zero
            echo $i | cat >> ../finishedjoblist
            echo "job finished"
         else
            echo $i | cat >> ../notfinishedjoblist
            echo "job did not finish"
         fi
         cd ..
      else
         echo "file does not exist"
         exit
      fi
   else
      echo $i does not exist
   fi
   sleep 2
done

