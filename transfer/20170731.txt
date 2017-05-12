#!/bin/bash
function val_prov {
	code=$1
	RUTA=$2
	IFS=$';'
	result=0
	while read col1 col2 col3
	do
    #echo "I got: $col1"
		if [ "$col1" == "$1" ]
		then
			let result=1
		fi
	done < "$RUTA/provincias.csv"
	echo $result
}

