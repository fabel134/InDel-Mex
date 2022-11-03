#[ -d results ] || mkdir results

## PRUEBA CON LA POS 21633 A 21642

# bash Abel_deleciones.sh <input> <input2>
# bash Abel_deleciones.sh 2824_S96.bam julio2
# <input1> is a bam file 
# <input2> is the id for the runs
# <input3> is a start deletion
# <input4> is a end deletion
##Note
##hacer que el script agregue  guiones al bam
if [ -z "$3" ]; then
  start=27399
else
  start=$3 # gene start
fi
ds=150       # positions before the delation from where we take the reads
pre_start=$(( ${start} - ${ds} ))

if [ -z "$4" ]; then
  end=28259
else
  end=$4 # gene start
fi
de=150        # positions after the delation from where we take the reads
pos_end=$(( ${end} + ${de} ))


##Variabls para BLAST Y FASTA
fullfile=$1
fname=$(basename $fullfile .bam)
id=$2

#Create a folder for the results with the chosen id if needed
[ -d ${id} ] || mkdir ${id}

## We cut the original bam to a sam file that only contains reads in the interest region

#RECORTA ENCABEZADOS Y LOS PASA A SAM----

samtools view -h -o ${id}/${fname}.sam $1 


grep '@' ${id}/${fname}.sam >${id}/${fname}.short.sam 

#------------------

##Consortium reads
awk -v pini=$pre_start -v pfini=$pos_end '( $4>=pini && $4<pfini ){print}' ${id}/${fname}.sam >> ${id}/${fname}.short.sam 

# NOTA: CON LOS ARCHIVOS DE ABEL NO VA A JALAR :C



### We transform the sam to fasta
samtools fasta ${id}/${fname}.short.sam | sed 's/ /_/' > ${id}/${fname}.short.fasta 

## Aligning, we aline the reads of interest in the fasta with the original genome
blastn -query ${id}/${fname}.short.fasta -subject ../reference-covid19.fasta -outfmt 6 | cut -f1,9,10 > ${id}/${fname}.blast 


## Producing reads list that align into deletion
### Quitar las vars de inicio y fin porque no se usan
awk -v ini="$start" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2<$3)){print}' ${id}/${fname}.blast |sort|uniq > ${id}/${fname}FWD-center ##Lists into deletion Fordward

awk -v ini="$start" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2>$3)){print}' ${id}/${fname}.blast |sort|uniq > ${id}/${fname}RV-center ##Lists into deletion Reverse

##--------Busqueda reads partidos en los genes-------

## Producing reads list that align into deletio

#awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2<$3)){print}' results/${fname}.blast |sort|uniq > results/${fname}FWD-center ##Lista into deletion Fordward

#awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2>$3)){print}' results/${fname}.blast |sort|uniq > results/${fname}RV-center ##Lista into deletion Reverse

##Unir los archivos center y buscar los reads partidos
#cat results/${fname}**center |awk '(($2>27000 && $3<29000)){print}'| cut -f1 | sort | uniq -c | grep '2 ' | sed 's/      2 //g' > results/${fname}.search
##Buscar las posiciones de la delecion

##Buscar la cantidad mas alta de posiciones
#prep=$(cat results/${fname}.search | while read line; do grep $line results/${fname}.blast ; done |awk '(($2>27000 && $3<29000)){print}' | cut -f2,3 | sort |uniq -c | sort -n | tail -n2)

##Buscar la posicione del read FWD mas alta
#pfa=$(cat results/${fname}.search | while read line; do grep $line results/${fname}.blast ; done |awk '(($2>27000 && $3<29000)){print}' |cut -f2 | sort |uniq -c | sort -n | tail -n2)

#Buscar la posicione del read RV mas alta
#pra=$(cat results/${fname}.search | while read line; do grep $line results/${fname}.blast ; done |awk '(($2>27000 && $3<29000)){print}' | cut -f3 | sort |uniq -c | sort -n | tail -n2)
#echo ${mes}$'\t'${fname}$'\t'${prep}$'\t'${pfa}$'\t'${pra} >> results/SncPositions
#rm results/*.sam 
#rm results/*.fasta 
#exit
##----------------------------------------------------------

#Max and min
#Forward #Read_delecion_R1_S11   a=28258   b=28319
cat ${id}/${fname}FWD-center | while read line
do
#Cambiar bi y bf por ,match_start y match_end
#Cambiar start por start_deletion 
	name_F=$(echo $line | cut -d" " -f1)
        bi=$(echo $line | cut -d" " -f2)
        bf=$(echo $line | cut -d" " -f3)
        max_f=$(( ${start} < $bi  ? $bi : $start ))
        min_f=$(( ${end} > $bf ? $bf : $end))
        t_f=$((${min_f} - ${max_f})) #Interseccion con la delecion
       # echo "blast" $bi $bf
       # echo "max" $max_f
       # echo "min" $min_f
        echo ${name_F}$'\t'${t_f}
done > ${id}/${fname}FWD-TamInt
#exit    
#Reads FWD que hacen match en dos regiones de SARS
awk '(($2>-3 && $2<3)) {print}' ${id}/${fname}FWD-TamInt  | sort | uniq -c | grep '2 ' | sed 's/ /#/g' | sed 's/######2#//g' | sed 's/\t[0-9]//' | sed 's/\t-[0-9]//' > ${id}/${fname}FWD-matchs

