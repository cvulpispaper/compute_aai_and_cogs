#!/usr/bin/perl -w
use strict;

my $blast_file=shift;
die ("could not find $blast_file\n") unless -e $blast_file;
open(BL,$blast_file);


my $decode_file=shift;
$decodde_file="decode.txt" unless $decode_file;
die ("could not find $decode_file\n") unless -e $decide_file;

my @AAIG=();
my @AAID=();
my %decode_name=();
open(IN,$decode_file);

while(<IN>)
{
	chomp;
	my ($num,$name)=(split())[0,1];
	$decode_name{$num}=$name;
	push(@AAIG,$num);
	push(@AAID,$name);
}


my %gene_list=();
my %hit_list=();
my %gene_matrix=();
my $query="";
my $gquery="";

my %duplications=();
my $norm_V=0;
my %seen=();

open(COGS,">cogs_list.csv");
open(AAI,">aai_table.csv");



while(<BL>)
{
	if($_=~/^\#/|| $_=~/Warning/) {
		next;
	}else{
		my ($q,$hit,$id,$alnL,$bit_score)=(split())[0,1,2,3,-1];
		$norm_V=0 unless $seen{$q};
		$gquery=(split(/\_/,$q))[0];
		$gene_list{$q}=$gquery;
		next if $q eq $hit;
		$norm_V=$bit_score if $norm_V==0;
		$bit_score/=$norm_V;
		my $genome=(split(/\_/,$hit))[0];
		if (($genome ne $gquery))
		{
			if ($hit_list{$q}{$genome})
			{
				my $prev_hit=$hit_list{$q}{$genome}[0];
				my $delta=($hit_list{$q}{$genome}[1]-$bit_score);
				if ($delta <= 0.1)
				{
					$duplications{$genome}++;
					$hit_list{$q}{$genome}[2]=0; 
				}
			}else{
				$hit_list{$q}{$genome}=[$hit,$bit_score,1,$id,$alnL]; #hit bit_score dupl
			}
		}
		$seen{$q}=1;
	}
}
my %printed=();
my %genomes=();
my %aai=();
foreach my $gene (sort keys %gene_list)
{
	my $gq=$gene_list{$gene};
	my $score_bbr=1;
	my @best=();
	my @genomes=();
	my @non_best_genome=();
	my @scores=();
	push (@genomes,$gq);
	next if $printed{$gene};
	my $nhit=0;
	foreach my $genome (keys %{$hit_list{$gene}})
	{
		$nhit++;
		my $hit=$hit_list{$gene}{$genome}[0];
		my $score=$hit_list{$gene}{$genome}[1];
		my $best=$hit_list{$gene}{$genome}[2];
		my $idpc=$hit_list{$gene}{$genome}[3];
		my $alnL=$hit_list{$gene}{$genome}[4];
		next if $best==0;
		my $reciprocal_best=0;
		if ($hit_list{$hit}{$gq})
		{
			
			my $rbest=$hit_list{$hit}{$gq}[0] eq $gene ? 1 : 0;
			$rbest=0 if $hit_list{$hit}{$gq}[2]==0;
			#print "\t$genome\t$hit\t$best\n";
			if ($rbest==1 && $best==1)
			{
				$aai{$gq}{$genome}[0]+=$idpc*$alnL;
				$aai{$gq}{$genome}[1]+=$alnL;
				$aai{$genome}{$gq}[0]+=$idpc*$alnL;
				$aai{$genome}{$gq}[1]+=$alnL;
				$score_bbr++;
				push (@best,$hit);
				push (@genomes,$genome);
				push (@scores,$score);
			}else{
				push (@non_best_genome,$genome);
			}
		}	
	}
	#my $nnostri=genomi_nostri(\@genomes);
	my $already=0;
	my $ngiusti=0;
	my $nsbagliati=0;
	$nhit=@genomes;
	foreach my $h (@best)
	{
		unless ($printed{$h})
		{
			$printed{$h}++;
		}else{
			$already=1;
		}
	}
	next if $already==1;
	foreach my $g (@genomes)
	{
		#	$is1=1 if $g==1;
		$genomes{$g}++;
	}
		
	print COGS "$score_bbr $gene @best\n"; #if $already==0;
}

print " @AAID\n";
foreach my $genome (@AAIG)
{
	my $decode1=$decode_name{$genome};
	print AAI "$decode1\t";
	foreach my $gen2 (@AAIG)
	{
		my $aai= $genome == $gen2 ? 100 :$aai{$genome}{$gen2}[0]/$aai{$genome}{$gen2}[1];
		print AAI "$aai\t";
	}
	print AAI "\n";
}
		

