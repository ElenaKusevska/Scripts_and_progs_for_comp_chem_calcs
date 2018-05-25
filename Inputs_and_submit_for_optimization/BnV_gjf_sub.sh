k=B3V2
for i in {17..31} 
do 

#-------------------------------------------------------------------
#to create the input file:
#-------------------------------------------------------------------

	echo $i
	mkdir $i
	dos2unix $i.gjf
	cp $i.gjf $i
	rm $i.gjf
	cd $i
	
   j=$(pwd)
	echo $j

	echo %chk=$i-$k.chk | cat >> $i-$k.com
	echo '#p opt=(maxcycles=400) tpssh/6-311+g(d) nosymm output=wfn' | cat >> $i-$k.com

	echo ' ' | cat >> $i-$k.com
	echo $i | cat >> $i-$k.com
	echo ' ' | cat >> $i-$k.com

	sed -i 's/150 6-/B/g' $i.gjf
	sed -i 's/400 6-/A/g' $i.gjf
	grep -e '0 1' -e '0 2' -e '0 3' -e '0 4' -e '0 5' -e '0 6' $i.gjf | head -1 | cat >> $i-$k.com
	sed '/ B \| V /!d' $i.gjf | cat >> $i-$k.com

	echo ' ' | cat >> $i-$k.com
	echo $i-$k.wfn | cat >> $i-$k.com
	echo ' ' | cat >> $i-$k.com

#--------------------------------------------------------------
#  make all molecules low spin:
#--------------------------------------------------------------

	sed -i 's/0 3/0 1/g' $i-$k.com
	sed -i 's/0 5/0 1/g' $i-$k.com
	sed -i 's/0 4/0 2/g' $i-$k.com
	sed -i 's/0 6/0 2/g' $i-$k.com

#--------------------------------------------------------------
#  make all molecules high spin:
#--------------------------------------------------------------

#	sed -i 's/0 5/0 3/g' $i-$k.com
#	sed -i 's/0 1/0 3/g' $i-$k.com
#	sed -i 's/0 2/0 4/g' $i-$k.com
#  sed -i 's/0 6/0 4/g' $i-$k.com

#---------------------------------------------------------------
#  reallyhighspin:
#---------------------------------------------------------------

#  sed -i 's/0 1/0 5/g' $i-$k.com
#  sed -i 's/0 3/0 5/g' $i-$k.com
#  sed -i 's/0 2/0 6/g' $i-$k.com
#  sed -i 's/0 4/0 6/g' $i-$k.com
	
#---------------------------------------------------------------
# to submit the job to one of the queues:
#---------------------------------------------------------------

	for n in {0..30}
	do
		let "x=1+3*$n"
		let "y=2+3*$n"
		let "z=3+3*$n"
		
		if [[ $i -eq $x ]]; then 
			echo x = $x
			subg09 ccc $i-$k.com heavy 4
			break
		fi
		if [[ $i -eq $y ]]; then
			echo y = $y
			subg09 ccc $i-$k.com heavy 4
			break
		fi
		if [[ $i -eq $z ]]; then
			echo z = $z
			subg09 fastp $i-$k.com moleculas 2
			break
		fi
	done
cd ../

sleep 2

done


