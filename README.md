# InDel-Mex

Indel-Mex is a pipeline for searching large deletions in alignments (BAM file) from SARS-CoV-2.


**Input:** aligments (BAM file)
**Output:** 
	A table with general analysis
	graph sample with deletions

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
