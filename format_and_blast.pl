$file_list=shift;
$num_blast=shift;
$out_file=shift;


die("\n
     #####################################################################################################
     #This program requires 3 input parameters: A file containing a list of fasta files with the protein,# 
     #sequences the number of processors to be used by blastp, and a name for the output file. The first #
     #parameter is mandatory, but you did not provide it. Please run the program again!                  #
     #####################################################################################################\n\n") unless $file_list;

$num_blast=4 unless $num_blast;
$out_file="self_blast.tabular" unless $out_file;

open(IN,$file_list);
open(OUT,">decode.txt");
open(FAS,">concatenated.faa");
$nG=1;
while(<IN>)
{
	$nP=1;
	chomp;
	$file=$_;
	print OUT "$file $nG\n";
	open(N,$file);
	while(<N>)
	{
		if ($_=~/^>/)
		{
			print FAS ">$nG\_$nP\n";
			$nP++;
		}else{
			print FAS;
		}
	}
	$nG++;
}

system("makeblastdb -in $file_list.concatenated.faa -dbtype prot -out $file_list.db")==0||die("$! could not create the db!");
system("blastp -query $file_list.concatenated.faa -db $file_list.db -num_threads $num_blast -outfmt 7 -out $out_file")==0||die("$! could not complete the blastp!");
