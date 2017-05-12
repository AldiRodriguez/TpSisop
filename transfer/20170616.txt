#!/bin/bash

function Logep {
	#Setea correctamente el directorio destino
	ruta="$DIRLOG"

	#Agrega la barra solo si hay una carpeta de destino distinta a la actual
	if [ ! -z "$ruta" ]
	then
		ruta="$ruta/"
	fi

	#Chequea que este la minima cantidad de parametros.
	if [ $# -lt 2 ]
	then
		echo "Sintaxis: logep comando mensaje [tipo de mensaje]"
		exit 1
	fi

	#Chequea si el parametro opcional es correcto.
	if [ ! -z $3 ]
	then
		case $3 in
		INFO|WAR|ERR)
		;;
		*)
			echo "Los tipos de mensaje validos son: INFO, WAR y ERR"
			exit 1
		;;
		esac
	fi

	echo "$(date +%d/%m/%Y-T%T)-$USER-$1-$3-$2" >> "$ruta$1.log" 

	#Trunca el log a la mitad del tamaño maximo permitido si lo supera
	tamanoArchivo=$(wc -c < "$ruta$1.log")
	cantidadLineas=$(wc -l < "$ruta$1.log")

	tamanoArchivo=$(($tamanoArchivo/1024))

	if [ $tamanoArchivo -ge $LOGSIZE ]
	then
		#Cuenta lineas hasta pasar la mitad del tamaño del archivo
		lineasASacar=0
		bytesLineas=0

		while read linea
		do
			bytesLineas=$(($bytesLineas+$(echo $linea | wc -c)))
		
			if [ $(($bytesLineas/1024)) -gt $(($LOGSIZE/2)) ]
			then
				break
			else
				lineasASacar=$(($lineasASacar+1))
			fi
		done < "$ruta$1.log"

		#Finalmente calcula la cantidad que deja en el log y saca las otras.
		lineasADejar=$(($cantidadLineas-$lineasASacar))
		aux=$(tail -$lineasADejar "$ruta$1.log")
		echo "$aux" > "$ruta$1.log" 
		echo "$(date +%d/%m/%Y-T%T)-$USER-Logep-INFO-Log Excedido" >> "$ruta$1.log"	
	fi
}
