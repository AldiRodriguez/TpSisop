#INICIALIZADOR

############################## CONSTANTES ###################################

#Declaro el PATH donde se debe trabajar SIEMPRE
GRUPO=`pwd`"/Grupo01/"

#Declaro subdirectorio dirconf (RESERVADO)
DIRCONF="$GRUPO""dirconf/"

#PATH al archivo de config
ARCHCONF="$DIRCONF""arch.conf"

##############################################################################

############################# PROCEDIMIENTOS #################################
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
      exit 1
    fi
  done

	archivo_maestro=("maestro.csv")
  if [ `ls -l $DIRMA | grep $archivo_maestro -c` -ne 1 ]; then
    echo "Falta $archivo_maestro "
    exit 1
  fi

  archivosNov=("nov1.csv" "nov2.csv")
  for file in ${archivosNov[@]} ; do
    if [ `ls -l $DIRNOV | grep $file -c` -ne 1 ]; then
      echo "Falta $file"
      exit 1
    fi
  done

  archivo_log_inic=("ini.log")
  if [ `ls -l $DIRLOG | grep $archivo_log_inic -c` -ne 1 ]; then
    echo "Falta $archivo_log_inic "
    exit 1
  fi
}

verificarPermisos(){

	ejecutables=("inicializador" "demonio")
	for arch in ${ejecutables[@]} ; do
   		 if [ ! -x "$arch" ] || [ ! -r "$arch" ] ; then
      		chmod +xr "$arch"
       		if [ ! -x "$arch" ] || [ ! -r "$arch" ] ; then
            	echo "No se puede cambiar los permisos de $arch."
           		return 1
        	fi
    	fi
	done

	maestro=("maestro")

	if [ ! -r "$archivo_maestro" ] ; then
   		chmod +r "$archivo_maestro"
    	if [ ! -r "$archivo_maestro" ] ; then
            echo "No se puede cambiar los permisos de $archivo_maestro."
            return 1
    	fi
    fi
}

elegirOpcion(){
	option=""
	while [ "$option" != "Si" ] ; do
   		echo -n "Activar Demonio Si-No: "
    	read option
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
}

##############################################################################

################################### MAIN ####################################

if [ "$inicializado" ] ; then
    echo "ya se inicializo el ambiente."
    exit 0
fi

if [ -e "$ARCHCONF" ]; then
	setearAmbiente
else
	echo "EL SISTEMA NO ESTA INSTALADO"
	echo "Por favor, instalarlo de la siguiente manera:"
	echo "./instalador.sh  -i"
	exit 0
fi

detectarExistenciaArchivos
verificarPermisos
export inicializado=$true
elegirOpcion

#############################################################################
