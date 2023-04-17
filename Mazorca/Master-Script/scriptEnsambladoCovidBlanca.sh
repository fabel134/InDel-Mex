#PBS -N NUMnoviembre
#PBS -q default
#PBS -l nodes=1:ppn=8,walltime=90:00:00,mem=8g,vmem=8g
#PBS -e /LUSTRE/usuario/aherrera/covid/noviembre/error.txt
#PBS -o /LUSTRE/usuario/aherrera/covid/noviembre/out.txt
#PBS -V

module load fastp/0.20
module load cd-hit/4.8.1
module load bowtie2/2.3.5.1
module load samtools/1.9
module load ivar/1.2

localPath="/LUSTRE/usuario/aherrera/covid/noviembre" 
numThreads=1

mkdir ${localPath}/trimmed
mkdir ${localPath}/calidades
mkdir ${localPath}/dedup
mkdir ${localPath}/alineamientos
mkdir ${localPath}/variantes
mkdir ${localPath}/ensamblajes
mkdir ${localPath}/depths
while read run
do
	for lane in 1 2 3 4
	do
#		p=${run}1_001.fastq.gz
#		q=${run}2_001.fastq.gz
                p=${run}_L00${lane}_R1_001.fastq.gz
                q=${run}_L00${lane}_R2_001.fastq.gz
		echo $run
		echo $p
		echo $q

	# 1 QC secuenciamiento
		echo QC
		fastp -w ${numThreads} -i ${localPath}/reads/$p -I ${localPath}/reads/$q -o ${localPath}/trimmed/${run}L${lane}1.fq.gz -O ${localPath}/trimmed/${run}L${lane}2.fq.gz -h ${localPath}/calidades/${run}L${lane}.html -j ${localPath}/calidades/${run}L${lane}.json
		
	# 2 Deduplicacion reads
		echo dedup
		gzip -d ${localPath}/trimmed/${run}L${lane}1.fq.gz ${localPath}/trimmed/${run}L${lane}2.fq.gz
                # revisar done
		cd-hit-dup -i ${localPath}/trimmed/${run}L${lane}1.fq -i2 ${localPath}/trimmed/${run}L${lane}2.fq -o ${localPath}/dedup/${run}L${lane}1.fq -o2 ${localPath}/dedup/${run}L${lane}2.fq -e 0 -m false
		gzip -q ${localPath}/dedup/${run}L${lane}1.fq ${localPath}/dedup/${run}L${lane}2.fq

	# 3 Alineamiento y ordenado bam
		echo alineamiento
		bowtie2 --very-sensitive-local -L 15 --soft-clipped-unmapped-tlen --score-min G,30,8 -t --sam-no-qname-trunc -X 500 -x /LUSTRE/usuario/aherrera/referencia/covid19.fasta -1 ${localPath}/dedup/${run}L${lane}1.fq.gz -2 ${localPath}/dedup/${run}L${lane}2.fq.gz -S ${localPath}/alineamientos/${run}L${lane}.sam --threads ${numThreads}
		
		samtools view -S -b ${localPath}/alineamientos/${run}L${lane}.sam > ${localPath}/alineamientos/${run}L${lane}.bam
		rm ${localPath}/alineamientos/${run}L${lane}.sam
	done

	echo merge
	samtools merge ${localPath}/alineamientos/${run}Merged.bam ${localPath}/alineamientos/${run}L*.bam 

	samtools sort -o ${localPath}/alineamientos/${run}.bam ${localPath}/alineamientos/${run}Merged.bam
	samtools index ${localPath}/alineamientos/${run}.bam
	
	# 4 Llamado variantes
	echo llamado variantes
	samtools mpileup -A -B -d 1000000 -Q 20 -f /LUSTRE/usuario/aherrera/referencia/covid19.fasta ${localPath}/alineamientos/${run}.bam | ivar variants  -p ${localPath}/variantes/${run} -q 20 -t 0.03
	samtools mpileup -aa -B -A -d 1000000 -Q 20 ${localPath}/alineamientos/${run}.bam | ivar consensus  -q 20 -t 0 -m 3 -n N -p ${localPath}/ensamblajes/${run}

	# 5 Calcular profundidad
	samtools depth -aa ${localPath}/alineamientos/${run}.bam  >  ${localPath}/depths/${run}.tsv
        python3 /LUSTRE/usuario/aherrera/covid/processDepthSamtools.py ${localPath}/depths/${run}.tsv ${localPath}/depthReport.tsv
done < ${localPath}'/listaReads/listaMuestras.txt'

