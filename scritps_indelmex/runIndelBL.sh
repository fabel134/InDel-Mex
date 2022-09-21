cat results/FinalPos | while read line
do
input1=$(echo $line | cut -d' ' -f1)
input2=$(echo prueba)
input3=$(echo $line | cut -d' ' -f2)
input4=$(echo $line | cut -d' ' -f3)

#echo bash 2109_deleciones.sh ../sample_data/$input1.bam $input2 $input3 $input4 
bash 2109_deleciones.sh ../sample_data/$input1.bam $input2 $input3 $input4 

done
