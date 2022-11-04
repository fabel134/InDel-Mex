# Basic tutorial to run the main bash files

## Cloning the repository
1. `cd ~
2. `git clone --branch dev https://github.com/fabel134/InDel-Mex.git`   
#![git clone](./tutorial_ss/gitclone.png)

3. `cd ~/InDel-Mex`  
#![git clone](./tutorial_ss/cdIndelMex.png)

## Sample data 
To try this program, you can download the sample data folder from this [link](https://drive.google.com/file/d/1XtVuEIJ16FRA2yQPG--L3g0dKYV3OQRE/view?usp=sharing). We recommend to locate the bam files inside the folder `/InDel-Mex/indelmex/data/`

## Running the program 
1. Once we're located in the project folder (i.e **InDel-Mex**), we move to the folder **indelmex**, we achieve this by typing `cd indelmex/`  
#![git clone](./tutorial_ss/cdscripts.png)

2. After that, we run the file **2103_Search_pos.sh** to search the position of a possible deletion. To run it we type `bash 2103_Search_pos.sh path_to_bam_file/bam_file.bam id start_pos final_pos` where *path_to_bam_file* is the path to the folder where is located the *bam_file.bam* to analyse and _id_ is a simple string to identify the runs, you can run as many bam files as you want with the same id. *start_pos* and *final_pos* are optional, by default their values are 27399 and 28259 respectively.
#![git clone](./tutorial_ss/2103_SearchPos.png)


3. Once we ran the file to search the positions, we can check the results by typing `more ./output/id/FinalPos`, it will show 3 columns: *file name*, *initial position* and *final position* for the possible deletion.
#![git clone](./tutorial_ss/moreresultsFinalPos.png)

4.  The next step is run the file **2109_deleciones.sh**, to run it we simple type `bash 2109_deleciones.sh path_to_bam_file/bam_file.bam id start_pos final_pos` where *path_to_bam_file* is the path to the folder where is located the *bam_file.bam* to analyse, _id_ is a simple string, it should be the same used to run  **2103_Search_pos.sh** , *start_pos* is the initial position for the possible deletion (found in the previous step) and *final_pos* is the final position for the possible deletion (also found in the previos step).
#![git clone](./tutorial_ss/2109_deleciones.png)

5. Finally we type `more ./output/id/reportFinal` to check the summary.
#![git clone](./tutorial_ss/moreresultsreportFinal.png)


