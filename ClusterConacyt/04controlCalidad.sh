newMonth=$1;

dir="/app/LANGEBIO/${newMonth}"
cd ${dir}
perl ControlCalidad.pl > controlCalidad/calidadesmanuales.txt

cat controlCalidad/MexCov2.tsv|cut -f3 |sort -n | uniq -c |sort -nr > controlCalidad/linajes.txt
