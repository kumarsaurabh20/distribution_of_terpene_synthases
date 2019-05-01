#!/bin/bash
filter_name=$1
extension=$2
if [ -z "$filter_name" -o -z "$extension" ]; then
	echo "Error :: arguments not specified!"
	echo "Usage :: bash '$0' '<genus_name>' '<genome|protein|gff>'"
	exit 1
fi
#
if [ -e "assembly_summary.txt" ]; then
	echo "Found assembly_summary.txt file"	
else
	wget ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/bacteria/assembly_summary.txt
	echo "Assembly file is downloaded"
fi
#
if [ -e "streptomyces.paths" ]; then
	echo "Found paths file"
else
	grep "$filter_name" assembly_summary.txt | awk '{FS=OFS="\t"} { if ($12~/^Complete/) print $20}' > streptomyces.paths
	echo "A new paths file is created with name '${filter_name}.paths'"
fi
#
if [ "$extension" == "genome" ]; then
	for each in $(cat streptomyces.paths);do name=`echo $each | cut -d'/' -f10`;wget -P genomes "${each}/${name}_genomic.fna.gz";done
	gunzip genomes/*.gz
	exit 0
elif [ "$extension" == "protein" ]; then
	for each in $(cat streptomyces.paths);do name=`echo $each | cut -d'/' -f10`;wget -P proteomes "${each}/${name}_protein.faa.gz";done
	gunzip proteomes/*.gz
	exit 0
elif [ "$extension" == "gff" ]; then
	for each in $(cat streptomyces.paths);do name=`echo $each | cut -d'/' -f10`;wget -P gffs "${each}/${name}_genomic.gff.gz";done
	gunzip gffs/*.gz
	exit 0
fi
