#!/bin/bash

# A safer version of "rm".
# Because rm is too dangerous.
# (I know this is bad practice...)

# to use in home directory:
# create a 'trash' folder in home directory
# alias rm='/home/directory/username/trash.sh'
# alias delete='command rm'

home_dir='/home/directory/username/trash'

#------------------------------------
# Make sure command line arguments
# (filenames) are provided:
#------------------------------------

if [ $# -eq 0 ]; then
   echo ' '
   echo $0: no arguments provided for "rm"
   echo ' '
   exit 1


#----------------------------------------
# If commandline arguments are provided
# Remove the files specified:
#----------------------------------------

elif [ $# -ne 0 ]; then 

   #--------------------------------------
   # if the trash directory exists:
   #--------------------------------------

   if [ -d "$home_dir/trash" ]; then
      for filename in "$@"
      do

         #-----------------------------------------------
         # If there already exists a file/directory with
         # the same name as the one being deleted:
         #-----------------------------------------------

         if [ -d "$home_dir/trash/$filename" ]; then
            echo ' '
            echo A directory -$filename- already exists in $home_dir/trash that would be overwritten. Overwrite? '[Y/N]'
            read overwrite
            if [ $overwrite == 'Y' ]; then
               rm -r $home_dir/trash/$filename
               mv $filename $home_dir/trash
               echo ' '
               echo Removed -$filename-
               echo ' '
            else
               echo ' '
               echo OK
               echo ' '
            fi
         elif [ -f "$home_dir/trash/$filename" ]; then
            echo ' '
            echo A file -$filename- already exists in $home_dir/trash that would be overwritten. Overwrite? '[Y/N]'
            read overwrite
            if [ $overwrite == 'Y' ]; then
               rm -r $home_dir/trash/$filename
               mv $filename $home_dir/trash
               echo ' '
               echo Removed -$filename-
               echo ' '
            else 
               echo ' '
               echo OK
               echo ' '
            fi

         #---------------------------------------
         # If there is no such file/directory
         # then, no problem:
         #---------------------------------------

         else
            mv $filename $home_dir/trash
            echo ' '
            echo Removed -$filename-
            echo ' '
         fi
      done

      #-------------------------------
      # if the trash directory does 
      # not exist:
      #-------------------------------

      else
         echo $home_dir/trash does not exist. Create a -trash- folder in your home directory.
   fi
fi
