#!/bin/bash

while IFS= read -r line; do
	# Generate a random number between 1 and 1000
	dice_roll=$(( (RANDOM % 1000) + 1 ))

	# Checks if the line number matches the generated random number
	if [[ $line =~ ^$dice_roll\. ]]; then
		# Extract the quote from the line ( remove line number and leading space ).
		quote="${line#*. }"

		# Print the quote
		echo "$quote"

		# Exit the loop after printing the quote
		break
	fi
done < ./famous_quotes.txt
