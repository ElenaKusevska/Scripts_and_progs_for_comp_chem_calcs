#!/bin/bash

# prepare higher level of theory calculation from lower
# level of theory one. 

for i in {1..5}

#-------------------------------------------------------------------
#to create the input file:
#-------------------------------------------------------------------

	echo $i
	dos2unix $i.gjf
   	j=$(pwd)
	echo $j

	echo %chk=$i.chk | cat >> $i.com
	echo '#p opt=(maxcycles=400) freq tpssh/cc-pvtz symmetry=loose pop=full output=wfn' | cat >> $i.com

	echo ' ' | cat >> $i.com
	echo $i | cat >> $i.com
	echo ' ' | cat >> $i.com

	grep -e '0 1' -e '0 2' -e '0 3' -e '0 4' -e '0 5' -e '0 6' $i.gjf | head -1 | cat >> $i.com
	sed '/ B \| V /!d' $i.gjf | cat >> $i.com

	echo ' ' | cat >> $i.com
	echo $i.wfn | cat >> $i.com
	echo ' ' | cat >> $i.com

