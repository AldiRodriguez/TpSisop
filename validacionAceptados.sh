
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
	#cantRegTotal=`sed -n '1p' "$inputFile" | sed 's/^\([^;]*\);.*/\1/g'`
	#cantReal=`wc -l < "$inputFile"`
	#cantReal=`echo "$cantReal - 1" | bc`
	#if [ ! "$cantReal" == "$cantRegTotal" ]; then
	#	WHEN=`date "+%Y/%m/%d %T"`
	#	    	WHO=$USER
	#	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cantidad de campos inconsistente" >> $LOGFILE
	#		validado="true"
	#fi

	## No se debe procesar un archivo si la sumatoria del campo importe es diferente a la monto total informado en el campo 2 del registro de cabecera
	#importeTotal=`sed -n '1p' "$inputFile" | sed 's/^[^;]*;\(.*\)/\1/g'`
	#importeSuma=0
	#for line in $(tail -n +2 $inputFile ) ; do
	#	importe=`echo "$line" | sed 's/^[^;]*;\([^;]*\);.*/\1/g'`
	#	importeSuma=`echo "$importe + $importeSuma" | tr , . | bc`
	#done
	#if [ ! "$importeSuma" == "$importeTotal" ]; then
	#	WHEN=`date "+%Y/%m/%d %T"`
    #	WHO=$USER
    #	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cantidad de campos inconsistente" >> $LOGFILE
	#	validado="true"
	#fi

	# -------------------------------------------------
	# Valido pre-condiciones a nivel de registro
	# -------------------------------------------------
	OLDIFS=$IFS
	IFS=$'\r'
	for A in $(cat $inputFile); do

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
		date "+%Y%m%d" -d $FECHA_TRANS > /dev/null  2>&1
		resultValData="$?"

		#Valido fecha calendario
		if [ $resultValData -ne 0 ]; then
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, fecha: $FECHA_TRANS de archivo fuera de calendario" >> $LOGFILE
			validado="false"
		#CAMPO IMPORTE
		elif [ ! "$IMPORTE" ]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, reg 2 no existe" >> $LOGFILE
			validado="false"
		
		elif [[ "$ESTADO" == "Pendiente"  &&  ! $(echo "$IMPORTE" | sed 's/^-.*//')  ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, importe <0 y estado pendiente" >> $LOGFILE
			validado="false"
		
		elif [[ "$ESTADO" == "Anulada"  &&  ! $(echo "$IMPORTE" | sed 's/^[^-]*//') ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, importe >0 y estado anulada" >> $LOGFILE
			validado="false"
		

		#CAMPO ESTADO
		elif [[ "$ESTADO" != "Pendiente" && "$ESTADO" != "Anulada" ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, reg estado mal" >> $LOGFILE
			validado="false"
		

		#CAMPOS CBU
		elif [[ ${CBU_ORIGEN#0} -eq ${CBU_DESTINO#0} ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cbu iguales" >> $LOGFILE
			validado="false"
		
		elif [[ "${#CBU_ORIGEN}" -ne "22" ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cbu origen mal" >> $LOGFILE
			validado="false"
		
		elif [[ "${#CBU_DESTINO}" -ne "22" ]]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, cbu origen mal" >> $LOGFILE
			validado="false"
		

		#VALIDO QUE EXISTAN EN MAESTRO
		elif [ ! "$ENTIDAD_ORIGEN" ]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, no existe ent origen" >> $LOGFILE
			validado="false"
		
		elif [ ! "$ENTIDAD_DESTINO" ]; then
			WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Arhivo rechazado, no existe ent destino" >> $LOGFILE
			validado="false"
		fi

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
		


