use strict;
use Unicode::Normalize;
#comenzar en el 1513 #recuerda que debes ponerle el numero donde inicias -1
# perl metadata.pl metadata/EpiCoV_LANGEBIO_100321_corregido.xlsx.tsv metadata/PlaneacionIDCorridaAH1COV2SSr015.xlsx.tsv metadata/depthReport.tsv 1 
### Variables ...........
#
my $start=3115; #Mayo 1 0..(el numero anterior que nos quedamos)
my $submitter="nselem";	 #Submitter[0]i
my $FastaName="Vigilancia_24Nov2021";	#FASTA filename[1] ¿Es un multifasta?i
my $technology="Illumina";	#Sequencing technology[17]
my $method="bowtie2-2.3.4.3 / ivar-1.3.1"; #Assembly method[18]	
my $subLab="Unidad de Genomica Avanzada"; #Submitting lab[23]	
my $address="Libramiento Norte Leon Km 9.6, 36821 Irapuato, Gto."; #Address	
my $author="Consorcio Mexicano de Vigilancia Genomica (CoViGen-Mex). Authors (in alphabetical order): Julio Elias Alvarado-Yaah, Carlos F. Arias, Santiago Avila-Rios, Victor Hugo Borja-Aburto, Celia Boukadida, Juan Bautista Chale-Dzul , Jose Antonio Enciso-Moreno, Gloria Elena Espinoza-Ayala, Fernando Fontove-Herrera, Concepcion Grajales-Muniz, Ricardo Grande, Alfredo Herrera-Estrella, Carla Ivon Herrera-Najera, Pavel Isa, Brenda Irasema Maldonado-Meza, Bernardo Martinez-Miguel, Margarita Matias-Florentino, Maria Guadalupe de Jesus Mireles-Rivera, Gloria Maria Molina-Salinas, Hector Montoya-Fuentes, Jose Esteban Munoz-Medina, Jose de Jesus Nunez-Contreras, Alicia Ocana-Mondragon, Luis Alberto Ochoa-Carrera, Hector Esteban Paz-Juarez, Francisco Pulido, Helen Haydee Fernanda Ramirez-Plascencia, Angel Gustavo Salas-Lais, Jorge Ivan Salinal-Nevarez, Alejandro Sanchez-Flores, Clara Esperanza Santacruz-Tinoco, Maria Guadalupe Santiago-Mauricio, Nelly Selem-Mojica, Blanca Taboada, Gloria Vazquez "; #Authors[25]
my $firstline="submitter\tfn\tcovv_virus_name\tcovv_type\tcovv_passage\tcovv_collection_date\tcovv_location\tcovv_add_location\tcovv_host\tcovv_add_host_info\tcovv_sampling_strategy\tcovv_gender\tcovv_patient_age\tcovv_patient_status\tcovv_specimen\tcovv_outbreak\tcovv_last_vaccinated\tcovv_treatment\tcovv_seq_technology\tcovv_assembly_method\tcovv_coverage\tcovv_orig_lab\tcovv_orig_lab_addr\tcovv_provider_sample_id\tcovv_subm_lab\tcovv_subm_lab_addr\tcovv_subm_sample_id\tcovv_authors\tcovv_comment\tcomment_type\n";
my $secondline="Submitter\tFASTA filename\tVirus name\tType\tPassage details/history\tCollection date\tLocation\tAdditional location information\tHost\tAdditional host information\tSampling Strategy\tGender\tPatient age\tPatient status\tSpecimen source\tOutbreak\tLast vaccinated\tTreatment\tSequencing technology\tAssembly method\tCoverage\tOriginating lab\tAddress\tSample ID given by originating laboratory\tSubmitting lab\tAddress\tSample ID given by the submitting laboratory\tAuthors\tComment\tComment Icon\n";

my $file=$ARGV[0]; #EpiCoV
my $fileCorrida=$ARGV[1]; #archivo de secuenciacion
my $fileDepth=$ARGV[2];  # Archivo de profundidad generado por Fonty
my $verbose=$ARGV[3];  # verbose, cuanto va a imprimir el pantalla para debugg#----------------------------- main

my %depths=readDepth($fileDepth);   ## reading depths 1-400 (Ids from 1-400)
my %biblioteca=readBiblio($fileDepth);   ## reading depths 1-400 (Ids from 1-400)
#my $cleanMD=cleanFile($file);
#foreach my $key(keys %depths){print "$key - > $depths{$key}\n";}
#exit;
fillFile($file,$fileCorrida,$start,%depths); #filling metadata and printing files new headers
exit;
#------------------------------------------
#-

