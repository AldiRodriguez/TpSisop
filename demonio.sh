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

	cd "$GRUPO$DIRNOV"

	# Validar que el archivo sea texto (es Binario)
	if [ ! `file "./$archivoVerif" | grep text` ]; then
		#echo "Archivo Novedad Rejected. No es archivo de texto." 
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, no es regular de texto: $archivoVerif" >> $LOGFILE
		echo "false"

	# Validar que el archivo no este vacio
	elif [ ! -s "$archivoVerif" ]; then
		#echo "Archivo Novedad Rejected. Archivo vacio."
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, esta vacio: $archivoVerif" >> $LOGFILE
		echo "false"

	# Validar formato del nombre del archivo (entidad_fecha). 
	elif [ `echo "$archivoVerif" | sed 's-^[^_]*_[0-9]\{8,\}.csv-true-'` != "true" ]; then
		#echo "Archivo Novedad Rejected. Archivo con convencion de nombre incorrecto."
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, convencion de nombre incorrecto: $archivoVerif" >> $LOGFILE
		echo "false"
	
	# Valido que sea una fecha valida (este en el calendario ). 


	# Valido que sea una fecha con antiguedad no superior a 15 dias. 


	# Valido que esta en el archivo maestro de entidades bancarias. 
	elif [ "`grep -c "^${Banco};" "$GRUPO$DIRMA/maestro.csv"`" -eq "0" ]; then 
		echo "Archivo Novedad Rejected. Entidad no existe en el maestro." 
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, Entidad no existe en el maestro: $archivoVerif" >> $LOGFILE
		echo "false"
	else
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Demonio - Info - Arhivo Aceptado: $archivoVerif" >> $LOGFILE
		#echo "Entidad ${Banco} - Dia: ${fecha}. Original: -------$archivoVerif---- "
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

