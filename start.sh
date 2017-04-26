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

	statusInit=$(estaDeamonInicializado)
	if [ "$statusInit" == "false" ]; then
		echo "Ambiente no inicializado. No es posible ejecutar Start."
		# Sprint2: Enviar al log.
		echo "false"
		exit
	fi


	statDeamonStarted=$(estaDeamonIniciado)
	if [ "$statDeamonStarted" == "true" ]; then
		echo "Deamon ya esta Iniciado. No es posible ejecutar Start nuevamente."
		# Sprint2: Enviar al log.
		echo "false"
		exit
	fi

	echo "true"
}


estaDeamonInicializado(){

	if [ "$inicializado" ] ; then
	    echo "true"
	fi
	echo "false"
}


estaDeamonIniciado(){

	ps ax | grep startDemon | grep -v "grep" | grep -v "gedit" > /dev/null
	status=${?}

	if [ "${status}" = "0" ]; then
	    echo "true"
	else
	    echo "false"
	fi
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


echo "-------------------------------------"
echo "PRE CONDICIONES"
echo "-------------------"
statusPreCond=$(verificaPreCondStartDeamon)
if [ "$statusPreCond" != "true" ]; then
	echo "No cumple PRE CONDICIONES para iniciar Deamon."
	# Sprint2: Enviar al log.
	exit 1
fi
echo "Status: SUCESS"

echo "-------------------------------------"
echo "DEMON Backgraund"
echo "-------------------"

source $GRUPO$DIRBIN/demonio.sh &
#echo "Id de proceso del demonio: $!"
# Pegar el PID y pasar para archivo de metadata.






##############################################################################

