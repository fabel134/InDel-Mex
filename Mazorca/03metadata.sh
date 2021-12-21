# bash 03metadata.sh mesfalso mesanterior
newMonth=$1
lastMonth=$2

base_dir="/LUSTRE/usuario/aherrera/covid" 
work_dir="/LUSTRE/usuario/aherrera/covid/${newMonth}" 
NewStart=$(cut -f3 ${base_dir}/${lastMonth}/metadata/EpiCoV_LANGEBIO_031121_10_LANGEBIO_031121.tsv-90.tsv|cut -d'_' -f4|cut -d'/' -f1 |grep -v NC|sort -n|tail -n1 )
# En noviembre estaba en metadataNewName en lugar de metadata y el número fue 3585

NewFastaName="Vigilancia_${newMonth}"
echo LastRecord $NewStart NewFastaName $NewFastaName
cd ${work_dir}
#cp ${base_dir}/Master-Script/metadataWorking.pl ${work_dir}/metadata.pl 
sed -i "s/start=3115/start=${NewStart}/" metadata.pl;  
sed -i "s/FastaName=\"Vigilancia_24Nov2021\"/FastaName=\"${NewFastaName}\"/" metadata.pl;  

# Mv Report to metadata  
mv depthReport.tsv metadata/.
# Get EpicovFile
Epi=$(ls metadata/*Ep*|grep -v '-')
# Remove accents
sed -i 'y/āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜĀÁǍÀĒÉĚÈĪÍǏÌŌÓǑÒŪÚǓÙǕǗǙǛ/aaaaeeeeiiiioooouuuuüüüüAAAAEEEEIIIIOOOOUUUUÜÜÜÜ/' $Epi

# Get PlaneacionFile 
Plan=$(ls metadata/*Plan*)
# change | for _ in fasta and meatadata for NC number
# done 
# Change date format
#done
# remove S from meatdata.pl
#done

# add column to metadata out
#done

# save as tsv  

`perl metadata.pl ${Epi} ${Plan} metadata/depthReport.tsv 1`
cat fastas/*/* > metadata/${newMonth}.fasta  

## Agregar uno de 90 y uno que no salio al clean y al depth
mkdir controlCalidad 
