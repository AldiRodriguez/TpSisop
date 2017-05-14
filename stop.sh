#STOP

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


killDeamon(){

	# Busco ultomp PID utilizado
	lastPID=`grep PIDDEM $ARCHCONF | cut -d'=' -f2`

	# Valido que este activo el Ultimo PID
	statusProc=`ps ax | grep -c "^\s*$lastPID"` #&> /dev/null
	if [ $statusProc -eq 0 ]; then
		echo "false"
		exit
	fi
	
	# Demonio esta activo
	kill $lastPID
	echo "true"
}



##############################################################################

################################### MAIN ####################################


echo "-------------------------------------"
echo "RUN STOP"
echo "-------------------"

fueDetenido=$(killDeamon)
if [ "$fueDetenido" != "true" ]; then
	echo "Demonio no se esta ejecutando."
	WHEN=`date "+%Y/%m/%d %T"`
	WHO=$USER
	echo -e "$WHEN - $WHO - Start - Error - Demonio no fue posible detener, no se encuentra corriendo." >> $LOGFILE
	exit 1
fi
echo "Demonio Detenido."
WHEN=`date "+%Y/%m/%d %T"`
WHO=$USER
echo -e "$WHEN - $WHO - Start - Info - Demonio detenido." >> $LOGFILE

exit 0


##############################################################################

