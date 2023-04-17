use strict;
use warnings;
open (FASTA, "$ARGV[0]") || die "No se puede abrir el archivo $ARGV[0]\n";
open (TSV, "$ARGV[1]") || die "No se puede abrir el archivo $ARGV[1]\n";
open (OUT, ">$ARGV[2]") || die "No se puede abrir el archivo $ARGV[2]\n";
open (REF, "$ARGV[3]") || die "No se puede abrir el archivo $ARGV[3]\n";

print "$ARGV[0]\n";
print "$ARGV[1]\n";
print "$ARGV[2]\n";
my @aLine;
my ($i,$lineFile,$fas,$idRef,$fasRef,$id,$len,$posGenome,$posAuxI,$numVars,$posAuxD,$str,$pos,$strNew,@varian);
$id=<FASTA>;
$fas=<FASTA>;
$idRef=<REF>;
$fasRef=<REF>;
@varian=<TSV>;
$posAuxD=0;
$posAuxI=0;
$numVars=scalar(@varian);
for($i=1;$i<$numVars-1;$i++)
{
	@aLine=split(/\t/,$varian[$i]);
	if( (($aLine[4]+$aLine[7])>=3) and ($aLine[7]>$aLine[4]) )
	{
		print "Variante mayor $aLine[1] $aLine[7] $aLine[4]\n";
		if($aLine[3]=~"-")
		{
			$len=length($aLine[3])-1;
			$posGenome=$aLine[1]-$posAuxD+$posAuxI;
			$pos=$aLine[1];
			print "Deletion. $len\t$posGenome\n";
			$i++;
			@aLine=split(/\t/,$varian[$i]);
			while ($aLine[1]<=($posGenome+$len))
			{
				$i++;
				@aLine=split(/\t/,$varian[$i]);
			}
			$posAuxD+=$len;
			$i--;
		}
		if($aLine[3]=~ /\+/){
			$len=length($aLine[3])-1;
			$posAuxI+=$len;
			print "Intsercion. $len\t$aLine[3]\n";
		}
		if( ($aLine[7]<=10)   and $aLine[3]!~"-" ) 
		{
			$posGenome=$aLine[1]-$posAuxD+$posAuxI-1;
			print "Cambio. $posGenome\t$aLine[4]\t$aLine[7]\n";
			substr($fas, $posGenome, 1, 'N');	
		}
		if( ($aLine[7]>10)   and $aLine[1]=~"8658" )
		{
			$posGenome=$aLine[1]-$posAuxD+$posAuxI-1;
			print "Cambio. $posGenome\t$aLine[4]\t$aLine[7]\n";
			substr($fas, $posGenome, 1, 'A');	
		}
		
	}
}
#substr($fas, 29870, 33, 'NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN');	
print OUT $id;
print OUT $fas;
close FASTA;
close TSV;

