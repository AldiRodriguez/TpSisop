#DEMONIO

############################## CONSTANTES ###################################

#Declaro el PATH donde se debe trabajar SIEMPRE
GRUPO=`pwd`"/Grupo01/"

#Declaro subdirectorio dirconf (RESERVADO)
DIRCONF="$GRUPO""dirconf/"

#PATH al archivo de config
ARCHCONF="$DIRCONF""arch.conf"

#Declaro subdirectorio DIRLOG
DIRLOG="$GRUPO""log/"

#archivo de log
LOGFILE="$DIRLOG/ini.log"



##############################################################################

############################# PROCEDIMIENTOS #################################




estaCorrectoArchivoNovedad() {

	local archivoVerif="$1"
	Banco="$(echo $archivoVerif | cut -d'_' -f 1 )"
	fecha="$(echo $archivoVerif | cut -d'_' -f 2 | cut -d'.' -f 1)"
	fechaFormatReqFuncDate=$(echo $fecha | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\2\/\3\/\1/')
	fechaHoy=$(date "+%Y%m%d")
	date "+%m/%d/%Y" -d $fechaFormatReqFuncDate > /dev/null  2>&1
	resultValData="$?"

	
	cd "$GRUPO$DIRNOV"

	# Validar que el archivo sea texto (es Binario)
	if [ ! `file "./$archivoVerif" | grep text` ]; then
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, no es regular de texto: $archivoVerif" >> $LOGFILE
		echo "false"

	# Validar que el archivo no este vacio
	elif [ ! -s "$archivoVerif" ]; then
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, esta vacio: $archivoVerif" >> $LOGFILE
		echo "false"

	# Validar formato del nombre del archivo (entidad_fecha). 
	elif [ `echo "$archivoVerif" | sed 's-^[^_]*_[0-9]\{8,\}.csv-true-'` != "true" ]; then
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, convencion de nombre incorrecto: $archivoVerif" >> $LOGFILE
		echo "false"
	
	# Valido que sea una fecha valida (este en el calendario ). Convierto de formato de aaaammdd a mm/dd/aaaa para poder validar con date 
	elif [ $resultValData -ne 0 ]; then
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, fecha de archivo fuera de calendario: $archivoVerif" >> $LOGFILE
		echo "false"

	# Valido que sea una fecha con antiguedad no superior a 15 dias. 
	elif [ "$(( ($(date --date "$fechaHoy" +%s) -$(date --date "$fecha" +%s)  )/(60*60*24) ))" -gt 15 ]; then
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, fecha mayor a 15 dias de antiguedad: $archivoVerif." >> $LOGFILE
		echo "false"

	# Valido que sea una fecha superior a la actual. 
	elif [ "$(( ($(date --date "$fechaHoy" +%s) -$(date --date "$fecha" +%s)  )/(60*60*24) ))" -lt 0 ]; then
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, fecha superior al dia de hoy: $archivoVerif." >> $LOGFILE
		echo "false"

	# Valido que esta en el archivo maestro de entidades bancarias. 
	elif [ "`grep -c "^${Banco};" "$GRUPO$DIRMA/maestro.csv"`" -eq "0" ]; then 
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, Entidad no existe en el maestro: $archivoVerif" >> $LOGFILE
		echo "false"
	else
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Info - Arhivo Aceptado: $archivoVerif" >> $LOGFILE
		echo "true"
	fi
}


moverArchivoRejectado(){

	archivoMov="$1"
	# Valido duplicados (preciso un numero sequancial para incrementar)

	# Muevo
	mv "$GRUPO$DIRNOV/$archivoMov" "$GRUPO$DIRREJ" 

    	echo -e "$WHEN - $WHO - Demonio - Info - Archivo moviod a carpeta de Rechazados" >> $LOGFILE
}


moverArchivoAceptado(){

	archivoMov="$1"

	# Valido duplicados (preciso un numero sequancial para incrementar)

	# Muevo
	mv "$GRUPO$DIRNOV/$archivoMov" "$GRUPO$DIRACE"  

    	WHEN=`date "+%Y/%m/%d %T"`
    	WHO=$USER
    	echo -e "$WHEN - $WHO - Demonio - Info - Archivo moviod a carpeta de aceptados" >> $LOGFILE
}



##############################################################################

################################### MAIN ####################################

echo "-------------------------------------"
echo "DEMON Iniciado"
echo "-------------------------------------"

cicle=1
pid=0
seguir=1
corte=1000
	
while [ $cicle > $corte ];
do
		
	echo "--------------------"
	echo "Ciclo: $cicle"
	echo "--------------------"
    	WHEN=`date "+%Y/%m/%d %T"`
    	WHO=$USER
    	echo -e "$WHEN - $WHO - Demonio - Info - Inicio Cilclo: $cicle" >> $LOGFILE

	IFS='
	'
	# Detecto si existe novedad y proceso Validacion & Mov
	for archivo in $( ls "$GRUPO$DIRNOV")
	do	
		echo "-------------------------"	
		echo "Nombre archivo: $archivo"		
		echo "-------------------------"
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Info - Archivo leido: $archivo" >> $LOGFILE

		# Verifico el archivo de  Novedad	
		statusArchivoNovCorrecto=$(estaCorrectoArchivoNovedad $archivo)

		# Segun el resultado de la validacion, muevo para Aceptados o Des.
		if [ "$statusArchivoNovCorrecto" == "true" ]; then
			echo "-- Aceptado --"
			moverArchivoAceptado $archivo
		else 
			echo "-- Reject --"
			moverArchivoRejectado $archivo
		fi
	done			
		
	# Duracion Ciclo
	sleep 5

	# Incremento de Ciclo
	cicle=$(( cicle + 1 ))

done



##############################################################################

