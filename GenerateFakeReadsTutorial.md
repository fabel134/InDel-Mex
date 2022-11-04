# Tutorial to generate fake reads

#### Things we need before running the program
1. The repository cloned (You can consult the process [here](./BasicTutorial.md))
2. A base fasta file to generate the reads, in this repository we have a file *base_reads.fasta* located in the folder `/InDel-Mex/indelmex/data/`.
3. Have installed **bwa** and **samstools**

#### The Process
1. First we move to the folder *indelmex*, we can achieve that by typing `cd ~/InDel-Mex/indelmex/`.

2. Now we simply run the file *generate_reads.sh* typing `bash generate_reads.sh path_to_base_fasta_file result_filename del_size del_start` where *path_to_base_fasta_file* is the path to your base file, you could use */InDel-Mex/indelmex/data/base_reads.fasta* if you don't have a custom one. *result_filename* is the base filename for the resulting reads, take in consideration that *del_size*, which is the desired deletion size, will be part of the final filename, and finally *del_start* is the beggining of the deletion, is completly option, the valuebydefault is 21000.

After running thisfile, you will get new files in the folder `/InDel-Mex/indelmex/simulations/`, this file will have the following names:
* *result_filename*del*del_size*.fasta
* *result_filename*del*del_size*.sam
* *result_filename*del*del_size*.bam