#Reads FWD que hacen match dentro de la delecion. #¿Cuantos reads mapean dentro de la delecion, es decir, cuantos reads estan en contra de nuestra delecion
awk '(($2>3 && $2<150)) {print}' ${id}/${fname}FWD-TamInt  | sort | uniq -c | sed 's/ /#/g' | sed 's/######1#//g' | sed 's/\t[0-9]//'  > ${id}/${fname}FWD-InDel
#----------------------------------------------------------

#Reverse #Read_delecion_R2_S11  a=28319   b=28258
##create list for reads Reverse
awk -v ini="$start" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2>$3)){print}' ${id}/${fname}.blast |sort|uniq > ${id}/${fname}RV-center ##Lista into deletion Reverse


cat ${id}/${fname}RV-center | while read line
do
        name_r=$(echo $line | cut -d" " -f1)
        bi=$(echo $line | cut -d" " -f2)
        bf=$(echo $line | cut -d" " -f3)
        max_r=$(( ${start} < $bf  ? $bf : $start ))
        min_r=$(( ${end} > $bi ? $bi : $end))
        t_r=$((${min_r} - ${max_r}))
#       echo ${name_r}$'\t'${t_r}
#        echo "blast" $bi $bf
#        echo "max" $max_r
#       echo "min" $min_r
        echo ${name_r}$'\t'${t_r}

done > ${id}/${fname}RV-TamInt

#Reads RV que hacen match en dos regiones de SARS
awk '(($2>-3 && $2<3)) {print}' ${id}/${fname}RV-TamInt  | sort | uniq -c | grep '2 ' | sed 's/ /#/g' |     sed 's/######2#//g' | sed 's/\t[0-9]//' | sed 's/\t-[0-9]//' > ${id}/${fname}RV-matchs

awk '(($2>3 && $2<150)) {print}' ${id}/${fname}RV-TamInt  | sort | uniq -c | sed 's/ /#/g' | sed 's/######1#//g' | sed 's/\t[0-9]//'  > ${id}/${fname}RV-InDel
#----------------------------------------------------------
## Producing reads list that align before deletion
#ini = 21633 pini= 21483

awk -v ini="$start" -v pin="$pre_start" '(($2<$3 && $3<=ini && $2>=pin) || ($2>$3 && $2 <= ini && $3 >= pin)){print}' ${id}/${fname}.blast |cut -f1|sort|uniq > ${id}/${fname}-izq ##Lista antes de la delecion
#NB501110:225:HFJMJAFX3:1:21102:18353:2014	2=21562	3=21721


# Producing reads list that align after deletion 
awk -v fini="$end" -v pfini="$pos_end" '(($2>$3 && $2<=pfini && $3>=fini) || ($2<$3 && $2 >= fini && $3 <= pfini)){print}' ${id}/${fname}.blast |cut -f1|sort|uniq > ${id}/${fname}-der ##Lista antes de la delecion

#### Si hay reads en ambas listas entonces alinean a ambos lados de la delecion
## producimos un archivo con los reads en comun y escribimos cuantas lineas contiene ese archivo
comm -12  ${id}/${fname}-izq ${id}/${fname}-der > ${id}/${fname}.comun

cdf=$(comm -12  ${id}/${fname}.comun ${id}/${fname}FWD-matchs | wc -l)
cdr=$(comm -12  ${id}/${fname}.comun ${id}/${fname}RV-matchs | wc -l)
wcizq=$(wc -l <${id}/${fname}-izq) 
wcder=$(wc -l < ${id}/${fname}-der) 
wccomun=$(wc -l  < ${id}/${fname}.comun)
wcFWD=$(wc -l < ${id}/${fname}FWD-matchs)
wcRV=$(wc -l < ${id}/${fname}RV-matchs)
wcInto=$(cat ${id}/${fname}RV-InDel ${id}/${fname}FWD-InDel | sort | uniq | wc -l )

## Escribimos un reporte con nombre de muestra, reads izquierdos, reads derechos, reads en comun, reads rv matchs,reads fwd match, reads rv mdc, reads fwd mdc, reads Into delecion, mes.
## mdc= metodo dos columnas:comparar los metodos dos columnas y formula Nelly
## reads rv matchs= Reads RV que hacen match en dos regiones formula Nelly
echo muestra$'\t'readsizquierdos$'\t'readsderechos$'\t'readsencomun$'\t'readsrvmatchs$'\t'readsfwdmatch$'\t'readsrvmdc$'\t'readsfwdmdc$'\t'readsIntodelecion$'\t'mes$'\t'inicio$'\t'final > ${id}/encabezado
echo ${fname}$'\t'$wcizq$'\t'$wcder$'\t'$wccomun$'\t'${wcRV}$'\t'${wcFWD}$'\t'${cdr}$'\t'${cdf}$'\t'$wcInto$'\t'${mes}$'\t'${inicio}$'\t'${final} >> ${id}/report
cat ${id}/encabezado ${id}/report > ${id}/reportFinal
#rm results/${fname}-izq  results/${fname}-der 
#results/${fname}.blast 
#rm results/*.fasta 
#rm results/*.sam
