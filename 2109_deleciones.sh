[ -d results ] || mkdir results

# bash Abel_deleciones.sh <input> 
# bash Abel_deleciones.sh 2824_S96.bam
# <iinput> is a bam file 
##Note
##hacer que el script agregue  guiones al bam
##Variables para AWK 
inicio=27889 # inicio de la delecion
di=150       # posiciones anteriores a la delecion desde donde tomamos reads
pre_inicio=$(( ${inicio} - ${di} ))
final=28111  # final de la delecion
df=150        # posiciones posteriores de la delecion hasta donde tomamos reads del bam
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

##Reads consorcio
awk -v pini=$pre_inicio -v pfini=$pos_final '( $5>=pini && $5<pfini){print}' results/${fname}.sam >> results/${fname}.short.sam 

##Read-prueba
#awk -v pini=$pre_inicio -v pfini=$pos_final '( $4>=pini && $4<pfini){print}' results/${fname}.sam >> results/${fname}.short.sam 

# pasamos ese sam a fasta
samtools fasta results/${fname}.short.sam | sed 's/ /_/' > results/${fname}.short.fasta ##convertir los archivos bam en fastas

## Aligning    Alineamos los reads de interés del fasta versus el genoma original
blastn -query results/${fname}.short.fasta -subject /LUSTRE/usuario/aherrera/covid/reference-covid19.fasta -outfmt 6 | cut -f1,9,10 > results/${fname}.blast ## Se realiza un blast muitifasa

## Producing reads list that align into deletio
awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2<$3)){print}' results/${fname}.blast |sort|uniq > results/${fname}FWD-center ##Lista into deletion Fordward

#echo awk -v ini="$inicio" -v pin="$pre_inicio" -v fini="$final" -v pfini="$pos_final" '(($2<$3)){print}' results/${fname}.blast \|sort\|uniq \> results/${fname}FWD-center ##Lista into deletion Fordward
#exit

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
awk '(($2>-3 && $2<3)) {print}' results/${fname}FWD-TamInt  | sort | uniq -c | grep '2 ' | sed 's/ /#/g' | sed 's/######2#//g' | sed 's/\t\-1//'| sed 's/\t\-2//' | sed 's/\t\-3//' | sed 's/\t\-3//' | sed 's/\t\0//' > results/${fname}FWD-matchs

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
awk '(($2>-3 && $2<3)) {print}' results/${fname}RV-TamInt  | sort | uniq -c | grep '2 ' | sed 's/ /#/g' |     sed 's/######2#//g' | sed 's/\t\-1//' | sed 's/\t\-2//'| sed 's/\t\-3//'| sed 's/\t\-3//' | sed 's/\t\0//' > results/${fname}RV-matchs
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
## Escribimos un reporte con nombre de muestra, reads izquierdos, reads derechos, reads en comun, reads fwd dobles, reads contenidos en el metodo dos columnas.
echo ${fname}$'\t'$wcizq$'\t'$wcder$'\t'$wccomun$'\t'${wcRV}$'\t'${wcFWD}$'\t'${cdr}$'\t'${cdf} >> results/report
#rm results/${fname}-izq  results/${fname}-der 
#results/${fname}.blast 
#rm results/*.fasta 
rm results/*.bam 
