# bash 03metadata.sh mesfalso mesanterior
newMonth=$1
lastMonth=$2

base_dir="/app/LANGEBIO" 
work_dir="/app/LANGEBIO/${newMonth}" 
echo cut -f3 ${base_dir}/${lastMonth}/metadata/EpiCoV*.tsv-90.tsv "|" cut -d'_' -f4,5 "|" cut -d'/' -f1 "|" grep -v NC "|" sort -n "|" tail -n1 

NewStart=$(cut -f3 ${base_dir}/${lastMonth}/metadata/EpiCoV*.tsv-90.tsv|cut -d'_' -f4,5|cut -d'/' -f1 |grep -v NC|sort -n|tail -n1 )
# En noviembre estaba en metadataNewName en lugar de metadata y el número fue 3585
echo $NewStart
NewFastaName="Vigilancia_${newMonth}"
#echo LastRecord $NewStart NewFastaName $NewFastaName
cd ${work_dir}
#cp ${base_dir}/Master-Script/metadataWorking.pl ${work_dir}/metadata.pl 
cp ${base_dir}/Master-Script/metadata.pl ${work_dir}/metadata.pl 
#echo sed -i "s/start=3115/start=${NewStart}/" ${work_dir}/metadata.pl
sed -i "s/start=3115/start=int\(\"${NewStart}\"\)/" ${work_dir}/metadata.pl
sed -i "s/FastaName=\"Vigilancia_24Nov2021\"/FastaName=\"${NewFastaName}\"/" metadata.pl  

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

echo perl metadata.pl ${Epi} ${Plan} metadata/depthReport.tsv 1
`perl metadata.pl ${Epi} ${Plan} metadata/depthReport.tsv 1`
cat fastas/*/* > metadata/${newMonth}.fasta  
#exit

## Agregar uno de 90 y uno que no salio al clean y al depth
 mkdir controlCalidad 
