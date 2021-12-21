### Este programa realiza limpieza del genoma consenso
## Debe correrse después de los alineamientos (01file-move.sh)
## NEcesita los fastas de ensambles produce los clean.fa
## Para correrlo:
## bash 02ensambles.sh <mesfalso>
##
## Autores nselem84@gmail.com Nelly Selem
##         Jose Abel Lovaco

new_month=$1
work_dir="/LUSTRE/usuario/aherrera/covid/${new_month}"
mkdir ${work_dir}/err-out
mv ${work_dir}/err* ${work_dir}/out* ${work_dir}/err-out

cd ${work_dir}/ensamblajes
# quitar las S del nombre
# removing S_ from ensambles names 
ls *fa |cut -d'_' -f1 |sort|uniq |while read line; do mv $line*fa $line.fa; done       
ls *qual.txt |cut -d'_' -f1 |sort|uniq |while read line; do  mv ${line}*.qual.txt  ${line}.qual.txt ; done       

cd ${work_dir}/variantes
ls *tsv |cut -d'_' -f1 |sort|uniq |while read line; do mv $line*tsv $line.tsv; done       
# obtener min y max de reads
min=$(ls ${work_dir}/reads/|cut -d'_' -f1|sort -n|uniq|head -n1) 
max=$(ls ${work_dir}/reads/|cut -d'_' -f1|sort -n|uniq|tail -n1)
echo min $min max $max 

cd ${work_dir}
# HAcer un for para correr el clean consensus
for num in $(seq $min $max) ;do perl cleanConsensus_v4.pl ensamblajes/${num}.fa variantes/${num}.tsv ensamblajes/${num}-clean.fa reference-covid19.fasta; done

mkdir ${work_dir}/metadata
