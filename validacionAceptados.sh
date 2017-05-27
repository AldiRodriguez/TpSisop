
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


estaArchivoAceptCorrecto() {

	local archivoVerif="$1"
	local validado="true"
	# Parseo info del archivo
	Banco="$(echo $archivoVerif | cut -d'_' -f 1 )"
	fecha="$(echo $archivoVerif | cut -d'_' -f 2 | cut -d'.' -f 1)"
	outputDir="$GRUPO""transfer"
	outputFile="$outputDir""/$fecha"".txt"
	inputFile="$GRUPO$DIRACE/$archivoVerif"

	# -------------------------------------------------
	# Valido pre-condiciones a nivel de archivo
	# -------------------------------------------------

	# Valido que No se debe procesar más de una vez un mismo archivo
	if [ -f "$outputFile" ]; then
		resutltGrep="`grep -c "^$archivoVerif;.*" "$outputFile"`"

		if [ "$resutltGrep" -gt 0 ]; then 
		    	WHEN=`date "+%Y/%m/%d %T"`
		    	WHO=$USER
		    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, fue procesado previamente: $archivoVerif" >> $LOGFILE
			validado="false"
		fi
	fi


	# Se considera que un archivo es el mismo si posee el mismo filename

	# No se debe procesar un archivo si la cantidad de registros leídos es diferente a la cantidad total informada en el campo 1 del registro de cabecera
	cantRegTotal=`sed -n '1p' "$inputFile" | sed 's/^\([^;]*\);.*/\1/g'`
	cantReal=`wc -l < "$inputFile"`
	cantReal=`echo "$cantReal - 1" | bc`
	if [ ! "$cantReal" == "$cantRegTotal" ]; then
		WHEN=`date "+%Y/%m/%d %T"`
		    	WHO=$USER
		    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cantidad de campos inconcistente" >> $LOGFILE
			validado="false"
	fi

	# No se debe procesar un archivo si la sumatoria del campo importe es diferente a la monto total informado en el campo 2 del registro de cabecera
	importeTotal=`sed -n '1p' "$inputFile" | sed 's/^[^;]*;\(.*\)/\1/g'`
	importeSuma=0
	for line in $(tail -n +2 $inputFile ) ; do
		importe=`echo "$line" | sed 's/^[^;]*;\([^;]*\);.*/\1/g'`
		importeSuma=`echo "$importe + $importeSuma" | tr , . | bc`
	done
	if [ ! "$importeSuma" == "$importeTotal" ]; then
		WHEN=`date "+%Y/%m/%d %T"`
    	WHO=$USER
    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cantidad de campos inconcistente" >> $LOGFILE
		validado="false"
	fi

	# -------------------------------------------------
	# Valido pre-condiciones a nivel de registro
	# -------------------------------------------------
	OLDIFS=$IFS
	IFS=$'\r'
	for A in $(tail -n +2 $inputFile ) ; do

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


		#FALTA VALIDAR FECHA

		#CAMPO IMPORTE
		if [ ! "$IMPORTE" ]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, reg 2 no existe" >> $LOGFILE
			validado="false"
		fi
		if [[ "$ESTADO" == "Pendiente"  &&  "$IMPORTE" -lt "0" ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, importe <0 y estado pendiente" >> $LOGFILE
			validado="false"
		fi
		if [[ "$ESTADO" == "Anulada"  &&  "$IMPORTE" -gt "0" ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, importe <0 y estado pendiente" >> $LOGFILE
			validado="false"
		fi

		#CAMPO ESTADO
		if [[ "$ESTADO" != "Pendiente" && "$ESTADO" != "Anulada" ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, reg estado mal" >> $LOGFILE
			validado="false"
		fi

		#CAMPOS CBU
		if [[ "$CBU_ORIGEN" -eq "$CBU_DESTINO" ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cbu iguales" >> $LOGFILE
			validado="false"
		fi
		if [[ "${#CBU_ORIGEN}" -ne "22" ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cbu origen mal" >> $LOGFILE
			validado="false"
		fi
		if [[ "${#CBU_DESTINO}" -ne "22" ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cbu origen mal" >> $LOGFILE
			validado="false"
		fi

		#VALIDO QUE EXISTAN EN MAESTRO
		if [ ! "$ENTIDAD_ORIGEN" ]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, no existe ent origen" >> $LOGFILE
			validado="false"
		fi
		if [ ! "$ENTIDAD_DESTINO" ]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, no existe ent destino" >> $LOGFILE
			validado="false"
		fi
		# Guardo registro de salida en el archivo
		# Validar que el archivo sea texto (es Binario)
#		if [ ! `file "./$archivoVerif" | grep text` ]; then
#		    	WHEN=`date "+%Y/%m/%d %T"`
#		    	WHO=$USER
#		    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, no es regular de texto: $archivoVerif" >> $LOGFILE
#			echo "false"
#
#		# Validar que el archivo no este vacio
#		elif [ ! -s "$archivoVerif" ]; then
#		    	WHEN=`date "+%Y/%m/%d %T"`
#		    	WHO=$USER
#		    	echo -e "$WHEN - $WHO - Demonio - Error - Arhivo rechazado, esta vacio: $archivoVerif" >> $LOGFILE
#			echo "false"
	done
	IFS=$OLDIFS

	echo $validado
}




procesarAceptados() {

	local archivoVerif="$1"

	# Parseo info del archivo
	Banco="$(echo $archivoVerif | cut -d'_' -f 1 )"
	fecha="$(echo $archivoVerif | cut -d'_' -f 2 | cut -d'.' -f 1)"
	outputDir="$GRUPO""transfer"
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
			mkdir "$outputDir/listados"
			mkdir "$outputDir/balances"
			mkdir "$outputDir/rankings"
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
	procesadosDir="$GRUPO""procesados"
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
	estaCorrecto=$(estaArchivoAceptCorrecto "$archivo")

	# Segun el resultado de la validacion, muevo para Aceptados o Des.
	echo "-----------------"
	echo "EstaCorrecto: $estaCorrecto"	
	echo "-----------------"
	if [ "$estaCorrecto" == "true" ]; then
		echo "-- Proceso archivo --"
		resul=$(procesarAceptados "$archivo")
		if [ "$resul" == "true" ]; then
		    	WHEN=`date "+%Y/%m/%d %T"`
		    	WHO=$USER
		    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Info - Archivo rechazado por pre requisitos de validacion de aceptados: $archivoVerif" >> $LOGFILE
			moverArchivoProcesados $archivo
		else 
  		  	WHEN=`date "+%Y/%m/%d %T"`
    			WHO=$USER
    			echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Procesamiento invalido: $archivo" >> $LOGFILE	
			moverArchivoRejectado "$archivo"
		fi
	else 
		echo "-- Reject --"
		moverArchivoRejectado "$archivo"
	fi
done		
		


