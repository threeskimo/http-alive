#!/bin/bash
filename=$1
line=0
online=0
offline=0

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

echo -e "\033[1;33m-------------------------------------------------------------------------------\033[0m"

# CURL us some URLs
while read TARGET; do
	if curl --silent --output /dev/null -I --connect-timeout 3 --max-time 10 "$TARGET"; then
		line=$((line+1))
		online=$((online+1))
		printf "[$line/$total] $TARGET\t: \033[0;32monline  ($online)\033[0m\n" | expand -t 65
		echo -e "$TARGET:online" >> results.txt
		
	else
		line=$((line+1))
		offline=$((offline+1))
		printf "[$line/$total] $TARGET\t: \033[0;31moffline ($offline)\033[0m\n" | expand -t 65
		echo -e "$TARGET:offline" >> results.txt
	fi
done <$filename

#Spit out results
echo -e "\033[1;33m-------------------------------------------------------------------------------"
echo -e "\033[0monline: \033[0;32m$online \033[0m| offline: \033[0;31m$offline\033[0m"
echo -e "\033[0mResults stored in file \"results.txt\""
