# Guia para el CoViGenMex en Langebio 
Símbolos:
- <> susitituir por  
- ✋ Paso Manual  
- 🌽 Mazorca  
- ☁️ Google Drive (La nube)   
- 🌐 internet  
- 👀 Fijarse Bien!  

## 0. Preparar Nube e ir al directorio de trabajo     
0.1 Crear en ☁️ 2022-Corrida<Num>/RawMetadata con los 4 archivos de metadata y planeación.    
0.2. :corn: `cd /LUSTRE/usuario/aherrera/covid `      

Desde secuenciacion los reads se depositan en una carpeta ej. `<mesfalso>`     
Los scripts están programados para reads que vienen de 4Lanes y deben ser mínimo 10 muestras  
Los templados de los scripts están guardados en `Master-Script`      

## 1. Producir alineamientos y primer ensamble   
:corn: `bash 01file-move.sh <mesfalso>`     
_input:_ <mesfalso>
_output:_ alineamientos, calidades, dedup, depth, ensamblajes, trimmed y variantes     

Con `qstat` se verifica si hay trabajos pendientes. Si alguno de ellos se traba, ej. el <n>-EnsamCoV.sh repetir con:   
:corn: `qsub /LUSTRE/usuario/aherrera/covid/<mesfalso>/<n>-EnsamCoV.sh `   
  
## 2 Primera limpieza de ensambles  
2.1 :corn: `bash 02ensambles.sh <mesfalso>`  
 _input:_ 
 _output:_ mesfalso/metadata  mesfalso/ensamblajes/*.clean.fa
  
2.2 :hand: "Subir raw-Metadatos"     
2.2.1 Descargar desde ☁️ a 💻 los archivos del mes correspondientes a:  
  1.EpiCoV_LANGEBIO_<fecha-mesfalso>.excel  
  2. METADATA_LANGEBIO_<fecha-mesfalso>Planeacion.excel  
  
 2.2.2 Subir archivos metadata de 💻 a 🌽 al directorio metadata de <mesfalso>   
 - 2.2.2.1 💻 Abrirlo en excel y guardarlo como __tsv__ 
 - 2.2.2.2 💻 Subir los __tsv__ a 🌽  
   `scp EpiCoV_LANGEBIO_011221.tsv aherrera@148.247.230.5:/LUSTRE/usuario/aherrera/covid/<mesfalso>/metadata/.`  
    `scp METADATA_LANGEBIO_011221-PlaneacionAH1COV2SSr030.tsv aherrera@148.247.230.5:/LUSTRE/usuario/aherrera/covid/<mesfalso>/metadata/.`
Nota 👀 El archivo de planeación debe contener en la 4 columna el número de Biblioteca (ID biblioteca UGA).  
  
## 3 Obtener fastas y metadatos del mes combinando planeacion, ensambles y metadatos originales.  
3.1 🌽 `bash 03metadata.sh <mesfalso> <mesanterior>`  
_input:_  <mesfalso> <mesanterior>
_output:_  
  1. Metadata preliminar de +90% de cobertura (<10% Ns) en el genoma
  2. Fasta preliminar de +90% cobertura. 
                                                                
3.2 ✋ Control de Calidad  
3.2.1. De 🌽 descargar a 💻 el fasta y subirlo a MexCov y a NextClade
  💻 `scp aherrera@148.247.230.5:/LUSTRE/usuario/aherrera/covid/<mesfalso>/metadata/. Descargas/.`  
3.2.2 De 💻 subir a MexCov
3.2.3 De Descargar de MexCov y subir a 🌽 y a Drive ☁️  
    
 ## 4 Mazorca 
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
  
                                                              
  
