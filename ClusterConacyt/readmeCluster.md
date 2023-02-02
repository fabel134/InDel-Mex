## Copiar archivos (10 sec)
`bash 01file-move.sh septiembre2022`       

## Ensamblar   (4-5 horas)
cd septiembre22/scripts     
nohup bash 1-EnsamCoV.sh >salida1 &  
nohup bash 2-EnsamCoV.sh >salida2 &  
nohup bash 3-EnsamCoV.sh >salida3 &  
nohup bash 4-EnsamCoV.sh >salida4 &  
nohup bash 5-EnsamCoV.sh >salida5 &  
nohup bash 6-EnsamCoV.sh >salida6 &  
nohup bash 7-EnsamCoV.sh >salida7 &  
nohup bash 8-EnsamCoV.sh >salida8 &  
nohup bash 9-EnsamCoV.sh >salida9 &  
nohup bash 10-EnsamCoV.sh >salida10 &  
nohup bash 11-EnsamCoV.sh >salida11 &  


## Limpiar los ensambles  y obtener la calidad  (5 minutos)  
bash 02ensambles.sh mesactual     
python3 calculateRunDepth.py mesactual/depths mesactual  
Ejemplo  
bash 02ensambles.sh septiembre2022     
python3 calculateRunDepth.py 22junio/depths 22junio  

## Preparar los metadatos  
mv mesactual/depths/mesactualdepthReport.tsv mesactual/metadata/depthReport.tsv  
Ejemplo  
`mv septiembre2022/depths/septiembre2022depthReport.tsv septiembre2022/metadata/depthReport.tsv`                                                   subir raw data en tsv                                                                                                                                         
## Crear el archivo de metadatos  
`bash 03metadata.sh mesactual  mesanterior`  
Ejemplo
bash 03metadata.sh septiembre2022 Agosto2022  


`cp 2021/30jun/scripts/calidad*.sh ${mesactual}/scripts/ `    
   `conda activate sambcfenv `   
   `cd ${mesactual}/scripts/`  
    nohup bash calidad1.sh >salidacalodades1&                                                                         
    nohup bash calidad2.sh >salidacalodades2&                                                                         
    nohup bash calidad3.sh >salidacalodades3&                                                                          
    nohup bash calidad4.sh >salidacalodades4&                                                                       
    nohup bash calidad5.sh >salidacalodades5&                                                                       
    nohup bash calidad6.sh >salidacalodades6&                                                                  
    nohup bash calidad7.sh >salidacalodades7&                                                             
    nohup bash calidad8.sh >salidacalodades8&                                              
    nohup bash calidad9.sh >salidacalodades9&        
    nohup bash calidad10.sh >salidacalodades10&     
    nohup bash calidad11.sh >salidacalodades11&   
## Realizar control de calidad      
4.1 De 💻 subir .fasta(con todas las secuencias) a [MexCov](http://132.248.32.96:8080/COVID-TRACKER/login#tablero) langebio@ibt.unam.mx 2021langebio
➡️analisis de clados➡️ Agregar secuencia(s) ➡️fasta ➡️Procesar (esperar que acabe) RECORDAR SE USA EL tsv original para el script (subir a drive y descargar tsv)

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

   ## Revisión extra 
   1. Revisar incluso deleciones comunes  poner N cuando se ve que hay delecion al inicio del primer
   2. Cambiar por n las letras Y , etc que no son A,C,G,T
   Tomar non ACGTN de la columna de NExtClade y cambiarlos por N
   3. Revisar los stop codons

perl -pe 's/Y/N/g if !/\>/' enero.fasta.bu >enero.2    
`perl -pe 's/[YSWKR]/N/g if !/>/' enero.fasta >enero.2.fasta   `  
