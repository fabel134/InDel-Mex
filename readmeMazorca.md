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

Desde secuenciacion los reads se depositan en una carpeta ej. `<mesfalso>` , el mes debe correr sin la diagonal.     
Los scripts están programados para reads que vienen de 4Lanes y deben ser mínimo 10 muestras  
Los templados de los scripts están guardados en `Master-Script`      

## 1. Producir alineamientos y primer ensamble   
:corn: `bash 01file-move.sh <mesfalso>`     
_input:_ <mesfalso>
_output:_ alineamientos, calidades, dedup, depth, ensamblajes, trimmed y variantes     

   Es importante que los reads tengan esta extension **5340_S116_L004_R1_001.fastq.gz**
   Si no están en este formato se pueden renombrar en la carpeta reads de links simbólicos.  
   
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
Nota 👀 Remover líneas en blanco y controles negativos de estos archivos tsv. (Se pueden abrir en vi, ver lineas con :set nu, y remover lineas con Esc dd, Ej. Esc 5dd borrará 5 líneas a partir de donde está el cursor).   
  
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
  
 4.4 🌽 Correr script para revisar Nuevas mutaciones, Deleciones e inserciones, sobre todo frameshifts    
  🌽 `bash 04controlCalidad.sh <mesfalso> `   
   _input:_ <mesfalso> MexCoV2.csv   
   _output:_ controlCalidad/calidadesmanuales.txt  controlCalidad/linajes.txt    
  debe ligar el ID con el num de reads  
   👀 Observar calidades manuales.txt 
   Contiene 6 columnas numéricas, Reads totales, reads reverse, calidad (original cols 1:3 variantes cols 4:6)  
   Anotar en el drive MexCoV2.csv para cada muestra con nueva deleción, mutación o inserción de nucleótidos una columna con alguno de los siguientes status:
     
      _Cambiar a N_        
      - Cuando no hay mas de 20 reads ni en el original ni en la variante    
   
      _Cambiar a original_   
      - Cuando hay mas reads en el original que en la variante, calidad >20 Existen reads reverse  
      - Cuando la variante tiene pocos reads reverse (respecto a forward) y la original >20 reads  

      _Mantener mutacion_  
      - Cuando reads de variante > reads de original, y variante tiene reads reverse, >20 reads   
 
 4.5 Subir <mesfalso>.fasta a [NextClade](https://clades.nextstrain.org)  
    👀 Observar salida de NextClade y anotar en el drive de MexCoV2.csv si es que hay alguna otra muestra que se deba verificar manualmente,   
   Para verificar manualmente se pueden ver los archivos csv en la carpeta variantes o bien descargar los bam y observa en tablet.    
   Para tables se necesita el archivo de referencia, el .bai y el .bam.   
   
  4.6 Lista de muestras para editar.  
   Hacer una lista con las muestras que en el drive MexCoV2.csv tengan status  "Cambiar a N" o "Cambiar a original" 
   Ejemplo:  
   `vi mesfalso/controlCalidad/paraAlinear.txt`    
   hCoV-19/Mexico/BCN_LANGEBIO_IMSS_13661_NC/2021_5186  
   hCoV-19/Mexico/CHH_LANGEBIO_IMSS_3597/2021_5008   
   `Esc:wq`  
  
## 5 Alineamientos y edición manual ( 🌽 y ✋ )     
  `bash 05alineamientos.sh <mesfalso> `     
   __input:__ controlCalidad/paraAlinear.txt  
   __output:__ controlCalidad/Alinear.fasta   # Este es un fasta con la referencia y las secuencias a editar alineadas     
               controlCalidad/NOAlinear.fasta # fasta de secuencias que no hay que corregir  
               controlCalidad/mesfalsoAlineadosParaEditar.fasta #Fasta alineado

  5.2 Corregir en JalView
   5.2.1 Descargar de mazorca mesfalsoAlineadosParaEditar.fasta     
  💻 ` scp -r aherrera@148.247.230.5:/LUSTRE/usuarios/aherrera/covid/<mesfalso>/controlCalidad/ Descargas/.`  
  5.2.2 💻 Abrir en Jalview <mesfalso>AlineadosParaEditar.fasta y editar.   
   Guardar el resultado en editados1.fasta
   __output:__ editados1.fasta  
  💻 `vi editados1.fasta /`  
   💻 Para eliminar el id agregado de JalView ejecutar en vi `%s/_\d*\/\d-\d*\n/\r/`  
   
  5.3 Subir a NextClade y verificar que ya no hay mediocres.  
  Si hay mediocres usar los reads y volver a Corregir en Jalview   
  Finalmente guardar en Jalview los editados SIN la referencia.  
 
  5.4 Concatenar con los Noalinear
  💻 `cat Noalinear editados1.fasta > Vigilancia_<mesfalso>.fasta `   
   
 
 ## Subir a Drive y a GISAID  
  Con el metadata final de la plantilla original de GISAID abrir en excel y ajustar formato de fecha y de Id del IMSS    
  Subirlo a drive 👀, descargar como csv y finalmente subir a GISAID
 
 ## Datos en el Microreact (☁️)
   Crear un nuevo libro de excel llamado "Linajes-mes" en drive
   Abrir el libro de excel "MexCoV"
   Copiar las columnas "Linaje Pangolin", "Clado Nextstrain", "Nombre de la secuencia" en el "Linajes-mes"
   Abrir el libro de excel 
   
   
   
  
                                                           
