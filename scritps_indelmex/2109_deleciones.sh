[ -d results ] || mkdir results

# bash Abel_deleciones.sh <input> <input2>
# bash Abel_deleciones.sh 2824_S96.bam julio2
# <input1> is a bam file 
# <input2> is a month
# <input3> is a start deletion
# <input4> is a end deletion
##Note
##hacer que el script agregue  guiones al bam
##Variables para AWK 
inicio=$3 # inicio de la delecion
di=150       # posiciones anteriores a la delecion desde donde tomamos reads
pre_inicio=$(( ${inicio} - ${di} ))
final=$4  # final de la delecion
df=150        # posiciones posteriores de la delecion hasta donde tomamos reads del bam
pos_final=$(( ${final} + ${df} ))

# echo inicio $inicio delta inicio $di el scaneo empieza en $pre_inicio
# echo final $final delta final $df el scaneo empieza en $pos_final
##Variabls para BLAST Y FASTA
fullfile=$1
fname=$(basename $fullfile .bam)
mes=$2
work_directory=$(pwd)
# echo file name is $fname

#echo month is $mes

## Recortamos el bam original hasta un archivo sam que solo contenga reads en la region de interes
samtools view -h -o results/${fname}.sam $1 
grep '@' results/${fname}.sam >results/${fname}.short.sam 

##Reads consorcio
awk -v pini=$pre_inicio -v pfini=$pos_final '( $5>=pini && $5<pfini){print}' results/${fname}.sam >> results/${fname}.short.sam 

##Read-prueba
#awk -v pini=$pre_inicio -v pfini=$pos_final '( $4>=pini && $4<pfini){print}' results/${fname}.sam >> results/${fname}.short.sam 

# pasamos ese sam a fasta
samtools fasta results/${fname}.short.sam | sed 's/ /_/' > results/${fname}.short.fasta ##convertir los archivos bam en fastas

## Aligning    Alineamos los reads de interés del fasta versus el genoma original
blastn -query results/${fname}.short.fasta -subject ${work_directory}/reference-covid19.fasta -outfmt 6 | cut -f1,9,10 > results/${fname}.blast ## Se realiza un blast muitifasa

## Producing reads list that align into deletio
awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2<$3)){print}' results/${fname}.blast |sort|uniq > results/${fname}FWD-center ##Lista into deletion Fordward

awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2>$3)){print}' results/${fname}.blast |sort|uniq > results/${fname}RV-center ##Lista into deletion Reverse

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
cat results/${fname}FWD-center | while read line
do
	name_F=$(echo $line | cut -d" " -f1)
        bi=$(echo $line | cut -d" " -f2)
        bf=$(echo $line | cut -d" " -f3)
        max_f=$(( ${inicio} < $bi  ? $bi : $inicio ))
        min_f=$(( ${final} > $bf ? $bf : $final))
        t_f=$((${min_f} - ${max_f}))
       # echo "blast" $bi $bf
       # echo "max" $max_f
       # echo "min" $min_f
        echo ${name_F}$'\t'${t_f}
done > results/${fname}FWD-TamInt
#exit    
#Reads FWD que hacen match en dos regiones de SARS
awk '(($2>-3 && $2<3)) {print}' results/${fname}FWD-TamInt  | sort | uniq -c | grep '2 ' | sed 's/ /#/g' | sed 's/######2#//g' | sed 's/\t[0-9]//' | sed 's/\t-[0-9]//' > results/${fname}FWD-matchs

#Reads FWD que hacen match dentro de la delecion. #¿Cuantos reads mapean dentro de la delecion, es decir, cuantos reads estan en contra de nuestra delecion
awk '(($2>3 && $2<150)) {print}' results/${fname}FWD-TamInt  | sort | uniq -c | sed 's/ /#/g' | sed 's/######1#//g' | sed 's/\t[0-9]//'  > results/${fname}FWD-InDel
#----------------------------------------------------------

#Reverse #Read_delecion_R2_S11  a=28319   b=28258
##create list for reads Reverse
awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2>$3)){print}' results/${fname}.blast |sort|uniq > results/${fname}RV-center ##Lista into deletion Reverse


