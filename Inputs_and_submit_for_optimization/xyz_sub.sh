k=B6V
for i in {5..7} 
do 

#-------------------------------------------------------------------
#to create the input file:
#-------------------------------------------------------------------

	echo $i
	mkdir $i
	cp $i.xyz $i
	rm $i.xyz
	cd $i
	
   	j=$(pwd)
	echo $j

	echo %mem=6000mb | cat >> $i-$k
	echo %chk=$j/$i-$k.chk | cat >> $i-$k
	echo '#p opt=(maxcycles=400) tpssh/6-311+g(d) nosymm output=wfn' | cat >> $i-$k

	echo ' ' | cat >> $i-$k
	echo $i | cat >> $i-$k
	echo ' ' | cat >> $i-$k

	echo '0 2' | cat >> $i-$k
	sed '/ B \| V /!d' $i.xyz | cat >> $i-$k

	echo ' ' | cat >> $i-$k
	echo $j/$i-$k.wfn | cat >> $i-$k
	echo ' ' | cat >> $i-$k
	
#---------------------------------------------------------------
#to submit the job to one of the queues:
#---------------------------------------------------------------

	for n in {0..30}
	do
		let "x=1+3*$n"
		let "y=2+3*$n"
		let "z=3+3*$n"
		
		if [[ $i -eq $x ]]; then 
			echo x = $x
			w=10
			break
		fi
		if [[ $i -eq $y ]]; then
			echo y = $y
			w=10
			break
		fi
		if [[ $i -eq $z ]]; then
			echo z = $z
			w=10
			break
		fi
	done
	subg09 g$w $i-$k /temp0/elena
cd ../

done


