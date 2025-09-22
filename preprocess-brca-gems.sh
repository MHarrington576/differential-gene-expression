#!/bin/bash

#Clone MergeGEM program
git clone https://github.com/feltus/mergegem.git

python ./mergegem/mergegem.py ea_bc_gem.tsv aa_bc_gem.tsv merged-bc-gem-raw.txt

#Preprocess the merged GEMs
cat merged-bc-gem-raw.txt | sed -e 's/\.[0-9]*//g' -e 's/ *$//' > merged-bc-gem-integer.txt 

#Remove duplicate rows
cat merged-bc-gem-integer.txt | awk '!a[$1]++' > merged-bc-gem-integer-unique.txt

#Remove dashes
cat merged-bc-gem-integer-unique.txt | sed 's/-/_/g' > merged-bc-gem-clean.txt

#Create comma-separated file
cat merged-bc-gem-clean.txt | sed 's/\s/,/g' > final-merged-bc-gem.csv

#Convert dashes to underscores in label file
cat merged-bc-gem-raw.labels.txt| sed 's/-/_/g' > merged-bc-gem-raw-dash.labels.txt

#Add comparison label to each row
cat merged-bc-gem-raw-dash.labels.txt | sed 's/\s/,/g' | sed 's/$/,EA_BRCA_AA/' > merged-bc-gem-raw.comparison.tmp

#Make sample-group-comparison rows
cat merged-bc-gem-raw.comparison.tmp | sed 's/sample,label,EA_BRCA_AA/Sample,Group,Comparison/' > merged-bc-gem.comparison.csv
