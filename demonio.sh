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


Loop() {
	cicle=1
	pid=0
	seguir=1
	corte=1000
	
	while [ $cicle > $corte ];
	do
		
		echo "--------------------"
		echo "Ciclo: $cicle"
		echo "--------------------"
		IFS='
		'

		# Detecto si existe novedad y proceso Validacion & Mov
		for archivo in $( ls "$GRUPO$DIRNOV")
		do	
			echo "-------------------------"	
			echo "Nombre archivo: $archivo"		
			echo "-------------------------"
			# Verifico el archivo de Novedad	
			
			statusArchivoNovCorrecto=$(estaCorrectoArchivoNovedad $archivo)

			# Segun el resultado de la validacion, muevo para Aceptados o Des.
			if [ $statusArchivoNovCorrecto == "true" ]; then
				moverArchivoAceptado $archivo
			else 
				moverArchivoRejectado $archivo
			fi

			# Sprint2: log de novedad identificada
		done			
		
		# Duracion Ciclo
		sleep 15

		# Incremento de Ciclo
		cicle=$(( cicle + 1 ))
		# Sprint2: Log ciclo.
	done
}


estaCorrectoArchivoNovedad() {

	local archivoVerif=$1
	
	cd "$GRUPO$DIRNOV"

	# Validar que el archivo sea texto (es Binario)
	if [ ! `file "./$archivoVerif" | grep text` ]; then
		#echo "Archivo Novedad Rejected. No es archivo de texto." 
		echo "false"
		#Sprint2: Log.

	# Validar que el archivo no este vacio
	elif [ ! -s "$archivoVerif" ]; then
		#echo "Archivo Novedad Rejected. Archivo vacio."
		echo "false"
		#Sprint2: Log.
	

	# Validar formato del nombre del archivo (entidad_fecha). #fecha=$(echo "$archivo" | cut -d_ -f4 | cut -d. -f1)
	elif [ `echo "$archivoVerif" | sed 's-^[^_]*_[0-9]\{8,\}.csv-true-'` != "true" ]; then
		#echo "Archivo Novedad Rejected. Archivo vacio."
		echo "false"
		#Sprint2: Log.
	
	# Valido que sea una fecha valida (este en el calendario ). 


	# Valido que esta en el archivo maestro de entidades bancarias. 

	else
		echo "true"
	fi
}


moverArchivoRejectado(){

	archivoMov="$1"
	# Valido duplicados (preciso un numero sequancial para incrementar)

	# Muevo
	mv "$GRUPO$DIRNOV/$archivoMov" "$GRUPO$DIRREJ" 
	echo "Archivo $archivo rejectado"
	#Sprint2: log Archivo rechazao
}


moverArchivoAceptado(){

	archivoMov="$1"

	# Valido duplicados (preciso un numero sequancial para incrementar)

	# Muevo
	mv "$GRUPO$DIRNOV/$archivoMov" "$GRUPO$DIRACE"  
	echo "Archivo $archivo Aceptado"
	#Sprint2: log Archivo rechazao
}


setearAmbiente(){

	#seteo variables de ambiente leyendo el archivo de configuracion
	export DIRBIN=`grep DIRBIN $ARCHCONF | cut -d'/' -f7`
	export DIRMA=`grep DIRMA $ARCHCONF | cut -d'/' -f7`
	export DIRNOV=`grep DIRNOV $ARCHCONF | cut -d'/' -f7`
	export DIRACE=`grep DIRACE $ARCHCONF | cut -d '/' -f7`
	export DIRACE=`grep DIRACE $ARCHCONF | cut -d '/' -f7`	
	export DIRREJ=`grep DIRREJ $ARCHCONF | cut -d'/' -f7`
	export DIRVAL=`grep DIRVAL $ARCHCONF | cut -d'/' -f7`
	export DIRREP=`grep DIRREP $ARCHCONF | cut -d'/' -f7`
	export DIRLOG=`grep DIRLOG $ARCHCONF | cut -d'/' -f7`
	export inicializado="true"
}


##############################################################################

################################### MAIN ####################################


setearAmbiente

echo $DIRBIN


echo "-------------------------------------"
echo "DEMON Iniciado"
echo "-------------------------------------"

Loop 



##############################################################################

