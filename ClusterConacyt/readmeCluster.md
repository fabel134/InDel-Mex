01  
  nohup bash ensam01>salida1&  
02  
python3 calculateRunDepth.py 22junio/depths 22junio                                                              
mv 22juniodepthReport.tsv depthReport.tsv                                                                                                                                                                                  
03  
  cp 2021/30jun/scripts/calidades*.sh mes/.  
   conda activate sambcfenv   
   nohup bash calidades01>salidacalodades1&  
   
4.1 De 💻 subir .fasta(con todas las secuencias) a [MexCov](http://132.248.32.96:8080/COVID-TRACKER/login#tablero) langebio@ibt.unam.mx 2021langebio
➡️analisis de clados➡️ Agregar secuencia(s) ➡️fasta ➡️Procesar (esperar que acabe)

4.2 Descargar de MexCov ➡️tsv
4.4 🌽 Correr script para revisar Nuevas mutaciones, Deleciones e inserciones, sobre todo frameshifts
🌽 bash 04controlCalidad.sh <mesfalso>
input: MexCov2.csv
output: controlCalidad/calidadesmanuales.txt controlCalidad/linajes.txt
debe ligar el ID con el num de reads
 
  ### NExtclade
  Para las secuencias que nextclade marque como de baja calidad revisar el archivo vcf en la carpeta alinemaientos 
  Ejemplo >hCoV-19/Mexico/MEX_LANGEBIO_IMSS_93492_NC/2022_10411 
  si se ve una delecion a partir del nucleótido 419 revisar alineamientos/10411.vcf 
 ADF R Integer Read depth for each allele on the forward strand
 ADR R Integer Read depth for each allele on the reverse strand
  y decidir

  ### Calidades IBT 
👀 Observar calidades manuales.txt Contiene 6 columnas numéricas, Reads totales, reads reverse, calidad (original cols 1:3 variantes cols 4:6)
Anotar en el drive MexCoV2.csv para cada muestra con nueva deleción, mutación o inserción de nucleótidos una columna con alguno de los siguientes status:

  _Cambiar a N_        
  - Cuando no hay mas de 20 reads ni en el original ni en la variante    

  _Cambiar a original_   
  - Cuando hay mas reads en el original que en la variante, calidad >20 Existen reads reverse  
  - Cuando la variante tiene pocos reads reverse (respecto a forward) y la original >20 reads  

  _Mantener mutacion_  
  - Cuando reads de variante > reads de original, y variante tiene reads reverse, >20 reads   


