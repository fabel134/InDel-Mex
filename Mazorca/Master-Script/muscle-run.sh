#PBS -N Muscle-sars
#PBS -q default
#PBS -l nodes=1:ppn=8,walltime=20:00:00,mem=8g,vmem=8g
#PBS -e /LUSTRE/usuario/aherrera/covid/noviembre/controlCalidad/errM2-3.txt
#PBS -o /LUSTRE/usuario/aherrera/covid/noviembre/controlCalidad/outM2-3.txt
#PBS -V

module load muscle/3.8.31
cd /LUSTRE/usuario/aherrera/covid/noviembre/controlCalidad
muscle -in ConRef.fasta   -out noviembreAlineadosParaEditar.fasta
