k=411
echo k, $k
i='HF_orb'
echo i, $i
mkdir $i
cp $k.chk $i/$k-$i.chk
cd $i

#-------------------------------------------------------------------
#to create the input file:
#-------------------------------------------------------------------

j=$(pwd)
echo j, $j

echo %chk=$j/$k-$i | cat >> $k-$i.com
echo '#p hf/cc-pvtz formcheck gfinput symmetry=(loose) pop=full geom=AllCheck' | cat >> $k-$i.com
echo '  ' | cat >> $k-$i.com

cd ../

