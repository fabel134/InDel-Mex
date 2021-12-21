newMonth=$1;

dir="/LUSTRE/usuario/aherrera/covid/${newMonth}"
cd ${dir}
perl ControlCalidad.pl > controlCalidad/calidadesmanuales.txt

cat controlCalidad/MexCoV2.csv|cut -d'"' -f6 |sort -n | uniq -c |sort -nr > controlCalidad/linajes.txt