#____________________________________________________________#


sub cleanFile0{
	my $file=shift;
	`perl -p -i -e s/\'a/a/g $file`;}
sub fillFile{
	my $file=shift; #EpiCoV
	my $plan=shift; #planeacion Alngebio
	my $start=shift; #lastnumber
	my %Depth=@_;

	mkdir "fastas";
	mkdir "fastas/97";
	mkdir "fastas/90";
	mkdir "fastas/OTHER";

	my $coun97=0;
	my $coun90=0;
	my $counOTHER=0;



	open (FILE,$file) or die "could not open $file!\n";
	
	open (OUT97,">$file-97.tsv") or die "could not open out $file-97!\n";
	open (OUT90,">$file-90.tsv") or die "could not open out $file-90!\n";
	open (OUTA,">$file-all.tsv") or die "could not open out $file-all!\n";
	open (ERROR,">metadata/ReportError") or die "could not open out error-file!\n";

	<FILE>; <FILE>;
	print OUT97 "$firstline"; print OUT97 "$secondline";
	print OUT90 "$firstline";print OUT90 "$secondline";
	print OUTA "$firstline"; print OUTA "$secondline";

	my $gisaid=1;  ## En que numero de esta corrida voy de los que tienen >97%
	my $corrida=1;  ## En que numero de esta corrida voy de de todos los genomas
	
	foreach my $line(<FILE>){
	
		my @st=split('\t',$line);
		#Coverag [19]
		#Sample ID given by the sample provider[*22]	
		#Sample ID given by the submitting laboratory[24]	
		my $IMSS_num=$st[22];	 #Submitter[0]
		if($verbose ne 0){	
#			print "IMSS num $IMSS_num\n";
#			print "grep -w  $IMSS_num $plan |cut -f1\n"; #num=202101034985
		} 
		my $num=`grep -w $IMSS_num $plan |cut -f4`; #IMSS_num=202101034985 
				    				   #st[22
								   #num=0354 (ejemplo)] es el número de biblioteca
		#1 ...   202101034985    hCoV-19/Mexico/TLA_UGA_IMSS_0001/2021 ... 0001 
		#Search in planeation file, which number in UGA corresponds to ID from provider
		$num =~ s/\R//g;#;
		 
	#	print "¡$num!\n";
                my $inum=int($num);
                #my $bib=$biblioteca{$inum};
		my $depth=$Depth{$inum}; #From depth file original id 1-400 
		if($verbose ne 0){	
		#	print "num $inum -> bib $bib -> Depth $Depth{$bib} !\n";
			#print "num $inum -> $bib IMSS->  $IMSS_num -> Depth $Depth{$bib} !\n";
		}
		#print "$inum  $depth=$Depth{$inum}\n"; #From depth file original id 1-400 
		# sumo ese Id al numero serial
                
		# Here we got location
                my @st2=split('/',$st[2]);
		my $location=$st[2];
		$location=~s/([A-Z]*)_LANGEBIO//;
		my $state=$1; #Eje TAM, MOR, etc
		if($verbose ne 0){
		#	print "state $state\n";
			#my $pause=<STDIN>;
			}
		
		# Aqui calcular N's y decidir el nuevo Id
                # 0039_S39-clean.fa primera corrida
                # 335_S11.qual.txt segunda corrida
 
		if ( -e "ensamblajes/$inum-clean.fa" ){
		#	print "ensamblajes/$bib\_S$inum-clean.fa\n"; 
			#print "pause\n";
			#my $pause=<STDIN>;
			# Read second line of clean files (line with sequence)
			`echo tail -n1 ensamblajes/$inum-clean.fa |grep -o N |wc -l`;
                 	my $ENES=`tail -n1 ensamblajes/$inum-clean.fa |grep -o N |wc -l`;
		
			my $virusName;
		 	
			if ($ENES<900){
				$coun97++;
				my $newID=newId($gisaid,$start); #count>97,#start series
				#print "$start, $gisaid, $newID\n";
				$virusName="hCoV-19/Mexico/$state\_LANGEBIO_IMSS_$newID/2021";### 97% GISAID
				$gisaid++;  ## How many genomes with good quality for gisaid from 0-..400i
				open (SEQ,">fastas/97/$newID.faa") or die "EROR";
				my $seq= `head -n2 ensamblajes/$inum-clean.fa |tail -n1 `;
				print SEQ ">$virusName\_$inum\n$seq\n";
				close SEQ;
				$corrida++;
				}
			elsif ($ENES<2990){
				$coun90++;
				my $local=substr($IMSS_num,-5);
				$virusName="hCoV-19/Mexico/$state\_LANGEBIO_IMSS_$local\_NC/2021";
				open (SEQ,">fastas/90/$IMSS_num.faa") or die "EROR";
				my $seq= `head -n2 ensamblajes/$inum-clean.fa |tail -n1 `;
				print SEQ ">$virusName\_$inum\n$seq\n\n";
				close SEQ;
				$corrida++;
				#print"NO GISASID $virusName\n";
				 }#Virus name[2] 90%
			else{
				$counOTHER;
				my $local=substr($IMSS_num,-5);
				$virusName="hCoV-19/Mexico/$state\_LANGEBIO_IMSS_$local-OTHER/2021"; 
				$corrida++;
				}#Virus name[2]

		# Removing accents from columns lab of origin and address
		my $OriginatedLab = NFKD( $st[20] );
		$OriginatedLab=$st[20];
		$OriginatedLab =~ s/\p{NonspacingMark}//g;
		
		my $OrigiAddress =  $st[21] ;
		my @predate=split('/',$st[5]);
		my $date=$predate[0]."-".$predate[1]."-".$predate[2];
		$date=~s/--//;
		#print "$OrigiAddress\n";
		#my $pause; $pause=<STDIN>;
	
		$st[0]=$submitter;	 #Submitter[0]i
		$st[1]=$FastaName;	#FASTA filename[1] ¿Es un multifasta?i
		$st[2]=$virusName;	
	 	$st[5]=$date;
		$st[17]=$technology;	#Sequencing technology[17]
		$st[18]=$method; #Assembly method[18]	
		$st[19]=$depth;
		$st[20]=$OriginatedLab;
		$st[21]=$OrigiAddress; #Submitting lab[23]	
		$st[23]=$subLab; #Submitting lab[23]	
		$st[24]=$address;	
		$st[26]=$author;
#		print "$st[25]\n";
		my $newline="";
		my @stn=@st;
		for(my $i=10;$i<=28;$i++){$stn[$i]=$st[$i-1];}
		$stn[29]=$inum; 
		foreach my $column(@stn){
			$column=~s/\r//; chomp $column;
			$newline.=$column."\t";
			#print"¡$column!";
			#my $pause; $pause=<STDIN>;
			}
			$newline=~s/^\t//;
			if($ENES<900) {print OUT97 "$newline\n";}
			if($ENES<2990) {print OUT90 "$newline\n";}
			else{print OUTA "$newline\n";}
		}
		else{
		print ERROR "$IMSS_num has no cleaned fasta file exists for  fastas/$inum-clean.fa \n";}
	}

	print "Count97 $coun97\n";
	print "Count90 $coun90\n";
	print "CountOTHER $counOTHER\n";

	close OUT97;
	close OUT90;
	close OUTA;
	close FILE;
	close ERROR;	
}
#-------------------------------------------------------------------------------------------
sub newId{
 my $num=shift;
 my $start=shift;
 my $newID=$num+$start;
 my $length=length($newID);
 	if ($length==1)
		{$newID="000$newID";}
	elsif ($length==2)
		{$newID="00$newID";}
 	elsif ($length==3)
		{$newID="0$newID";}
 	elsif ($length==4)
		{$newID="$newID";}
 return $newID;
}
#------------------------------------------------------------------------------------------
#
sub readDepth{
	my $file=shift;
	open(FILE,$file) or die "$file!\n";
	my %depth;
	foreach my $line (<FILE>){
		chomp $line;
		#if($verbose){print "$line\n";}
		my @st=split('\t', $line);
		   $st[0]=~s/(\d*)_S//;
		my $numId=int($1);
		$depth{$numId}=$st[1];
		if($verbose){
		#	print "$numId->$depth{$numId}\n";
		#	my $pause=<STDIN>;
			}
		}
	close FILE;
	return %depth;		
}
#--------------------------------------------------
sub readBiblio{
	my $file=shift;
	open(FILE,$file) or die "$file!\n";
	my %biblio;
	foreach my $line (<FILE>){
		chomp $line;
		#if($verbose){print "$line\n";}
		my @st=split('\t', $line);
		   $st[0]=~s/(\d*)_S(\d*)//;
		my $bib=int($1);
		my $consecutivo=$2;
		$biblio{$consecutivo}=$bib;
		if($verbose){
			#print "$consecutivo->$biblio{$consecutivo}\n";
			#my $pause=<STDIN>;
			}
		}
	close FILE;
	return %biblio;		
}

