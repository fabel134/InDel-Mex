## bash 01file-move.sh mesfalso 

new_month=$1
work_dir="/app/LANGEBIO/${new_month}"

##create file (month) 
##Copy file in new Chapter
cp Master-Script/* ${new_month}/
##Make a new directory "reads"
cd ${work_dir}
mkdir ${work_dir}/reads
cd ${work_dir}/reads

##Create symbol link
#find ${work_dir}/AH1COV2*/* . -name "*fastq*" -exec ln -s {} . ';'

find ${work_dir}/AH1COV*/* . -name "*fastq*" -exec ln -s {} . ';'

#find ${work_dir}/SARS*/* . -name "*fastq*" -exec ln -s {} . ';' #AnalisisNoe
##Create preliminary list 
ls ${work_dir}/reads | grep "L001_R1" > ../muestras.txt
#ls ${work_dir}/reads | grep "fastq" > ../muestras.txt
##"sample" filter
sed 's/_L001_R1_001.fastq.gz//g' ${work_dir}/muestras.txt > ${work_dir}/listaMuestras.txt

#sed 's/_L001_R1_001.fastq//g' ${work_dir}/muestras.txt > ${work_dir}/listaMuestras.txt ##analisisNoe
#sed 's/.fastq//g' ${work_dir}/muestras.txt > ${work_dir}/listaMuestras.txt
#rm ${work_dir}/muestras.txt #delete file "muestras.txt"
######## Numero de lineas totales del archivo listaMuestras equivale al numero de muestras
total_muestra=$(wc -l < ${work_dir}/listaMuestras.txt)
#echo total_muestra ${total_muestra}

#### real_list numero de lineas que queremos en cada sublista de muestras (al dividir lista muestras entre10)
real_list=$((${total_muestra}/10))
# resto=$((${total_muestra}%10))
# echo total ${real_list} ${resto}
##create file 
mkdir ${work_dir}/listaReads
cd ${work_dir}/listaReads
##split file divide kistaMuestras en varios archivos con numero de lineas real_list (ej real_list=50 si total_muestra=500) 
split -l ${real_list} ${work_dir}/listaMuestras.txt listaMuestras
# echo split -l ${real_list} ${work_dir}/listaMuestras.txt listaMuestras
#exit 
##Change_name 
count=1
for name in ${work_dir}/listaReads/*; 
do 
	mv $name listaMuestras${count}.txt; count=$((count+1)); 
done

##copy file "scripts"
total_script=$(ls ${work_dir}/listaReads/ |wc -l)
#echo wc -l ${work_dir}/listaReads/*
echo total_script ${total_script}
#exit

mkdir ${work_dir}/scripts
for i in $(eval echo {1..$total_script}); 
do 
	cp ${work_dir}/scriptEnsambladoCovidBlanca.sh ${work_dir}/scripts/${i}-EnsamCoV.sh  
	sed -i "s/NUMnoviembre/${i}Cov${new_month}/g" ${work_dir}/scripts/${i}-EnsamCoV.sh 

#echo	cp ${work_dir}/EnsamCoV.sh ${work_dir}/scripts/${i}-EnsamCoV.sh ; 
done

## edit file "EnsamCov" in the correct format
cd ${work_dir}/scripts/
sed -i "s/noviembre/${new_month}/g" *EnsamCoV* 
#echo sed -i "s/noviembre/${new_month}/g" *EnsamCoV* 
#exit
rm scriptEnsambladoCovidBlanca.sh scriptEnsambladoCovidBlanca.sh 
for i in $(eval echo {1..$total_script});
do 
	sed -i "s/listaMuestras/listaMuestras${i}/" ${i}-EnsamCoV.sh;

#echo	sed -i "s/listaMuestras/listaMuestras${i}/" ${i}-EnsamCoV.sh;
done 
#exit

for i in $(eval echo {1..$total_script});
do 
	sed -i "s/error/error${i}/" ${i}-EnsamCoV.sh;
#	echo sed -i "s/error/error${i}/" ${i}-EnsamCoV.sh;
	sed -i "s/out/out${i}/" ${i}-EnsamCoV.sh;
#	echo sed -i "s/out/out${i}/" ${i}-EnsamCoV.sh;
done
#exit

#for i in $(eval echo {1..$total_script});
#do
#        qsub ${work_dir}/scripts/${i}-EnsamCoV.sh;
#        echo qsub ${work_dir}/scripts/${i}-EnsamCoV.sh;
#done

#rm ${work_dir}/listaMuestras.txt
#rm ${work_dir}/muestras.txt
#rm ${work_dir}/scriptEnsambladoCovidBlanca.sh 
