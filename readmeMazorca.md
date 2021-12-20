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
   Remover los espacios en los nombres de los archivos (cambiarlos por guiones)  
0.2. 🌽 `cd /LUSTRE/usuario/aherrera/covid `      

Desde secuenciacion los reads se depositan en una carpeta ej. `<mesfalso>`     
Los scripts están programados para reads que vienen de 4Lanes y deben ser mínimo 10 muestras  
Los templados de los scripts están guardados en `Master-Script`      

## 1. Producir alineamientos y primer ensamble   
:corn: `bash 01file-move.sh <mesfalso>`     
_input:_ <mesfalso>
_output:_ alineamientos, calidades, dedup, depth, ensamblajes, trimmed y variantes     

Con `qstat` se verifica si hay trabajos pendientes. Si alguno de ellos se traba, ej. el <n>-EnsamCoV.sh repetir con:   
:corn: `qsub /LUSTRE/usuario/aherrera/covid/<mesfalso>/<n>-EnsamCoV.sh `   
  
👀 Debería crear máximo 20 trabajos!  
  
## 2 Primera limpieza de ensambles  
2.1 :corn: `bash 02ensambles.sh <mesfalso>`  
 _input:_ 
 _output:_ mesfalso/metadata  mesfalso/ensamblajes/*.clean.fa
  
2.2 :hand: Subir de ☁️ el contenido de  corrida<mesfalso>/raw-Metadata a 🌽     
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
_output:_  EpiCoV_LANGEBIO_<fechamesfalso>.tsv-90.tsv 
  1. metadata/Epi*90.tsv      Metadata preliminar de +90% de cobertura (<10% Ns) en el genoma
  2. metadata/<mesfalso>.fasta  Fasta preliminar de +90% cobertura. 
                                                                
3.2 De 🌽 descargar a 💻 el fasta     
  💻 `scp aherrera@148.247.230.5:/LUSTRE/usuario/aherrera/covid/<mesfalso>/metadata/Epi*90.tsv Descargas/.`    
  💻 `scp aherrera@148.247.230.5:/LUSTRE/usuario/aherrera/covid/<mesfalso>/metadata/*.fasta Descargas/.`    
    
## 4 ✋ Control de calidad
### Subir fasta a analizadores de calidad on line  
4.1 De 💻 subir <mesfalso>.fasta a [MexCov](http://132.248.32.96:8080/COVID-TRACKER/login#tablero) 
   langebio@ibt.unam.mx 2021langebio  
   ➡️analisis de clados➡️ Agregar secuencia(s) ➡️fasta   ➡️Procesar (esperar que acabe)  
4.2 Descargar de [MexCov](http://132.248.32.96:8080/COVID-TRACKER/login#tablero) 
    ➡️csv   
4.3 💻 subir Descargas/MexCoV2.csv a Drive ☁️   
    💻 subir Descargas/MexCoV2.csv 🌽
    💻 `scp Descargas/MexCoV2.csv aherrera@148.247.230.5:/LUSTRE/usuario/aherrera/covid/<mesfalso>/controlCalidad/.`  
4.4 
  🌽Correr script para revisar Nuevas mutaciones, Deleciones e inserciones, sobre todo frameshifts   
  debe ligar el ID con el num de reads
   👀 Observar salida y anotar en el drive   
   _Cambiar a N_        Cuando no hay mas de 20 reads ni en el original ni en la variante    
   _Cambiar a original_   Cuando hay mas reads en el original que en la variante, calidad >20 Existen reads reverse  
                        Cuando la variante tiene pocos reads reverse (respecto a forward) y la original >20 reads  

   _Mantener mutacion_  Cuando reads de variante > reads de original, y variante tiene reads reverse, >20 reads   
 
 4.5 Subir <mesfalso>.fasta a [NextClade](https://clades.nextstrain.org)  
 Obtener lista _Cambiar a N_ y _Cambiar original_    
## 5 Alineamientos   
   __input:__ 
   pasar lista con Ids por alinear
  Alinear 
  Corregir en JalView
  
  Subir a NextClade
  Volver a Corregir en Jalview
   
 ## 6 Fasta y Metadata Finales   
  Ya con toda la calidad garantizada, subir el fasta despues del JalView (genomas editados)
  Pasar a mazorca la lista de los editados, eliminados
  
  Generar MetadataFinal, FastaFinal Descargar  
   
 ## Subir a Drive y a GISAID  
  Con el metadata final abrir en excel y ajustar formato de fecha y de Id del IMSS   
  Subir a drive, subir a GISAID
  
                                                           
