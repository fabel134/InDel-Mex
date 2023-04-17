my $Month=$ARGV[0];

open(FASTA,"metadata/$Month.fasta") or die "Could not open metadata/$Month.fasta\n";
open (LISTA,"controlCalidad/paraAlinear.txt")or die "Couldnot open controlCalidad/paraAlinear.txt\n";
open (ALINEAR,">controlCalidad/Alinear.fasta")or die "Couldnot open controlCalidad/paraAlinear.txt\n";
open (NOALINEAR,">controlCalidad/NoAlinear.fasta")or die "Couldnot open controlCalidad/paraAlinear.txt\n";

my %SEQ=fillHASH();
my @LISTA=fillLISTA();	
#foreach my $id(@LISTA){print"iid $id\n";}
#foreach my $seq(sort keys %SEQ){print ("id $seq\n");
#	-> $SEQ{$seq} #\n");
#		}
foreach my $seq(keys %SEQ){
	if($seq ~~ @LISTA){
		print ALINEAR ">$seq\n$SEQ{$seq}\n";}
	else{
		my $id=$seq;
		my @st=split('_',$id);
		pop(@st);
		my $newId=join('_',@st);
		print NOALINEAR ">$newId\n$SEQ{$seq}\n";}
}
#------------------------------
sub fillLISTA{
	my @LISTA;
	foreach my $line(<LISTA>){
		chomp $line;
		if($line ne ""){
			push(@LISTA,$line);
		}
	}
	return @LISTA;
}
#--------------------------------------------
## Fill hash with fastas  
sub fillHASH{
my %SEQ;
my $id="";
foreach my $line (<FASTA>){
	chomp $line;
	#print "$line\n";
	if($line=~/>/){
		$id=$line;
		$id=~s/>//;
		}
	else{   if($id ne ""){
			$SEQ{$id}=$line;
			$id="";
			}
		}
	} 
	return %SEQ;
}


close FASTA;
close LISTA;
