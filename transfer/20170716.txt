#!/bin/bash
function val_fecha {
	fecha_actual=`date +%s`
	year=`date +%Y`
	fecha_inicio=`date -d "${year}0101" +"%s"`
	fecha=$(date -d $1 +"%s")
	
	if [ $fecha -le $fecha_actual ] && [ $fecha -ge $fecha_inicio ]
	then
		echo 1
	else
		echo 0
	fi
}
