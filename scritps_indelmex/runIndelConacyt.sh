cat results/FinalPos | while read line
#cat results/FinalPos |head -n1 | while read line
do
input1=$(echo $line | cut -d' ' -f1)
input2=$(echo $1)
input3=$(echo $line | cut -d' ' -f2)
input4=$(echo $line | cut -d' ' -f3)
work_directory=$(pwd)
#echo bash 2109_deleciones.sh ${work_directory}/sample_data/$input1.bam $input2 $input3 $input4 


bash /app/LANGEBIO/InDel-Mex/scritps_indelmex/2109_deleciones.sh ${work_directory}/bam/$input1.bam $input2 $input3 $input4 

#echo bash /app/LANGEBIO/InDel-Mex/scritps_indelmex/2109_deleciones.sh ${work_directory}/bam/$input1.bam $input2 $input3 $input4 
done
