#!/bin/bash
filename=$1
line=1

# Check if file exists
if [[ -f "$filename" ]]; then
	echo -e "\"$filename\" will be used."
else
	echo "Invalid filename."
	exit
fi

# Count number of lines in file
total=($(wc -l < $filename))

# Check if results.txt exists
if [[ -f "results.txt" ]]; then
	echo -e "\"results.txt\" already exists. Deleting..."
	rm -f results.txt
else
	echo "\"results.txt\" will be created."

fi
echo -e "\033[1;33m-----------------------------------------------------------\033[0m"

# CURL us some URLs
while read TARGET; do
	if curl --silent --output /dev/null -I --connect-timeout 3 --max-time 10 "$TARGET"; then
		printf "[$line/$total] $TARGET\t: \033[0;32monline\033[0m\n" | expand -t 50
		echo -e "$TARGET:online" >> results.txt
		line=$((line+1))
	else
		printf "[$line/$total] $TARGET\t: \033[0;31moffline\033[0m\n" | expand -t 50
		echo -e "$TARGET:offline" >> results.txt
		line=$((line+1))
	fi
done <$filename

#Spit out results
echo -e "\033[1;33m-----------------------------------------------------------"
echo -e "\033[0mResults stored in file \"results.txt\""
