#PBS -N Search-Deletions1
#PBS -q default
#PBS -l nodes=1:ppn=8,walltime=90:00:00,mem=8g,vmem=8g
#PBS -e /LUSTRE/usuario/aherrera/covid/2021/posiciones/search-pos/errlista1.txt
#PBS -o /LUSTRE/usuario/aherrera/covid/2021/posiciones/search-pos/outlista1.txt
#PBS -V

module load samtools/1.9
module load ncbi-blast+/2.9.0

cd /LUSTRE/usuario/aherrera/covid/2021/posiciones/search-pos 

cat corrida1 | while read line
do
corrida=$line

## Aqui pasale la lista de archivos bam que quieres correr
ls /LUSTRE/usuario/aherrera/covid/2021/${corrida}/alineamientos/*[0-9][0-9].bam  | while read line; do bash 2109_deleciones.sh  $line ${corrida} ; done ##linea nelly

ls /LUSTRE/usuario/aherrera/covid/2021/${corrida}/alineamientos/*S[0-9].bam  | while read line; do bash 2109_deleciones.sh  $line ${corrida} ; done ##linea nelly

done
#ls *bam | while read line; do bash 2109_deleciones.sh  $line ; done ##linea Abel

#bash 2109_deleciones.sh ../2167_S231.bam abril
#bash 2109_deleciones.sh ../2320_S384.bam abril
#bash AbelDeleciones.sh 590_S190Merged.bam
#bash 2109_deleciones.sh prueba-script.bam
#Muestra con delecion
#bash 2109_deleciones.sh 590_S190Merged.bam
#Muestra sin delecion 
#bash 2109_deleciones.sh 653_S253Merged.bam
#Muestra reads inventados
#bash 2109_deleciones.sh prueba-script.bam
