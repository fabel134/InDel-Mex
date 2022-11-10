# bash 2103_Search_pos.sh <input> <input2>
# bash 2103_Search_po.sh 2824_S96.bam julio2
# <input 1> is a bam file 
# <input 2> is the id for the run
# <input 3> is the start position to search
# <input 4> is the finish  position to search

### start & end are optionals
##Variables for AWK 

#Start pos
if [ -z "$3" ]; then
  start=27399
else
  start=$3 # gene start
fi
ds=150       # positions before the delation from where we take the reads
pre_start=$(( ${start} - ${ds} ))

#Finish pos
if [ -z "$4" ]; then
  end=28259
else
  end=$4 # gene start
fi
de=150        # positions after the delation from where we take the reads
pos_end=$(( ${end} + ${de} ))


#echo inicio $start delta inicio $ds el scaneo empieza en $pre_start
#echo final $end delta final $de el scaneo empieza en $pos_end

  ##Variables for BLAST Y FASTA
fullfile=$1
fname=$(basename $fullfile .bam)
id=$2

#Create a folder for the results with the chosen id if needed
[ -d ./output/${id} ] || mkdir ./output/${id}
#[ -d ${id} ] || mkdir ${id}

## We cut the original bam to a sam file that only contains reads in the interest region
samtools view -h -o  ./output/${id}/${fname}.sam $fullfile
grep '@' ./output/${id}/${fname}.sam > ./output/${id}/${fname}.short.sam 

##Consortium reads
awk -v pini=$pre_start -v pfini=$pos_end '( $4>=pini && $4<pfini){print}' ./output/${id}/${fname}.sam >> ./output/${id}/${fname}.short.sam 
#echo awk -v pini=$pre_start -v pfini=$pos_end '( $4>=pini && $4<pfini){print}' ./output/${id}/${fname}.sam \>\> ./output/${id}/${fname}.short.sam


### We transform the sam to fasta
samtools fasta ./output/${id}/${fname}.short.sam | sed 's/ /_/' > ./output/${id}/${fname}.short.fasta 

## Aligning, we aline the reads of interest in the fasta with the original genome
blastn -query ./output/${id}/${fname}.short.fasta -subject ../reference-covid19.fasta -outfmt 6 | cut -f1,9,10 > ./output/${id}/${fname}.blast 

##-------- Search reads matches in genes -------

## Producing reads list that align into deletion

awk -v ini="$start" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2<$3)){print}' ./output/${id}/${fname}.blast |sort|uniq > ./output/${id}/${fname}FWD-center ##Lista into deletion Fordward

awk -v ini="$inicio" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2>$3)){print}' ./output/${id}/${fname}.blast |sort|uniq > ./output/${id}/${fname}RV-center ##Lista into deletion Reverse

## Join the files center y search the reads matches
# Reads that aligned twice
cat ./output/${id}/${fname}**center |awk  -v ini="$inicio" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2>pin && $3<pfini)){print}'| cut -f1 | sort | uniq -c | grep '2 ' | sed 's/      2 //g' > ./output/${id}/${fname}.search



## Searching the positions of the delation

## Search the highest position 
prep=$(cat ./output/${id}/${fname}.search | while read line; do grep $line ./output/${id}/${fname}.blast ; done |awk -v ini="$inicio" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2>pini && $3<pfini)){print}' | cut -f2,3 | sort |uniq -c | sort -n | tail -n2)

## Search the highest position of the read FWD
pfa=$(cat ./output/${id}/${fname}.search | while read line; do grep $line ./output/${id}/${fname}.blast ; done |awk -v ini="$inicio" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2>pini && $3<pfini)){print}' |cut -f2 | sort |uniq -c | sort -n | tail -n2)

## Search the highest position of the read RV
pra=$(cat ./output/${id}/${fname}.search | while read line; do grep $line ./output/${id}/${fname}.blast ; done |awk -v ini="$inicio" -v pin="$pre_start" -v fini="$end" -v pfini="$pos_end" '(($2>pini && $3<pfini)){print}' | cut -f3 | sort |uniq -c | sort -n | tail -n2)
echo ${id}$'\t'${fname}$'\t'${prep}$'\t'${pfa}$'\t'${pra} >> ./output/${id}/SncPositions

sed 's/ /\t/g' ./output/${id}/SncPositions  | cut -f2,6,5 >> ./output/${id}/FinalPos
#rm results/*.sam 
#rm results/*.fasta 
rm ./output/${id}/SncPositions
#exit
##--------
