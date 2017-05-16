#START

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

verificaPreCondStartDeamon(){

	statusInit=$(estaAmbienteInicializado)		
	if [ "$statusInit" == "false" ]; then
		echo "Ambiente no inicializado. No es posible ejecutar Start."
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Start - Error - Ambiente no inicializado. No es posible ejecutar Start." >> $LOGFILE

		echo "false"
		exit
	fi

	statDeamonStarted=$(estaDeamonIniciado)
	if [ "$statDeamonStarted" == "true" ]; then
		echo "Deamon ya esta Iniciado. No es posible ejecutar Start nuevamente." 
	    	WHEN=`date "+%Y/%m/%d %T"`
	    	WHO=$USER
	    	echo -e "$WHEN - $WHO - Start - Error - Deamon ya esta Iniciado. No es posible ejecutar Start nuevamente." >> $LOGFILE
		echo "false"
		exit
	fi
	
	echo "true"
}


estaAmbienteInicializado(){

	if [ "$inicializado" == "true" ] ; then
	    	echo "true"
		exit
	fi
	echo "false"
}


estaDeamonIniciado(){

	# Busco ultomp PID utilizado
	lastPID=`grep PIDDEM $ARCHCONF | cut -d'=' -f2`

	# Valido que este activo el Ultimo PID
	statusProc=`ps ax | grep -c "^\s*$lastPID"` #&> /dev/null
	if [ $statusProc -eq 0 ]; then
		echo "false"
		exit
	fi
	echo "true"
}

grabarPIDDemonio(){

	PID="$1"
	FECHA=`date "+%d/%m/%Y %H:%M"`
	USR="$USER"

	RECORD_NEW_PIDDEM="PIDDEM=$PID=$USR="

	# Actualizo PID
	sed -i "s/PIDDEM=[0-9].*/${RECORD_NEW_PIDDEM}/g" $ARCHCONF 

}


##############################################################################

################################### MAIN ####################################


echo "-------------------------------------"
echo "PRE CONDICIONES"
echo "-------------------------------------"
statPreCond=$(verificaPreCondStartDeamon)
if [ "$statPreCond" != "true" ]; then
	echo "    No cumple PRE CONDICIONES para iniciar Deamon. Leer Log para mas informacion"
	echo "$statPreCond"
    	WHEN=`date "+%Y/%m/%d %T"`
    	WHO=$USER
    	echo -e "$WHEN - $WHO - Start - Error - Start abortado. No cumple pre-condiciones." >> $LOGFILE
	exit 1
else
	echo "    Cumple pre condicions para inicio."
	echo "-------------------------------------"
	echo "DEMON Inicio Backgraund"
	echo "-------------------"
	#$GRUPO$DIRBIN/demonio.sh &
	./demonio.sh &

    	WHEN=`date "+%Y/%m/%d %T"`
    	WHO=$USER
    	echo -e "$WHEN - $WHO - Start - Ifo - Demonio Iniciado." >> $LOGFILE

	PID=$!
	grabarPIDDemonio $PID
fi



##############################################################################

