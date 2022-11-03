# bash 2103_Search_pos.sh <input> <input2>
# bash 2103_Search_po.sh 2824_S96.bam julio2
# <input> is a bam file 
# <input2> is the id for the run
### start Y end SON OPCIONALES
##Variables for AWK 
start=27399 # gene start
ds=150       # positions before the delation from where we take the reads
pre_start=$(( ${start} - ${ds} ))
end=28259  # gene end
de=150        # positions after the delation from where we take the reads
pos_end=$(( ${end} + ${de} ))

#echo inicio $start delta inicio $ds el scaneo empieza en $pre_start
#echo final $end delta final $de el scaneo empieza en $pos_end

  ##Variables for BLAST Y FASTA
fullfile=$1
fname=$(basename $fullfile .bam)
id=$2

#Create a folder for the results with the chosen id if needed
[ -d ${id} ] || mkdir ${id}

## We cut the original bam to a sam file that only contains reads in the interest region
samtools view -h -o  ${id}/${fname}.sam $1 
grep '@' ${id}/${fname}.sam > ${id}/${fname}.short.sam 

##Consortium reads
awk -v pini=$pre_start -v pfini=$pos_end '( $5>=pini && $5<pfini){print}' ${id}/${fname}.sam >> ${id}/${fname}.short.sam 


### We transform the sam to fasta
samtools fasta ${id}/${fname}.short.sam | sed 's/ /_/' > ${id}/${fname}.short.fasta 

## Aligning, we aline the reads of interest in the fasta with the original genome
blastn -query ${id}/${fname}.short.fasta -subject ../reference-covid19.fasta -outfmt 6 | cut -f1,9,10 > ${id}/${fname}.blast 

##-------- Search reads matches in genes -------

## Producing reads list that align into deletion

awk -v ini="$start" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2<$3)){print}' ${id}/${fname}.blast |sort|uniq > ${id}/${fname}FWD-center ##Lista into deletion Fordward

awk -v ini="$inicio" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2>$3)){print}' ${id}/${fname}.blast |sort|uniq > ${id}/${fname}RV-center ##Lista into deletion Reverse

## Join the files center y search the reads matches
cat ${id}/${fname}**center |awk '(($2>27000 && $3<29000)){print}'| cut -f1 | sort | uniq -c | grep '2 ' | sed 's/      2 //g' > ${id}/${fname}.search
## Searching the positions of the delation

## Search the highest position 
prep=$(cat ${id}/${fname}.search | while read line; do grep $line ${id}/${fname}.blast ; done |awk '(($2>27000 && $3<29000)){print}' | cut -f2,3 | sort |uniq -c | sort -n | tail -n2)

## Search the highest position of the read FWD
pfa=$(cat ${id}/${fname}.search | while read line; do grep $line ${id}/${fname}.blast ; done |awk '(($2>27000 && $3<29000)){print}' |cut -f2 | sort |uniq -c | sort -n | tail -n2)

## Search the highest position of the read RV
pra=$(cat ${id}/${fname}.search | while read line; do grep $line ${id}/${fname}.blast ; done |awk '(($2>27000 && $3<29000)){print}' | cut -f3 | sort |uniq -c | sort -n | tail -n2)
echo ${id}$'\t'${fname}$'\t'${prep}$'\t'${pfa}$'\t'${pra} >> ${id}/SncPositions

sed 's/ /\t/g' ${id}/SncPositions  | cut -f2,6,5 >> ${id}/FinalPos
#rm results/*.sam 
#rm results/*.fasta 
rm ${id}/SncPositions
#exit
##--------
