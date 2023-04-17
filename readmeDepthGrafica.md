Para obtener el depthReport:  
`ls febrero08-22/depths/ | while read line; do python3 /LUSTRE/usuario/aherrera/covid/processDepthSamtools.py febrero08-22/depths/$line febrero08-22/depthReport.tsv  ; done  `   
