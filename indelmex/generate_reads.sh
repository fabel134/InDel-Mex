#<input 1> base fasta file
#<input 2> result fasta filename
#<input 3> deletion size
#<input 4> deletion start

#Naming the main variables
input_file=$1 #Input fasta file
output_file=$2 #Base name for the output file
size_del=$3 #Deletion size
output_filename=$(echo ${output_file}del${size_del}) #Fullname for the output file


#Deletion start
if [ -z "$4" ]; then
  start_del=21000
else
  start_del=$4 # gene start
fi


#Deletion end
end_del=$(($start_del + $size_del)) #Deletion end

#Next we will create 100 fake reads
for i in {1..100}
do

#We choose a random number to start the read
rand=$((RANDOM % 150)) #read size=150

#We calculate the difference for the end of the read
diff=$((150-$rand))

#We calculate the current positions for the start and end of the read
start_read=$(($start_del - $rand))
end_read=$(($end_del + $diff))

#We take the sequence before and after the deletion
before_del=$(cut -c ${start_read}-${start_del} $input_file)
after_del=$(cut -c ${end_del}-${end_read} $input_file)

#We write the read into the output file
echo ">read"$i" pos="$start_read" len=150" >> ./output/simulations/$output_filename".fasta"
echo $before_del$after_del >> ./output/simulations/$output_filename".fasta"
done


#GENERATE BAM

#First, we index our reference fasta
bwa index ../reference-covid19.fasta

#Then, we align our fasta with the reference one and produce a SAM file
bwa mem ../reference-covid19.fasta ./output/simulations/$output_filename.fasta >  ./output/simulations/$output_filename.sam

#we transform the SAM file into a BAM file
samtools view -S -b ./output/simulations/${output_filename}.sam > ./output/simulations/${output_filename}.bam

#Next, we sort the bam file
samtools sort -o ./output/simulations/${output_filename}.aligned.bam ./output/simulations/${output_filename}.bam

#Finally, we index the aligned bam
samtools index ./output/simulations/${output_filename}.aligned.bam

