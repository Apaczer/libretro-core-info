#!/bin/bash

SEARCH_DIR="${1:-.}" # first arg or CWD

find "$SEARCH_DIR" -type f | while read -r file; do
    core_supports_no_game=$(sed -n 's:^supports_no_game = ::p' "$file" 2>/dev/null | tr -d '"')
	core_supported_extensions=$(sed -n 's:^supported_extensions = ::p' "$file" 2>/dev/null | tr -d '"')
	core_single_purpose=$(sed -n 's:^single_purpose = ::p' "$file" 2>/dev/null | tr -d '"')

    if [[ "$core_supports_no_game" == "false" ]] || [[ "$core_supported_extensions" != "" ]] && [[ "$core_single_purpose" != "true" ]]; then
        if grep -oq "systemid =" $file; then
			if ! grep -oq "gamedir =" $file; then
				echo -e "\nWARNING: No \"gamedir =\" for core requiring content in: $file"
				core_systemid="$(sed -n 's:^systemid = ::p' "${file}" | tr -d '"')"
				echo -e "\nCreated -> gamedir = \"${core_systemid}\""
				echo -e "\ngamedir = \"${core_systemid}\"" >> $file
				core_systemid=""
			#else
				#echo "Found gamedir in: $file"
			fi
		else
			echo -e "\nERROR: no \"systemid =\" with req. content in $file"
		fi
    fi
done
