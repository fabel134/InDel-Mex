
open(FILE,"controlCalidad/MexCoV2.csv");

<FILE>;
foreach my $line (<FILE>){
	chomp $line;
	my @st=split('"',$line);
	my @Mut=split(',',$st[11]);#Nuevas mutaciones de Nucleotido
	my @Del=split(',',$st[19]);#Nuevas deleciones
	my @Ins=split(',',$st[27]);#Nuevas inserciones
	my @reads=split('_',$st[1]);
	my $read=$reads[$#reads];
	nuevasMutaciones($read,@Mut);
	nuevasDeleciones($read,@Del);
	nuevasInserciones($read,@Ins);

	}
#---------------------------------------------------------------
sub nuevasMutaciones{
	my $read=shift;
	my@Mut=@_;
	foreach my $mut(@Mut){	
		my @coord=split(':',$mut);
		$coord[1]=~s/[A-Za-z]//g;	
		my $pos=$coord[1];
		print ("#### MUTACION $read\t$mut\n");
		my $grep=`grep -P NC_045512.2'\t'$pos'\t' variantes/$read* `;
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
		print ("##### DELECION $read\t$del\n");
		my $grep0=`grep $inicio* variantes/$read* |grep [-][ACGT]`;
		#print("grep -P NC_045512.2'\t'$inicio* variantes/$read*");
		#print "$grep0\n";
		my @gr=split('\n',$grep0);
		foreach my $row(@gr){
			my @data=split('\t',$row);
			#print(" $data[1] \t $init\t abs($data[1]-$init)<=10\n");
			if(abs($data[1]-$init)<=10){
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
		print ("##### INSERCION $read\t$del\n");
		my $grep0=`grep $inicio* variantes/$read* |grep [+][ACGT]`;
		#print("grep -P NC_045512.2'\t'$inicio* variantes/$read*");
		#print "$grep0\n";
		my @gr=split('\n',$grep0);
		foreach my $row(@gr){
			my @data=split('\t',$row);
			#print(" $data[1] \t $init\t abs($data[1]-$init)<=10\n");
			if(abs($data[1]-$init)<=10){
				print("row $row\n");
			}
		}	
		#print ("0:$gr[4],1-$gr[5],$gr[6],$gr[7],$gr[8],$gr[9]\n");
	}	
}
