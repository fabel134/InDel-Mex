# Tutorial básico para correr los scripts en bash

## Cloning the repository
`cd ~
`git clone https://github.com/fabel134/InDel-Mex.git`   
`cd ~/InDel-Mex`  
2.  Estando en la carpeta del repositorio __InDel-Mex__, escribimos: ` cd scritps_indelmex/`
3. Posteriormente escribimos `bash 2103_Search_pos.sh ruta_del_archivo_bam mes` donde _ruta_del_archivo_bam_ es la ruta de la secuencia que queremos analizar y _mes_ es el mes que queremos revisar, aunque por el momento el mes no es relevante.
4. Lo siguiente es revisar las posiciones resultantes, esto lo hacemos con `more ./results/FinalPos` donde se nos mostrarán 3 columnas que continenen el nombre del archivo bam, la posición inicial de la posible deleción y la posición final de la posible deleción.
5. Ya con esto, escirbimos `bash 2109_deleciones.sh ruta_del_archivo_bam mes pi pf` donde _ruta_del_archivo_bam_ es la ruta de la secuencia que queremos analizar, _mes_ es el mes que queremos revisar, _pi_ es la posición inicial de la posible deleción (encontrada en el paso anterior) y _pf_ es la posición final de la posible deleción (también encontrada en el paso anterior)
6. Finalmente vemos los resultados con `more ./results/reportFinal`
