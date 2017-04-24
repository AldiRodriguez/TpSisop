#INICIALIZADOR

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
crearArchivoDeLog(){

if [ ! -f "$LOGFILE" ]; then
    touch $LOGFILE
    if [ ! -f "$LOGFILE" ]; then
        echo "No existe $LOGFILE y no se puede generar"
        exit
    fi
fi

}

setearAmbiente(){

	#seteo variables de ambiente leyendo el archivo de configuracion
	export DIRBIN=`grep DIRBIN $ARCHCONF | cut -d'/' -f5`
	export DIRMA=`grep DIRMA $ARCHCONF | cut -d'/' -f5`
	export DIRNOV=`grep DIRNOV $ARCHCONF | cut -d'/' -f5`
	export DIRACE=`grep DIRACE $ARCHCONF | cut -d '/' -f5`
	export DIRREJ=`grep DIRREJ $ARCHCONF | cut -d'/' -f5`
	export DIRVAL=`grep DIRVAL $ARCHCONF | cut -d'/' -f5`
	export DIRREP=`grep DIRREP $ARCHCONF | cut -d'/' -f5`
	export DIRLOG=`grep DIRLOG $ARCHCONF | cut -d'/' -f5`

}

detectarExistenciaArchivos(){
  cd "$GRUPO"
	archivosBin=("inicializador" "demonio")
  for archivo in ${archivosBin[@]} ; do
   	if [ `ls -l $DIRBIN | grep $archivo -c` -ne 1 ]; then
   	 	echo "Falta $archivo "
      WHEN=`date "+%Y/%m/%d %T"`
      WHO=$USER
      echo -e "$WHEN - $WHO - inicializador - Error- Falta $archivo" >> $LOGFILE
      exit 1
    fi
  done

	archivo_maestro=("maestro.csv")
  if [ `ls -l $DIRMA | grep $archivo_maestro -c` -ne 1 ]; then
    echo "Falta $archivo_maestro "
    WHEN=`date "+%Y/%m/%d %T"`
    WHO=$USER
    echo -e "$WHEN - $WHO - inicializador - Error- Falta $archivo_maestro" >> $LOGFILE
    exit 1
  fi

  archivosNov=("nov1.csv" "nov2.csv")
  for file in ${archivosNov[@]} ; do
    if [ `ls -l $DIRNOV | grep $file -c` -ne 1 ]; then
      echo "Falta $file"
      WHEN=`date "+%Y/%m/%d %T"`
      WHO=$USER
      echo -e "$WHEN - $WHO - inicializador - Error- Falta $file" >> $LOGFILE
      exit 1
    fi
  done

  archivo_log_inic=("ini.log")
  if [ `ls -l $DIRLOG | grep $archivo_log_inic -c` -ne 1 ]; then
    echo "Falta $archivo_log_inic "
    WHEN=`date "+%Y/%m/%d %T"`
    WHO=$USER
    echo -e "$WHEN - $WHO - inicializador - Error- Falta $archivo_log_inic" >> $LOGFILE
    exit 1
  fi
}

verificarPermisos(){

 	ejecutables=("$DIRBIN/inicializador" "$DIRBBIN/demonio")
	for arch in ${ejecutables[@]} ; do
   		 if [ ! -x "$arch" ] || [ ! -r "$arch" ] ; then
      		chmod +xr "$arch"
       		if [ ! -x "$arch" ] || [ ! -r "$arch" ] ; then
            	echo "No se puede cambiar los permisos de $arch."
              WHEN=`date "+%Y/%m/%d %T"`
              WHO=$USER
              echo -e "$WHEN - $WHO - inicializador - Error - No se puede cambiar los permisos del archivo $arch" >> $LOGFILE
           		return 1
        	fi
          WHEN=`date "+%Y/%m/%d %T"`
          WHO=$USER
          echo -e "$WHEN - $WHO - inicializador - Info - Seteados correctamente los permisos del archivo $arch" >> $LOGFILE
    	fi
	done

	maestro=("$DIRMA/maestro.csv")

	if [ ! -r "$archivo_maestro" ] ; then
   		chmod +r "$archivo_maestro"
    	if [ ! -r "$archivo_maestro" ] ; then
            echo "No se puede cambiar los permisos de $archivo_maestro."
            WHEN=`date "+%Y/%m/%d %T"`
            WHO=$USER
            echo -e "$WHEN - $WHO - inicializador - Error - No se puede cambiar los permisos del archivo $archivo_maestro" >> $LOGFILE
            return 1
    	fi
      WHEN=`date "+%Y/%m/%d %T"`
      WHO=$USER
      echo -e "$WHEN - $WHO - inicializador - Info - Seteados correctamente los permisos del archivo $archivo_maestro" >> $LOGFILE
    fi
}

elegirOpcion(){
	option=""
	while [ "$option" != "Si" ] ; do
   		echo -n "Activar Demonio Si-No: "
    	read option
      WHEN=`date "+%Y/%m/%d %T"`
      WHO=$USER
      echo -e "$WHEN - $WHO - inicializador - Info - ¿Desea efectuar la activación de Demonep? Si – No: $option" >> $LOGFILE
    	if [ "$option" == "No" ] ; then
        	echo "Para ejecutar el demonio Demonio puede ejecutar el siguiente comando: ./demonios.sh &"
       		return 0
    	fi
    	if [ -z "$option" ] ; then
       		option="Si" 
   		fi
	done
	
  chmod +xr "$DIRBIN/demonio.sh"
	$DIRBIN/demonio.sh &
	echo "Id de proceso del demonio: $!"
  WHEN=`date "+%Y/%m/%d %T"`
  WHO=$USER
  echo -e "$WHEN - $WHO - inicializador - Info - Id de proceso del demonio: $!" >> $LOGFILE
}

##############################################################################

################################### MAIN ####################################
crearArchivoDeLog

if [ "$inicializado" ] ; then
    echo "ya se inicializo el ambiente."
    WHEN=`date "+%Y/%m/%d %T"`
    WHO=$USER
    echo -e "$WHEN - $WHO - inicializador - Alerta - El ambiente ya fue inicializado" >> $LOGFILE
    exit 0
fi

if [ -e "$ARCHCONF" ]; then
	setearAmbiente
else
	echo "EL SISTEMA NO ESTA INSTALADO"
	echo "Por favor, instalarlo de la siguiente manera:"
	echo "./instalador.sh  -i"

  WHEN=`date "+%Y/%m/%d %T"`
  WHO=$USER
  echo -e "$WHEN - $WHO - inicializador - Alerta -EL SISTEMA NO ESTA INSTALADO.Por favor, instalarlo de la siguiente manera: ./instalador.sh  -i" >> $LOGFILE
	exit 0
fi

detectarExistenciaArchivos
verificarPermisos
export inicializado=$true
echo "Ha finalizado la inicializacion"
WHEN=`date "+%Y/%m/%d %T"`
WHO=$USER
echo -e "$WHEN - $WHO - inicializador - Info - Ha finalizado la inicializacion" >> $LOGFILE
elegirOpcion

#############################################################################
