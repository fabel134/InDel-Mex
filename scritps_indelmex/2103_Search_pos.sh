[ -d results ] || mkdir results

# bash Abel_deleciones.sh <input> <input2>
# bash Abel_deleciones.sh 2824_S96.bam julio2
# <input> is a bam file 
# <input2> is a month
##Note
##hacer que el script agregue  guiones al bam
##Variables para AWK 
inicio=27399 # inicio del gen 
di=150       # posiciones anteriores a la delecion desde donde tomamos reads
pre_inicio=$(( ${inicio} - ${di} ))
final=28259  # final del gen
df=150        # posiciones posteriores de la delecion hasta donde tomamos reads del bam
pos_final=$(( ${final} + ${df} ))

# echo inicio $inicio delta inicio $di el scaneo empieza en $pre_inicio
# echo final $final delta final $df el scaneo empieza en $pos_final
##Variabls para BLAST Y FASTA
fullfile=$1
fname=$(basename $fullfile .bam)
mes=$2
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
#blastn -query results/${fname}.short.fasta -subject /LUSTRE/usuario/aherrera/covid/reference-covid19.fasta -outfmt 6 | cut -f1,9,10 > results/${fname}.blast ## Se realiza un blast muitifasa ## line for run mazorka

blastn -query results/${fname}.short.fasta -subject /home/betterlab/abel/InDel-Mex/reference-covid19.fasta -outfmt 6 | cut -f1,9,10 > results/${fname}.blast ## Se realiza un blast muitifasa # line for run in Betterlab

## Producing reads list that align into deletio
#awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2<$3)){print}' results/${fname}.blast |sort|uniq > results/${fname}FWD-center ##Lista into deletion Fordward

##--------Busqueda reads partidos en los genes-------

## Producing reads list that align into deletio

awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2<$3)){print}' results/${fname}.blast |sort|uniq > results/${fname}FWD-center ##Lista into deletion Fordward

awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2>$3)){print}' results/${fname}.blast |sort|uniq > results/${fname}RV-center ##Lista into deletion Reverse

##Unir los archivos center y buscar los reads partidos
cat results/${fname}**center |awk '(($2>27000 && $3<29000)){print}'| cut -f1 | sort | uniq -c | grep '2 ' | sed 's/      2 //g' > results/${fname}.search
##Buscar las posiciones de la delecion

##Buscar la cantidad mas alta de posiciones
prep=$(cat results/${fname}.search | while read line; do grep $line results/${fname}.blast ; done |awk '(($2>27000 && $3<29000)){print}' | cut -f2,3 | sort |uniq -c | sort -n | tail -n2)

##Buscar la posicione del read FWD mas alta
pfa=$(cat results/${fname}.search | while read line; do grep $line results/${fname}.blast ; done |awk '(($2>27000 && $3<29000)){print}' |cut -f2 | sort |uniq -c | sort -n | tail -n2)

#Buscar la posicione del read RV mas alta
pra=$(cat results/${fname}.search | while read line; do grep $line results/${fname}.blast ; done |awk '(($2>27000 && $3<29000)){print}' | cut -f3 | sort |uniq -c | sort -n | tail -n2)
echo ${mes}$'\t'${fname}$'\t'${prep}$'\t'${pfa}$'\t'${pra} >> results/SncPositions

sed 's/ /\t/g' results/SncPositions  | cut -f2,6,5 >> results/FinalPos
#rm results/*.sam 
#rm results/*.fasta 
rm results/SncPositions
#exit
##--------
