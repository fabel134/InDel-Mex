# Guia para el ConViMex en Langebio    
Para trabajar en mazorca desde  `/LUSTRE/usuario/aherrera/covid `    
`cd /LUSTRE/usuario/aherrera/covid `    

Los templados de los scripts están guardados en `Master-Script`      
Una vez que desde secuenciacion los reads se depositan en una carpeta `<mesfalso>`     
Los reads vienen en 4Lanes, deben ser minimo 10 muestras  

`bash 01file-move.sh <mesfalso>`     
Produce alineamientos, calidades, dedup, depth, ensamblajes, trimmed y variantes     

Con `qstat` se verifica si hay trabajos pendientes. Si alguno se traba, digamos el <n>-EnsamCoV.sh repetir con:   
`qsub /LUSTRE/usuario/aherrera/covid/<mesfalso>/<n>-EnsamCoV.sh ` 
  
`bash 02metadata.sh <mesfalso>`
 Crea el metadata y los archivos clean consensus
 
  ## Paso Manual
  Subir desde el drive al metadata las planeaciones  
  
