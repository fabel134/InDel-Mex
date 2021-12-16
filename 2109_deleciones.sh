[ -d results ] || mkdir results

# bash Abel_deleciones.sh <input> 
# bash Abel_deleciones.sh 2824_S96.bam
# <iinput> is a bam file 

##Variables para AWK 
inicio=27825 # inicio de la delecion
#di=150       # posiciones anteriores a la delecion desde donde tomamos reads
di=200	#Reads falsos
pre_inicio=$(( ${inicio} - ${di} ))
final=28233  # final de la delecion
#df=150        # posiciones posteriores de la delecion hasta donde tomamos reads del bam
df=200 #Reads falsos
pos_final=$(( ${final} + ${df} ))

# echo inicio $inicio delta inicio $di el scaneo empieza en $pre_inicio
# echo final $final delta final $df el scaneo empieza en $pos_final

##Variabls para BLAST Y FASTA
fullfile=$1
fname=$(basename $fullfile .bam)
# echo file name is $fname

## Recortamos el bam original hasta un archivo sam que solo contenga reads en la region de interes
samtools view -h -o results/${fname}.sam $1 
grep '@' results/${fname}.sam >results/${fname}.short.sam 
awk -v pini=$pre_inicio -v pfini=$pos_final '( $5>=pini && $5<pfini){print}' results/${fname}.sam >> results/${fname}.short.sam 
exit 

# pasamos ese sam a fasta
samtools fasta results/${fname}.short.sam | sed 's/ /_/' > results/${fname}.short.fasta ##convertir los archivos bam en fastas

## Aligning    Alineamos los reads de interés del fasta versus el genoma original
blastn -query results/${fname}.short.fasta -subject ../reference-covid19.fasta -outfmt 6 | cut -f1,9,10 > results/${fname}.blast ## Se realiza un blast muitifasa


### Ahora hacemos dos listas una con con reads a la derecha y otra a la izquierda de la delecion
## Producing reads list that align before deletion
awk -v ini="$inicio" -v pin="$pre_inicio" '(($2<$3 && $2>=ini && $3<pin) || ($2>$3 && $2 <= ini && $3 >= pin)){print}' results/${fname}.blast |cut -f1|sort|uniq > results/${fname}-izq ##Lista antes de la delecion

# Producing reads list that align after deletion 
awk -v fini="$final" -v pfini="$pos_final" '(($2>$3 && $2<=pfini && $3>fini) || ($2<$3 && $2 >= fini && $3 <= pfini)){print}' results/${fname}.blast |cut -f1|sort|uniq > results/${fname}-der ##Lista antes de la delecion
#### Si hay reads en ambas listas entonces alinean a ambos lados de la delecion
## producimos un archivo con los reads en comun y escribimos cuantas lineas contiene ese archivo
comm -12  results/${fname}-izq results/${fname}-der > results/${fname}.comun

wcizq=$(wc -l <results/${fname}-izq) 
wcder=$(wc -l < results/${fname}-der) 
wccomun=$(wc -l  < results/${fname}.comun)

## Escribimos un reporte con nombre de muestra, reads izquierdos, reads derechos y reads en comun
echo ${fname} $wcizq $wcder $wccomun >> results/report

rm results/${fname}-izq  results/${fname}-der 
#results/${fname}.blast 
rm results/*.fasta 
rm results/*.bam 
