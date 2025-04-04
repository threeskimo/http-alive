#!/bin/bash
filename=$1
max_jobs=10  # Maximum number of concurrent curl requests
tmp_dir=$(mktemp -d)
online=0
offline=0

# Check if file exists
if [[ -z "$filename" || ! -f "$filename" ]]; then
    echo "Usage: $0 <url_list_file>"
    echo "Example: $0 urls.txt"
    exit 1
fi
echo -e "\"$filename\" will be used."

# Count number of lines in file
total=$(wc -l < "$filename")

# Check if results.txt exists
[[ -f results.txt ]] && echo "\"results.txt\" already exists. Deleting..." && rm -f results.txt
echo "\"results.txt\" will be created."

echo -e "\033[1;33m-------------------------------------------------------------------------------\033[0m"

# Function to check a single URL
check_url() {
    local target=$1
    local index=$2

    if curl --silent --output /dev/null -I --connect-timeout 3 --max-time 10 "$target"; then
        echo -e "$target:online" > "$tmp_dir/result_$index"
        printf "[$index/$total] $target\t: \033[0;32monline\033[0m\n" | expand -t 65
    else
        echo -e "$target:offline" > "$tmp_dir/result_$index"
        printf "[$index/$total] $target\t: \033[0;31moffline\033[0m\n" | expand -t 65
    fi
}

# Export the function so subshells can access it
export -f check_url
export tmp_dir total

# Read lines and run in parallel
i=0
while IFS= read -r url; do
    i=$((i + 1))
    check_url "$url" "$i" &
    
    # Limit concurrent jobs
    while (( $(jobs -r | wc -l) >= max_jobs )); do
        sleep 0.1
    done
done < "$filename"

wait

# Combine results
cat "$tmp_dir"/result_* > results.txt
online=$(grep -c 'online' results.txt)
offline=$(grep -c 'offline' results.txt)

echo -e "\033[1;33m-------------------------------------------------------------------------------"
echo -e "\033[0monline: \033[0;32m$online \033[0m| offline: \033[0;31m$offline\033[0m"
echo -e "\033[0mResults stored in file \"results.txt\""

# Cleanup
rm -rf "$tmp_dir"