cat results/${fname}RV-center | while read line
do
        name_r=$(echo $line | cut -d" " -f1)
        bi=$(echo $line | cut -d" " -f2)
        bf=$(echo $line | cut -d" " -f3)
        max_r=$(( ${inicio} < $bf  ? $bf : $inicio ))
        min_r=$(( ${final} > $bi ? $bi : $final))
        t_r=$((${min_r} - ${max_r}))
#       echo ${name_r}$'\t'${t_r}
#        echo "blast" $bi $bf
#        echo "max" $max_r
#       echo "min" $min_r
        echo ${name_r}$'\t'${t_r}

done > results/${fname}RV-TamInt

#Reads RV que hacen match en dos regiones de SARS
awk '(($2>-3 && $2<3)) {print}' results/${fname}RV-TamInt  | sort | uniq -c | grep '2 ' | sed 's/ /#/g' |     sed 's/######2#//g' | sed 's/\t[0-9]//' | sed 's/\t-[0-9]//' > results/${fname}RV-matchs

awk '(($2>3 && $2<150)) {print}' results/${fname}RV-TamInt  | sort | uniq -c | sed 's/ /#/g' | sed 's/######1#//g' | sed 's/\t[0-9]//'  > results/${fname}RV-InDel
#----------------------------------------------------------
## Producing reads list that align before deletion
awk -v ini="$inicio" -v pin="$pre_inicio" '(($2<$3 && $2<=ini && $3>=pin) || ($2>$3 && $2 <= ini && $3 >= pin)){print}' results/${fname}.blast |cut -f1|sort|uniq > results/${fname}-izq ##Lista antes de la delecion

# Producing reads list that align after deletion 
awk -v fini="$final" -v pfini="$pos_final" '(($2>$3 && $2<=pfini && $3>=fini) || ($2<$3 && $2 >= fini && $3 <= pfini)){print}' results/${fname}.blast |cut -f1|sort|uniq > results/${fname}-der ##Lista antes de la delecion
#### Si hay reads en ambas listas entonces alinean a ambos lados de la delecion
## producimos un archivo con los reads en comun y escribimos cuantas lineas contiene ese archivo
comm -12  results/${fname}-izq results/${fname}-der > results/${fname}.comun

cdf=$(comm -12  results/${fname}.comun results/${fname}FWD-matchs | wc -l)
cdr=$(comm -12  results/${fname}.comun results/${fname}RV-matchs | wc -l)
wcizq=$(wc -l <results/${fname}-izq) 
wcder=$(wc -l < results/${fname}-der) 
wccomun=$(wc -l  < results/${fname}.comun)
wcFWD=$(wc -l < results/${fname}FWD-matchs)
wcRV=$(wc -l < results/${fname}RV-matchs)
wcInto=$(cat results/${fname}RV-InDel results/${fname}FWD-InDel | sort | uniq | wc -l )

## Escribimos un reporte con nombre de muestra, reads izquierdos, reads derechos, reads en comun, reads rv matchs,reads fwd match, reads rv mdc, reads fwd mdc, reads Into delecion, mes.
## mdc= metodo dos columnas:comparar los metodos dos columnas y formula Nelly
## reads rv matchs= Reads RV que hacen match en dos regiones formula Nelly
echo muestra$'\t'readsizquierdos$'\t'readsderechos$'\t'readsencomun$'\t'readsrvmatchs$'\t'readsfwdmatch$'\t'readsrvmdc$'\t'readsfwdmdc$'\t'readsIntodelecion$'\t'mes$'\t'inicio$'\t'final > results/encabezado
echo ${fname}$'\t'$wcizq$'\t'$wcder$'\t'$wccomun$'\t'${wcRV}$'\t'${wcFWD}$'\t'${cdr}$'\t'${cdf}$'\t'$wcInto$'\t'${mes}$'\t'${inicio}$'\t'${final} >> results/report
cat results/encabezado results/report > results/reportFinal
#rm results/${fname}-izq  results/${fname}-der 
#results/${fname}.blast 
#rm results/*.fasta 
#rm results/*.sam
