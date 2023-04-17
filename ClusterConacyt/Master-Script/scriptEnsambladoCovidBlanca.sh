localPath="/app/LANGEBIO/noviembre" 
numThreads=1

mkdir ${localPath}/trimmed 
mkdir ${localPath}/calidades 
mkdir ${localPath}/dedup     
mkdir ${localPath}/alineamientos      
mkdir ${localPath}/variantes        
mkdir ${localPath}/ensamblajes  
mkdir ${localPath}/depths                                                                              

cat ${localPath}'/listaReads/listaMuestras.txt' | while read run
do
	for lane in 1 2 3 4
	do
                p=${run}_L00${lane}_R1_001.fastq.gz
                q=${run}_L00${lane}_R2_001.fastq.gz
#		echo $run
#		echo $p
#		echo $q

#  QC secuenciamiento           
                                                                                           
		echo QC                                           
#                echo /app/fastp.0.23/fastp -w ${numThreads} -i ${localPath}/reads/$p -I ${localPath}/reads/$q \
#		-o ${localPath}/trimmed/${run}L${lane}1.fq.gz -O ${localPath}/trimmed/${run}L${lane}2.fq.gz \
#		-h ${localPath}/calidades/${run}L${lane}.html -j ${localPath}/calidades/${run}L${lane}.json   
             
	       /app/fastp.0.23/fastp -w ${numThreads} -i ${localPath}/reads/$p -I ${localPath}/reads/$q \
		-o ${localPath}/trimmed/${run}L${lane}1.fq.gz -O ${localPath}/trimmed/${run}L${lane}2.fq.gz \
		 -h ${localPath}/calidades/${run}L${lane}.html -j ${localPath}/calidades/${run}L${lane}.json   

	# 2 Deduplicacion reads			
	echo dedup
		gzip -d ${localPath}/trimmed/${run}L${lane}1.fq.gz ${localPath}/trimmed/${run}L${lane}2.fq.gz        		# revisar done                                                                                                      
#		echo cd-hit-dup -i ${localPath}/trimmed/${run}L${lane}1.fq \
#		 -i2 ${localPath}/trimmed/${run}L${lane}2.fq \
#		-o ${localPath}/dedup/${run}L${lane}1.fq \
#		-o2 ${localPath}/dedup/${run}L${lane}2.fq -e 0 -m false                                      
		
		cd-hit-dup -i ${localPath}/trimmed/${run}L${lane}1.fq \
		 -i2 ${localPath}/trimmed/${run}L${lane}2.fq \
		-o ${localPath}/dedup/${run}L${lane}1.fq \
		-o2 ${localPath}/dedup/${run}L${lane}2.fq -e 0 -m false                                      
		
		gzip -q ${localPath}/dedup/${run}L${lane}1.fq ${localPath}/dedup/${run}L${lane}2.fq     	

#		# 3 Alineamiento y ordenado bam 
		echo alineamiento
                                                                                                  
# 		echo bowtie2 --very-sensitive-local -L 15 --soft-clipped-unmapped-tlen \
#		--score-min G,30,8 -t --sam-no-qname-trunc -X 500 \
#		-x /app/LANGEBIO/reference/covid19-reference\
#		-1 ${localPath}/dedup/${run}L${lane}1.fq.gz -2 ${localPath}/dedup/${run}L${lane}2.fq.gz \
#		-S ${localPath}/alineamientos/${run}L${lane}.sam --threads ${numThreads} 
 #
		bowtie2 --very-sensitive-local -L 15 --soft-clipped-unmapped-tlen \
		--score-min G,30,8 -t --sam-no-qname-trunc -X 500 \
		-x /app/LANGEBIO/reference/covid19-reference\
		-1 ${localPath}/dedup/${run}L${lane}1.fq.gz -2 ${localPath}/dedup/${run}L${lane}2.fq.gz \
		-S ${localPath}/alineamientos/${run}L${lane}.sam --threads ${numThreads} 

#		echo samtools view -S -b ${localPath}/alineamientos/${run}L${lane}.sam ">" ${localPath}/alineamientos/${run}L${lane}.bam
		samtools view -S -b ${localPath}/alineamientos/${run}L${lane}.sam > ${localPath}/alineamientos/${run}L${lane}.bam
#		echo rm ${localPath}/alineamientos/${run}L${lane}.sam      
		rm ${localPath}/alineamientos/${run}L${lane}.sam      
		done 
                                                                                                                                                                                                                                   
#	echo merge  
#      	echo samtools merge ${localPath}/alineamientos/${run}Merged.bam ${localPath}/alineamientos/${run}L*.bam
#        echo samtools sort -o ${localPath}/alineamientos/${run}.bam ${localPath}/alineamientos/${run}Merged.bam 
#	echo samtools index ${localPath}/alineamientos/${run}.bam      		
      	
	samtools merge ${localPath}/alineamientos/${run}Merged.bam ${localPath}/alineamientos/${run}L*.bam
       samtools sort -o ${localPath}/alineamientos/${run}.bam ${localPath}/alineamientos/${run}Merged.bam 
	samtools index ${localPath}/alineamientos/${run}.bam      		

	 # 4 Llamado variantes                                                                  
	echo llamado variantes                                                                 
#	echo samtools mpileup -A -B -d 1000000 -Q 20 -f /app/LANGEBIO/Master-Script/reference-covid19.fasta \
#	${localPath}/alineamientos/${run}.bam "|" /app/ivar-1.2/src/ivar variants  -p ${localPath}/variantes/${run} \
#	-q 20 -t 0.03

	samtools mpileup -A -B -d 1000000 -Q 20 -f /app/LANGEBIO/Master-Script/reference-covid19.fasta \
	${localPath}/alineamientos/${run}.bam | /app/ivar-1.2/src/ivar variants  -p ${localPath}/variantes/${run} -q 20 -t 0.03

#	echo samtools mpileup -aa -B -A -d 1000000 \
#	-Q 20 ${localPath}/alineamientos/${run}.bam "|" /app/ivar-1.2/src/ivar consensus -q 20 -t 0 -m 3 -n N -p ${localPath}/ensamblajes/${run}                                                                                                         
	samtools mpileup -aa -B -A -d 1000000 \
	-Q 20 ${localPath}/alineamientos/${run}.bam | /app/ivar-1.2/src/ivar consensus -q 20 -t 0 -m 3 -n N -p ${localPath}/ensamblajes/${run}                                                                                                         
 # 5 Calcular profundidad                                                               
	samtools depth -aa ${localPath}/alineamientos/${run}.bam  >  ${localPath}/depths/${run}.tsv   
#	python3 /app/LANGEBIO/processDepthSamtools.py ${localPath}/depths/${run}.tsv ${localPath}/depthReport.tsv

done

