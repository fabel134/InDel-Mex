# Guia para el ConViMex en Langebio    
Para trabajar en mazorca :corn: desde  `/LUSTRE/usuario/aherrera/covid `    
:corn: 
`cd /LUSTRE/usuario/aherrera/covid `    

Los templados de los scripts están guardados en `Master-Script`      
Una vez que desde secuenciacion los reads se depositan en una carpeta `<mesfalso>`     
Los reads vienen en 4Lanes, deben ser minimo 10 muestras  

`bash 01file-move.sh <mesfalso>`     
Produce alineamientos, calidades, dedup, depth, ensamblajes, trimmed y variantes     

Con `qstat` se verifica si hay trabajos pendientes. Si alguno se traba, digamos el <n>-EnsamCoV.sh repetir con:   
`qsub /LUSTRE/usuario/aherrera/covid/<mesfalso>/<n>-EnsamCoV.sh ` 
  
`bash 02ensambles.sh <mesfalso>`
 Crea el metadata y los archivos clean consensus
 
 :hand: "Asignar Metadatos"  
 Subir desde el drive al metadata las planeaciones y el metadata
`scp EpiCoV_LANGEBIO_011221.tsv aherrera@148.247.230.5:/LUSTRE/usuario/aherrera/covid/<mesfalso>/metadata/.`  
`scp METADATA_LANGEBIO_011221-PlaneacionAH1COV2SSr030.tsv aherrera@148.247.230.5:/LUSTRE/usuario/aherrera/covid/<mesfalso>/metadata/.`

  correr
`bash 03metadata.sh <mesfalso> <mesanterior>`
  va a producir 
  1. Metadata preliminar de +90% de cobertura (<10% Ns) en el genoma
  2. Fasta preliminar de +90% cobertura. 
                                                              
 ## Paso Manual "Control de Calidad"
1. Descargar el fasta y subirlo a MexCov y a NextClade
:computer: `scp aherrera@148.247.230.5:/LUSTRE/usuario/aherrera/covid/<mesfalso>/metadata/. Descargas/.`  
2. Descargar de MexCov y subir a :corn: y a Drive :cloud:
  
 ## Mazorca 
  Correr script para revisar Nuevas mutaciones, Deleciones e inserciones, sobre todo frameshifts   
  debe ligar el ID con el num de reads
 
  ## pasar lista con Ids por alinear
  Alinear 
  Corregir en JalView
  
  Subir a NextClade
  Volver a Corregir en Jalview
 
  Ya con toda la calidad garantizada, subir el fasta despues del JalView (genomas editados)
  Pasar a mazorca la lista de los editados, eliminados
  
  Generar MetadataFinal, FastaFinal
  Subir a drive, subir a GISAID
  
                                                              
  
