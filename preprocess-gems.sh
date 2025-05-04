#Preprocess GEMs for DESeq2 Analysis

#!/bin/bash

#Matt Harrington
#2025-04-04

#Download GEMs
wget -O BLCA_GTEX.gz https://ndownloader.figshare.com/files/9150181

wget -O BLCA_TCGA.gz https://ndownloader.figshare.com/files/9150184

#Merge the GEMs
module load anaconda3/2023.09-0 

git clone https://github.com/feltus/mergegem.git

python ./mergegem/mergegem.py BLCA_GTEX BLCA_TCGA bladder-gtex-tcga.txt
#Preprocess the GEMs
cat bladder-gtex-tcga.txt | sed -e 's/\.[0-9]*//g' -e 's/ *$//' > bladder-gtex-tcga-integer.txt 

#Remove duplicate rows
cat bladder-gtex-tcga-integer.txt | awk '!a[$1]++' > bladder-gtex-tcga-integer-unique.txt

#Remove dashes
cat bladder-gtex-tcga-integer-unique.txt| sed 's/-/_/g' > bladder-gtex-tcga-clean.txt

#Create comma-separated file
cat bladder-gtex-tcga-clean.txt | sed 's/\s/,/g' >  bladder-gtex-tcga-clean.csv

#Convert dashes to underscores in label file
cat bladder-gtex-tcga.labels.txt| sed 's/-/_/g' >  bladder-gtex-tcga-dash.labels.txt

#Add comparison label to each row
cat bladder-gtex-tcga-dash.labels.txt | sed 's/\s/,/g' | sed 's/$/,GTEX_BLCA_TCGA/' > bladder-gtex-tcga.comparison.tmp

#Make sample-group-comparison rows
cat bladder-gtex-tcga.comparison.tmp | sed 's/sample,label,GTEX_BLCA_TCGA/Sample,Group,Comparison/' > bladder-gtex-tcga.comparison.csv
