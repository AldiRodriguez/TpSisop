
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

	OLDIFS=$IFS
	IFS=$'\r'
	echo "Arhcivo verif $archivoVerif" 
	for A in $(cat $archivoVerif ) ; do
          echo "-------------------------"
	  echo $A 

	done
	IFS=$OLDIFS

	echo "true"
#
 #   	WHEN=`date "+%Y/%m/%d %T"`
#    	WHO=$USER
#    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Info - Poner motivo Acept/reject" >> $LOGFILE

}

moverArchivoRejectado(){

	archivoMov="$1"
	# Valido duplicados (preciso un numero sequancial para incrementar)

	# Muevo
	mv "$GRUPO$DIRACE/$archivoMov" "$GRUPO$DIRREJ" 

    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Archivo movido a carpeta de Rechazados" >> $LOGFILE
}


moverArchivoRejectado(){

	archivoMov="$1"
	# Valido duplicados (preciso un numero sequancial para incrementar)

	# Muevo
	mv "$GRUPO$DIRACE/$archivoMov" "$GRUPO$DIRREJ" 

    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Error - Archivo movido a carpeta de Rechazados" >> $LOGFILE
}

editFileToUnixEOF(){

	archivoToEdit="$1"
	#sed -i -e 's/\r\+$//' "$GRUPO$DIRACE/$archivoToEdit"  
	sed -i "s/\r$//" "$GRUPO$DIRACE/$archivoToEdit" 
}





##############################################################################

################################### MAIN ####################################

#echo "HOLA MUNDO. Sleep 20"
#sleep 6


# -----------------------------------------------------
# Valido cada novedad aceptada
# -----------------------------------------------------
for archivo in $( ls "$GRUPO$DIRACE")
do	
	echo "-----------------"
	echo "Proceso novedad aceptada: $archivo"		
    	WHEN=`date "+%Y/%m/%d %T"`
    	WHO=$USER
    	echo -e "$WHEN - $WHO - Procesamiento de aceptados - Info - Archivo con novedad aceptada detectado: $archivo" >> $LOGFILE

	# Verifico el archivo de  Novedad	
	estaArchivoAceptCorrecto=$(estaCorrectoArchivoNovedadAceptada "$GRUPO$DIRACE/$archivo")

	# Segun el resultado de la validacion, muevo para Aceptados o Des.
	if [ "$estaArchivoAceptCorrecto" == "true" ]; then
		echo "-- Proceso archivo --"
		procesarAceptados "$GRUPO$DIRACE/$archivo"
		#editFileToUnixEOF $archivo
	else 
		echo "-- Reject --"
		moverArchivoRejectado "$GRUPO$DIRACE/$archivo"
	fi
done		
		

