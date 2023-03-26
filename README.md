# InDel-Mex
# Hi again!
Indel-Mex is a pipeline for searching large deletions in alignments (BAM file) from SARS-CoV-2.

[Sample data](https://drive.google.com/file/d/1XtVuEIJ16FRA2yQPG--L3g0dKYV3OQRE/view?usp=sharing)

**Input:** aligments (BAM file).

**Output:** 
	A table with general analysis.
	graph sample with deletions.

## Programs necessary for run InDel-Mex
	-samtools V1.9
	-ncbi-blast+ V2.9.0

## InDel-Mex Installation guide
0.
1.
2. run InDel-Mex

### Run Indel-Mex
#### Searching positions with possible deletions
	$ bash 2103_Search_pos.sh YourFile.bam

#### Analysing sample with possible deletions
	$ bash 2109_deleciones.sh YourFile.bam


## Explaining the structure of this repository.

**Analisis_R_Indel_Mex:** containing R scripts to generate plots.

**ClusterConacyt:** containing scripts for running raw data from CoViGen-Mex in the cluster CONACYT.

**Mazorca:** containing scripts for running raw data from CoViGen-Mex in the cluster mazorca of LANGEBIO-CINVESTAV.

**scritps_indelmex:** containing scripts for running InDel-Mex
