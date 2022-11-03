#<input 1> base fasta file
#<input2> result fasta filename

size_del=400 #Deletion size

inicio_del=21000 #Inicio de la delecion
fin_del=$(($inicio_del+$size_del)) #Fin de la delecion

for i in {1..50}
do
rand=$((RANDOM % 150)) #read size=150
diff=$((150-$rand))
read_inicio=$(($inicio_del - $rand))
read_fin=$(($fin_del + $diff))

first_half=$(cut -c ${read_inicio}-${inicio_del} $1)
second_half=$(cut -c ${fin_del}-${read_fin} $1)

len=150

echo ">read"$i" pos="$read_inicio" len="$len>> $2".fasta"
echo $first_half$second_half >> $2".fasta"
done

####
#1. generar reads
#2. guardar como fasta
#3. cada linea empieza con > y el read
#4. pasar a sam 
#5. pasar a bam
#6. probar el script de deleciones 
### delecion más grande que 400
#guardar en otra rama