#!/bin/bash
function val_nom {
	res=1
	validate_number=^[0-9]+$
	IFS='_' read -r -a array <<< "$1"
	NAME=${array[3]%.*}
	EXTENSION=${array[3]##*.}
	date "+%Y%m%d" -d "$NAME" > /dev/null 2>&1
	DATE=$?

	if [ ${#array[@]} -ne 4 ]
	then
		let res=0
	elif [ "${array[0]}" != "ejecutado" ]
	then
		let res=0
	elif ! [[ ${array[1]} =~ $validate_number ]]
	then
		let res=0
	elif ! [[ ${array[2]} =~ $validate_number ]]
	then
		let res=0
	elif [ $DATE -eq 1 ]
	then
		let res=0
	elif [ "$EXTENSION" != "csv" ]
	then
		let res=0
	fi
	echo "$res"
}
