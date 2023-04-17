my $file="controlCalidad/MexCov2.tsv";
open(FILE,$file) or die "couldnot open $file\n";

<FILE>;
foreach my $line (<FILE>){
	chomp $line;
#	print "$line\n";
#	my $pause=<STDIN>;
	my @st=split('\t',$line);
	my @Mut=split(',',$st[5]);#Nuevas mutaciones de Nucleotido
	my @Del=split(',',$st[9]);#Nuevas deleciones
	my @Ins=split(',',$st[13]);#Nuevas inserciones
	my @reads=split('_',$st[0]);
	my $read=$reads[$#reads];
	#print"mutaciones $st[5]\ndeleciones$st[9]\n inserciones $st[13]\n read $read\n";
	#my $pause=<STDIN>;
	#print"$read\n";
	#my $pause=<STDIN>;
	nuevasMutaciones($read,@Mut);
	nuevasDeleciones($read,@Del);
	nuevasInserciones($read,@Ins);

	}
#---------------------------------------------------------------
sub nuevasMutaciones{
	my $read=shift;
	my@Mut=@_;
	foreach my $mut(@Mut){
#		print"$mut\n";
#		my $pause=<STDIN>;	
		my @coord=split(':',$mut);
		$coord[1]=~s/[A-Za-z]//g;	
		my $pos=$coord[1];
		print ("#### MUTACION $read\t$mut\n");
		my $grep=`grep -P NC_045512.2'\t'$pos'\t' variantes/$read*vcf `;
		print "$grep\n";
		my @gr=split('\t',$grep);
	#	print ("0:$gr[4],1-$gr[5],$gr[6],$gr[7],$gr[8],$gr[9]\n");

	}
}
#------------------------------------------------------------------
sub nuevasDeleciones{
	my $read=shift;
	my @Del=@_;

	foreach my $del(@Del){	
		my @coord=split(':',$del);
		my $inicio=$coord[1];
		if($coord[1]=~/-/){
			my @ini=split('-',$coord[1]);
			$inicio=@ini[0];}
		#$coord[1]=~s/[A-Za-z]//g;	
		#my $pos=$coord[1];
		my $init=$inicio;
		chop($inicio);
		my $grep0=`grep NC_045512.2'\t'$inicio* variantes/$read*vcf |grep INDEL`;
		#print("grep -P NC_045512.2'\t'$inicio* variantes/$read*vcf");
 		#my $pause=<STDIN>;
		#print "$grep0\n";
 		#my $pause=<STDIN>;
		my @gr=split('\n',$grep0);
		foreach my $row(@gr){
			my @data=split('\t',$row);
			#print(" $data[1] \t $init\t abs($data[1]-$init)<=10\n");
 			#my $pause=<STDIN>;
			if(abs($data[1]-$init)<=10){
				print ("##### DELECION $read\t$del\n");
				print("row $row\n");
			}
		}	
	}	
}
#--------------------------------------------------------------
sub nuevasInserciones{
	my $read=shift;
	my @Ins=@_;

	foreach my $del(@Ins){	
		my @coord=split(':',$del);
		my $inicio=$coord[1];
		if($coord[1]=~/-/){
			my @ini=split('-',$coord[1]);
			$inicio=@ini[0];}
		#$coord[1]=~s/[A-Za-z]//g;	
		#my $pos=$coord[1];
		my $init=$inicio;
		chop($inicio);
		#print "inicio $inicio del $del\n";
		#my $pause1= <STDIN>;
		my $grep0=`grep NC_045512.2'\t'$inicio* variantes/$read*vcf |grep INDEL`;
		#print("grep -P NC_045512.2'\t'$inicio* variantes/$read*vcf");
		#print "$grep0\n";
		my @gr=split('\n',$grep0);
		foreach my $row(@gr){
			my @data=split('\t',$row);
		#	print(" $data[1] \t $init\t abs($data[1]-$init)<=10\n");
	#		my $pause=<STDIN>;
			if(abs($data[1]-$init)<=10){
				print ("##### INSERCION $read\t$del\n");
				print("row $row\n");
			}
		}	
		#print ("0:$gr[4],1-$gr[5],$gr[6],$gr[7],$gr[8],$gr[9]\n");
	}	
}
