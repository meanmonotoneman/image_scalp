#!/bin/bash

start_time=$(date +%s)
# Use the find command to locate the script
script_path=$(find . -name "random_quote.sh")

if [ -z "$script_path" ]; then
	echo "Script not found.
	exit 1
fi

# Source the script
source "$script_path"
#Specify the target directory to store the html file and folder ( please store in a different dir ).
target_directory=.
echo "================================================================"

# Prompt for user input
echo -e '"Welcome to the Image-Web-Scalp spell." \n\n\n'


# Prompt the user to make a folder, as well as imput validation
read -r -p '"Create a folder by giving it a name":  ' folder_name
if [ -z "$folder_name" ]; then
	echo 'enby_mage: "Invalid folder name."'
	exit 1
fi
echo -e "\n\n\n"

# Create a folder in the target directory
mkdir -p "$target_directory/$folder_name"

# Variable to store errors
failed_urls=""

# URLs from a file (urls.txt) containing one URL per line
while IFS= read -r user_url; do
	# Extract the last segment of the URL as the folder name
	folder_name2=$(basename "$user_url")

	# Create a directory based on the folder name
	mkdir -p "$target_directory/$folder_name/$folder_name2"


	# Download the content using wget and save it in the folder with the .html file
	wget "$user_url" -O "$target_directory/$folder_name/$folder_name2/scalped.html"

	# Check to see if the HTML file was succesfully downloaded
	if [ $? -ne 0 ]; then
		echo "Failed to download HTML file."
		# Append the failed URL to the variable
		failed_urls="$failed_urls $user_url"
		continue # Move to the next iteration of the loop


	else
		echo -e "Download completed. The file is saved in that folder '$folder_name2'."
		echo -e "with the name 'scalped.html'."
	fi

	echo -e "Filtering for URLs.. \n\n "
	echo '==============================================================================='


	# Uses grep to find the "src" attributes inside of the html file, then creates a .txt file
	grep -o 'src="[^"]*"' "$target_directory/$folder_name/$folder_name2/scalped.html" | cut -d '"' -f2 > "$target_directory/$folder_name/$folder_name2/tmp.txt"

	# Uses grep to find the "data-src" attributes inside of the html file, then appends to .txt file
	grep -o 'data-src="[^"]*"' "$target_directory/$folder_name/$folder_name2/scalped.html" | cut -d '"' -f2 >> "$target_directory/$folder_name/$folder_name2/tmp.txt"

	# Sorts the URLs in the temporary file and removes duplicates
	sort -u "$target_directory/$folder_name/$folder_name2/tmp.txt" -o "$target_directory/folder_name/$folder_name2/tmp.txt"

	# Moves the unique URLs from the tmp file to the final image URLs file
	mv "$target_directory/$folder_name/$folder_name2/tmp.txt" "$target_directory/$folder_name/$folder_name2/image_urls.txt"

	echo -e "Created text file with URLS in '$folder_name2' \n\n"
	echo '================================================================================'

	# Loop through all .txt files in $folder_name
	for file in "$target_directory/$folder_name/$folder_name2"/*_urls.txt; do
		if [ -e "$file" ]; then
			echo -e "enby_mage: Processing File $file ..."
			# Download URLS using wget
			wget -i "$file" -P "$target_directory/$folder_name/$folder_name2"
			echo -e "enby_mage: Finished processing $file. \n"
		fi
	done
	sleep 5
	# Create an array to store unique file types
	declare -a file_types

	# Loop through all downloaded files in the target directory
	for downloaded_file in "$target_directory/$folder_name/$folder_name2"/*; do
		if [ -e "$downloaded_file" ]; then
			# Get the file extenstion
			file_extension="${downloaded_file##*.}"

			# Check if the file type is already inside the array
			if [[ ! " ${file_types[@]} " =~ " ${file_extension} " ]]; then
				# If not, add it to the array and create a folder for the file type
				file_types+=("$file_extension")
				mkdir -p "$target_directory/$folder_name/$folder_name2/$file_extension"
			fi

			# Move the file to the corresponding folder
			mv "$downloaded_file" "$target_directory/$folder_name/$folder_name2/$file_extension"
		fi
	done

done < ./urls.txt

	# Removes any extra files and empty directories
	find "$target_directory/$folder_name" -type f ! -iname "*.mp4" ! -iname "*.jpg" ! -iname "*.jpeg" ! -iname '*.gif' -delete
	sleep 10
	find "$target_directory/$folder_name" -type d -empty -delete

# Output failed URLs at end of script
if [ -n "$failed_urls" ]; then
	echo "The following URLs have failed to download: "
	echo "$failed_urls"
else
	echo "All URLS were successfully downloaded!"
fi

end_time=$(date +%s)
elapsed_time=(( (start_time - end_time) / 60 ))
echo -e "Total clock time:		$total_time minutes"
echo -e '"The spell has been cast! :3"'

sleep 1
random_quote


