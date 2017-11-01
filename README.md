# compute_aai_and_cogs
This repository holds a couple of scripts for computing cluster of orthologous genes (COGs) and aai (average aminoacid identity) from a collection of bacterial proteomes.

The tools depend on a working ncbi installation of ncbi blast+. You can install blast+ in your system by following instruction provided here: https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download

Since the programs are written in the Perl programming language, you will also need a Perl interpreter in order to run them. Perl is usually installed by default in unix alike systems. Anyway you can download and install the latest version of Perl from https://www.perl.org/get.html

The first script, format_and_blast.pl is used for format the sequences in the appropriate format and to perform an all against all blastp. The second, compute_cogs_and_aai.pl is used to compute the average aminoacid identity (aai) and to reconstruct clusters of orthologous genes (COGs) from the blastp output files. The final output consists in 2 files: a tabular file wiht aai values for all the species, and a text file containing the list of COGs, the number of genes and the (internal) identifiers of the genes included in each cluster.  COGs are formed using a simple best reciprocal blast match approach. In order to avoid confounding signal from possible paralogs genes, proteins showing 2 or more good matches (second best match has a score that is higher than 90% of the score of the best match) are excluded from computation.

##### FORMAT and BLAST ##########################################################################################################

To run format_and_blast.pl, you need to provide 3 input parameters, of which 1 is mandatory. The first parameter is (the name of) a simple text file providing a list of bacterial proteomes that are to be compared. One genome per line. All the proteomes need to be in fasta format (we suggest to download all the relevant files directly from the NCBI genomes resource, where available), and the list should must contain the actual names of the files (not the species or anything else). The program will concatenate the files into a multi fasta containing all the protein sequences, and assign internal idenfiers- based on progressive numbers -to each sequence.  This parameter is mandatory. 

The second parameter is the number of processors to be used by blastn. If no value is provided the default (4) will be used. In case you don't know about that, I would suggest to use the default. My advice is to you as many processors as you can on your machine.

The third parameter is a name for the output file. In no value is provided the  default (self_blast.tabular) will be used.
The file list.txt provides a valid example of a possible input file. Sample proteomes are also available on this github branch. 

This program will produce intermediate output files which will be analysed by compute_cogs_and_aai.pl in orded to obtain the final output.  The main output of format_and_blast.pl will consist in a typical blast output tabular file containing results of the all against all blast and a second file: "decode.txt" containing a list of the proteomes used by the program along with their internal identifiers. Both files will be needed in order to run compute_cogs_and_aai.pl. A third file named "concatenated.faa"
which will contain all the protein sequences in a single fasta file along with their the internal identifiers will be produced
as well.

Please be aware that since this program is likely to perform a relatively time demanding task, it would probably be better to run it in background using the nohup command.

You can run format_and_blast.pl by hittihg:

perl format_and_blast.pl <list_file> <number_of_cores> <outfile>

##### COMPUTE AAI and COGs ######################################################################################################

After you have executed format_and_blast.pl, you will need to use compute_cogs_and_aai.pl in order to complete the computation of aai and cogs. This program requires 2 input parameters, a tabular blastp output file, with the results of an all against all blastp (which is again the main output of format_and_blast.pl) and the "decode.txt" (or an equivalent file) produced by format_and_blast.pl . The first parameter is mandatory. When non ptovided, the second is set to "decode.txt" by default

The program will process the blast output file in order to compute the cogs and the aai values.  Two main output files will be created: cogs_list.csv and aai_table.csv.

cogs_list.csv will contain a space delineated list of all the cluster of orthologs genes, one cluster per line. The first value will indicate the number of genes belonging in the cluster and will be followed the corresponding list of genes. Be aware the list is based on internal identifiers, therefore you need to use the  "concatenated.faa" file created by format_and_blast.pl if you want to retrieve the sequences.   

aai.table.csv will contain aai values between all the proteomes considered in the analysis. The file will consist in a tab delineated square matrix, reporting all anib values between all the pairs of proteomes.  The file can be easily
visualized with MS-excel or equivalent programs.

You can run compute_cogs_and_aai.pl by hittihg:

perl compute_cogs_and_aai.pl <blast_file> <decode_file>


##### NOTICE ####################################################################################################################

No strong checking of file formats is perfomed, so in case of error please check that all the files are in the correct format if you encounter any error.
Anyway feel free to contact Matteo Chiara (matteo.chiara@unimi.it) if you encounter any problem or unexpected behaviour


