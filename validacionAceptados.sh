
#Validador aceptados

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


estaCorrectoArchivoNovedadAceptada() {

	local archivoVerif="$1"

	echo "true"
#
 #   	WHEN=`date "+%Y/%m/%d %T"`
#    	WHO=$USER
#    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Info - Poner motivo Acept/reject" >> $LOGFILE

}


procesarAceptados() {

	local archivoVerif="$1"

	# Parseo info del archivo
	Banco="$(echo $archivoVerif | cut -d'_' -f 1 )"
	fecha="$(echo $archivoVerif | cut -d'_' -f 2 | cut -d'.' -f 1)"
	outputDir="$GRUPO""Transfer"
	outputFile="$outputDir""/$fecha"".txt"
	inputFile="$GRUPO$DIRACE/$archivoVerif"

#	echo "-----------------"
#	echo "Archivo: $archivoVerif "
#	echo "Entidad: $Banco"
#	echo "Fecha: $fecha"
#	echo "OutputFile: $outputFile"
#	echo "Input FIle: $inputFile"
#	echo "-----------------"

	# Valido que exista el archivo donde guardar los registros, caso contrario lo creo
	if [ ! -f "$outputFile" ]; then
		if [ ! -d $outputDir ]; then 
			mkdir $outputDir
		fi
		touch $outputFile
    		if [ ! -f "$outputFile" ]; then
			echo "No existe $outputFile y no se puede generar"
		    	WHEN=`date "+%Y/%m/%d %T"`
		    	WHO=$USER
		    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Archivo de salida $outputFile no existe y no puede ser creado." >> $LOGFILE
			echo "false"
			exit
		else
		    	WHEN=`date "+%Y/%m/%d %T"`
		    	WHO=$USER
		    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Info - Archivo de salida $fecha.txt creado".  >> $LOGFILE 
		fi	
	fi

	# Recorro cada registro del archivo
	OLDIFS=$IFS
	IFS=$'\r'
	for A in $(cat $inputFile ) ; do
#		echo "------Registro-------------------"
#		echo "$A"
#		echo "---------------------------------"
		FECHA_TRANS="$(echo $A | cut -d';' -f 1 )"
		IMPORTE="$(echo $A | cut -d';' -f 2 )"
		ESTADO="$(echo $A | cut -d';' -f 3 )"

		CBU_ORIGEN="$(echo $A | cut -d';' -f 4 )"
		CODIGO_ENTIDAD_ORIGEN=$(echo $CBU_ORIGEN | cut -c1-3)
		ENTIDAD_ORIGEN=$(grep "^.*;$CODIGO_ENTIDAD_ORIGEN;.*" "$GRUPO$DIRMA/maestro.csv") 
		ENTIDAD_ORIGEN="$(echo $ENTIDAD_ORIGEN | cut -d';' -f 1 )"

		CBU_DESTINO="$(echo $A | cut -d';' -f 5 )"
		CODIGO_ENTIDAD_DESTINO=$(echo $CBU_DESTINO | cut -c1-3)
		ENTIDAD_DESTINO=$(grep "^.*;$CODIGO_ENTIDAD_DESTINO;.*" "$GRUPO$DIRMA/maestro.csv") 
		ENTIDAD_DESTINO="$(echo $ENTIDAD_DESTINO | cut -d';' -f 1 )"

#		echo "-----------------"
#		echo "FECHA: $FECHA_TRANS "
#		echo "IMPORTE: $IMPORTE"
#		echo "ESTADO: $ESTADO"
#
#		echo "CBU_ORIGEN: $CBU_ORIGEN"
#		echo "CODIGO_ENTIDAD_ORIGEN: $CODIGO_ENTIDAD_ORIGEN"
#		echo "ENTIDAD_ORIGEN: $ENTIDAD_ORIGEN"
#
#		echo "CBU_DESTINO: $CBU_DESTINO"
#		echo "CODIGO_ENTIDAD_DESTINO: $CODIGO_ENTIDAD_DESTINO"
#		echo "ENTIDAD_DESTINO: $ENTIDAD_DESTINO"
#		echo "-----------------"

		# Guardo registro de salida en el archivo
		echo "$archivoVerif;$ENTIDAD_ORIGEN;$CODIGO_ENTIDAD_ORIGEN;$ENTIDAD_DESTINO;$CODIGO_ENTIDAD_DESTINO;$FECHA_TRANS;$IMPORTE;$ESTADO;$CBU_ORIGEN;$CBU_DESTINO" >> "$outputFile"

	done
	IFS=$OLDIFS

    	WHEN=`date "+%Y/%m/%d %T"`
    	WHO=$USER
    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Info - Archivo aceptada procesado: $archivoVerif" >> $LOGFILE

	echo "true"
}


moverArchivoRejectado(){

	archivoMov="$1"
	# Valido duplicados (preciso un numero sequancial para incrementar)

	# Muevo
	mv "$GRUPO$DIRACE/$archivoMov" "$GRUPO$DIRREJ" 

    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Archivo movido a carpeta de Rechazados" >> $LOGFILE
}


moverArchivoProcesados(){

	archivoMov="$1"

	# Valido que exista el dir de procesados
	procesadosDir="$GRUPO""Procesados"
	if [ ! -d $procesadosDir ]; then 
		mkdir $procesadosDir
	fi

	# Valido duplicados (preciso un numero sequancial para incrementar)

	# Muevo
	mv "$GRUPO$DIRACE/$archivoMov" "$procesadosDir" 

    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Info - Archivo movido a carpeta de procesados" >> $LOGFILE
}

editFileToUnixEOF(){

	archivoToEdit="$1"
	#sed -i -e 's/\r\+$//' "$GRUPO$DIRACE/$archivoToEdit"  
	sed -i "s/\r$//" "$GRUPO$DIRACE/$archivoToEdit" 
}





##############################################################################

################################### MAIN ####################################


# -----------------------------------------------------
# Valido cada novedad aceptada
# -----------------------------------------------------
echo "$GRUPO$DIRACE"
for archivo in $( ls "$GRUPO$DIRACE")
do	
	echo "-----------------"
	echo "Proceso novedad aceptada: $archivo"		
    	WHEN=`date "+%Y/%m/%d %T"`
    	WHO=$USER
    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Info - Archivo aceptada detectado: $archivo" >> $LOGFILE


	# Verifico el archivo de  Novedad	
	estaArchivoAceptCorrecto=$(estaCorrectoArchivoNovedadAceptada "$archivo")

	# Segun el resultado de la validacion, muevo para Aceptados o Des.
	if [ "$estaArchivoAceptCorrecto" == "true" ]; then
		echo "-- Proceso archivo --"
		resul= $(procesarAceptados "$archivo")
		if [ "$estaArchivoAceptCorrecto" == "true" ]; then
			moverArchivoProcesados $archivo
		else 
  		  	WHEN=`date "+%Y/%m/%d %T"`
    			WHO=$USER
    			echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Procesamiento invalido: $archivo" >> $LOGFILE			
		fi
	else 
		echo "-- Reject --"
		moverArchivoRejectado "$archivo"
	fi
done		
		


