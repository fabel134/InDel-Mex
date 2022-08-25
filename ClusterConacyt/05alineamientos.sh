newMonth=$1

dir="/app/LANGEBIO/${newMonth}"
basedir="/app/LANGEBIO"
cd ${dir}

perl ${dir}/alineador.pl ${newMonth}
cat ${dir}/reference-covid19.fasta  ${dir}/controlCalidad/Alinear.fasta>${dir}/controlCalidad/ConRef.fasta

cp ${basedir}/Master-Script/muscle-run.sh  ${dir}/controlCalidad/muscle.sh
sed -i "s/noviembre/${newMonth}/"  ${dir}/controlCalidad/muscle.sh 
bash ${dir}/controlCalidad/muscle.sh 
