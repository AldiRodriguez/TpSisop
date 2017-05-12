# --- Valores de ambiente por default ----
GRUPO=$(pwd)"/Grupo10/"

DIRBIN="$GRUPO""bin/"
DIRMAE="$GRUPO""mae/"
DIRREC="$GRUPO""nov/"
DIROK="$GRUPO""ok/"
DIRPROC="$GRUPO""imp/"
DIRINFO="$GRUPO""rep/"
DIRLOG="$GRUPO""log/"
DIRNOK="$GRUPO""nok/"
CONFDIR="$GRUPO""dirconf/"
DIRRESG="$GRUPO""source/"

SUM=0
DATASIZE=100

# ----------------------------------------

arch_comprimido="source.tar.gz"
ARCH_LOG="$CONFDIR""Instalep.log"

seteoVariables() {
	#notAllow = "dirconf"
	echo "Seteo de variables globales"
	echo "Ingrese un nuevo valor (en caso de carpetas, solo el nombre de la misma) o solo ENTER para mantener el valor por defecto."
	echo

	dirSinBarra="${DIRBIN%/*}"
	while
		printf "Defina el directorio de ejecutables (default: ${dirSinBarra##*/}/): " | tee -a ARCH_LOG
		read input
		echo $input >> ARCH_LOG
		if [ "$input" != "" ]; then DIRBIN="$GRUPO""${input%/*}/"; else DIRBIN="$GRUPO""bin/"; fi
		if [ "$input" = "dirconf" ]; then 
			echo "El nombre $input se encuentra reservado. Por favor ingrese otro nombre." | tee -a ARCH_LOG ; fi
		[ "$input" = "dirconf" ]
	do :; done

	dirSinBarra="${DIRMAE%/*}"
	while
		printf "Defina el directorio de Maestros y Tablas (default: ${dirSinBarra##*/}/): " | tee -a ARCH_LOG
		read input
		echo $input >> ARCH_LOG
		if [ "$input" != "" ]; then DIRMAE="$GRUPO""${input%/*}/"; else DIRME="$GRUPO""mae/"; fi
		if [ "$input" = "dirconf" ]; then 
			echo "El nombre $input se encuentra reservado. Por favor ingrese otro nombre." | tee -a ARCH_LOG ; fi
		[ "$input" = "dirconf" ]
	do :; done

	dirSinBarra="${DIRREC%/*}"
	while
		printf "Defina el directorio de Recepcion de Novedades (default: ${dirSinBarra##*/}/): " | tee -a ARCH_LOG
		read input
		echo $input >> ARCH_LOG
		if [ "$input" != "" ]; then DIRREC="$GRUPO""${input%/*}/"; else DIRREC="$GRUPO""nov/"; fi
		if [ "$input" = "dirconf" ]; then 
			echo "El nombre $input se encuentra reservado. Por favor ingrese otro nombre." | tee -a ARCH_LOG ; fi
		[ "$input" = "dirconf" ]
	do :; done
	
	dirSinBarra="${DIROK%/*}"
	while
		printf "Defina el directorio de Archivos Aceptados (default: ${dirSinBarra##*/}/): " | tee -a ARCH_LOG
		read input
		echo $input >> ARCH_LOG
		if [ "$input" != "" ]; then DIROK="$GRUPO""${input%/*}/"; else DIROK="$GRUPO""ok/"; fi
		if [ "$input" = "dirconf" ]; then 
			echo "El nombre $input se encuentra reservado. Por favor ingrese otro nombre." | tee -a ARCH_LOG ; fi
		[ "$input" = "dirconf" ]
	do :; done
	
	dirSinBarra="${DIRPROC%/*}"
	while
		printf "Defina el directorio de Archivos Procesados (default: ${dirSinBarra##*/}/): " | tee -a ARCH_LOG
		read input
		echo $input >> ARCH_LOG
		if [ "$input" != "" ]; then DIRPROC="$GRUPO""${input%/*}/"; else DIRPROC="$GRUPO""imp/"; fi
		if [ "$input" = "dirconf" ]; then 
			echo "El nombre $input se encuentra reservado. Por favor ingrese otro nombre." | tee -a ARCH_LOG ; fi
		[ "$input" = "dirconf" ]
	do :; done
	
	dirSinBarra="${DIRINFO%/*}"
	while
		printf "Defina el directorio de Reportes (default: ${dirSinBarra##*/}/): " | tee -a ARCH_LOG
		read input
		echo $input >> ARCH_LOG
		if [ "$input" != "" ]; then DIRINFO="$GRUPO""${input%/*}/"; else DIRINFO="$GRUPO""rep/"; fi
		if [ "$input" = "dirconf" ]; then 
			echo "El nombre $input se encuentra reservado. Por favor ingrese otro nombre." | tee -a ARCH_LOG ; fi
		[ "$input" = "dirconf" ]
	do :; done

	dirSinBarra="${DIRLOG%/*}"
	while
		printf "Defina el directorio de log (default: ${dirSinBarra##*/}/): " | tee -a ARCH_LOG
		read input
		echo $input >> ARCH_LOG
		if [ "$input" != "" ]; then DIRLOG="$GRUPO""${input%/*}/"; else DIRLOG="$GRUPO""log/"; fi
		if [ "$input" = "dirconf" ]; then 
			echo "El nombre $input se encuentra reservado. Por favor ingrese otro nombre." | tee -a ARCH_LOG ; fi
		[ "$input" = "dirconf" ]
	do :; done
	
	dirSinBarra="${DIRNOK%/*}"
	while
		printf "Defina el directorio de Rechazados (default: ${dirSinBarra##*/}/): " | tee -a ARCH_LOG
		read input
		echo $input >> ARCH_LOG
		if [ "$input" != "" ]; then DIRNOK="$GRUPO""${input%/*}/"; else DIRNOK="$GRUPO""nok/"; fi
		if [ "$input" = "dirconf" ]; then 
			echo "El nombre $input se encuentra reservado. Por favor ingrese otro nombre." | tee -a ARCH_LOG ; fi
		[ "$input" = "dirconf" ]
	do :; done

	sum=$(df -h -m|awk '{sum+=$4} END {print sum}')
	echo "Espacio disponible: $sum"
 	retrying=true
	
	while [ "$retrying" = true ]
	do
		printf "Defina espacio minimo libre para la recepcion de archivos en Mbytes (default: 100): " | tee -a ARCH_LOG
		read input	
		echo $input >> ARCH_LOG	
		DATASIZE=$input
		if [ $sum -lt $DATASIZE ]; then 
			echo "Insuficiente espacio en disco."
			echo "Espacio disponible: $sum Mb."
			echo "Espacio requerido $DATASIZE Mb"
			echo "Inténtelo nuevamente." | tee -a ARCH_LOG
		else	
			retrying=false
		fi
	done
	
	clear
	echo "Directorio de Configuracion: $CONFDIR" | tee -a ARCH_LOG
	#find $CONFDIR | tee -a ARCH_LOG
	echo "Directorio de Ejecutables: $DIRBIN" | tee -a ARCH_LOG
	#find $DIRBIN | tee -a ARCH_LOG
	echo "Directorio de Maestros y Tablas: $DIRMAE" | tee -a ARCH_LOG
	#find $DIRMAE | tee -a ARCH_LOG
	echo "Directorio de Recepcion de Novedades: $DIRREC" | tee -a ARCH_LOG
	echo "Directorio de Archivos Aceptados: $DIROK" | tee -a ARCH_LOG
	echo "Directorio de Archivos Procesados: $DIRPROC" | tee -a ARCH_LOG
	echo "Directorio de Archivos de Reportes: $DIRINFO" | tee -a ARCH_LOG
	echo "Directorio de Archivos de Log: $DIRLOG" | tee -a ARCH_LOG
	echo "Directorio de Archivos Rechazados: $DIRNOK" | tee -a ARCH_LOG
	echo "Estado de la instalacion: LISTA" | tee -a ARCH_LOG
	printf "Desea continuar con la instalacion? (Si - No) " | tee -a ARCH_LOG
	read input
	echo $input >> ARCH_LOG
	if [ "$input" != "Si" ]	; then clear; seteoVariables; fi
	
	printf "Iniciando instalacion. Esta Ud. seguro? (Si - No) " | tee -a ARCH_LOG
	read input
	echo $input >> ARCH_LOG
	if [ "$input" != "Si" ]; then echo "Fin del proceso. $USER $fecha_y_hora" | tee -a ARCH_LOG; exit 1; fi
}


generarArchConfiguracion(){
	ARCH_CNF="$CONFDIR""Instalep.conf"
	echo "Creando archivo de configuración en $ARCH_CNF..."
	fecha_y_hora=$(date "+%d/%m/%Y %H:%M:%S")

	echo "Actualizando la configuracion del sistema" | tee -a ARCH_LOG
	echo "DIRLOG=${DIRLOG%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "DATASIZE=${DATASIZE%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "GRUPO=${GRUPO=$USER%?}=$fecha_y_hora" >> "$ARCH_CNF"
	echo "DIRBIN=${DIRBIN%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "DIRMAE=${DIRMAE%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "DIRREC=${DIRREC%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "DIROK=${DIROK%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "DIRPROC=${DIRPROC%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "DIRINFO=${DIRINFO%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "DIRRESG=${DIRRESG%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "DIRNOK=${DIRNOK%?}=$USER=$fecha_y_hora" >> "$ARCH_CNF"
}


organizarArchivos(){
	if [ ! -e "$arch_comprimido" ]
	  then
		echo "Hubo un error: se requiere el archivo source.tar.gz en la carpeta $PWD para poder continuar la instalación."
		exit 1
	fi

	tar -xzf source.tar.gz

	echo "Instalando Programas y Funciones" | tee -a ARCH_LOG
	mv source/DIRBIN/* "$DIRBIN"
	echo "Instalando Archivos Maestros y Tablas" | tee -a ARCH_LOG
	mv source/DIRMAE/* "$DIRMAE"

	mv "$arch_comprimido" "$DIRRESG"
	rm -rf "source/"

	cp Readme.md "$DIRRESG"
	mv Readme.md "$GRUPO"
}


# /////////////////////// MAIN /////////////////////////////////////

fecha_y_hora=$(date "+%d/%m/%Y %H:%M:%S")
echo "Inicio del proceso. $USER $fecha_y_hora" | tee -a ARCH_LOG

# Chequea instalacion previa
if [ -e "$CONFDIR""$ARCH_CNF" ]
  then
	echo "Ya existe una instalación previa." | tee -a ARCH_LOG
	echo "Directorio de Configuracion: $CONFDIR" | tee -a ARCH_LOG
	echo "Directorio de Ejecutables: $DIRBIN" | tee -a ARCH_LOG
	echo "Directorio de Maestros y Tablas: $DIRMAE" | tee -a ARCH_LOG
	echo "Directorio de Recepcion de Novedades: $DIRREC" | tee -a ARCH_LOG
	echo "Directorio de Archivos Aceptados: $DIROK" | tee -a ARCH_LOG
	echo "Directorio de Archivos Procesados: $DIRPROC" | tee -a ARCH_LOG
	echo "Directorio de Archivos de Reportes: $DIRINFO" | tee -a ARCH_LOG
	echo "Directorio de Archivos de Log: $DIRLOG" | tee -a ARCH_LOG
	echo "Directorio de Archivos Rechazados: $DIRNOK" | tee -a ARCH_LOG
	echo "Fin del proceso. $USER $fecha_y_hora" | tee -a ARCH_LOG
	return 1
fi

if [ ! -e "$arch_comprimido" ]
  then
	echo "Hubo un error: se requiere el archivo source.tar.gz en la carpeta actual ($PWD) para poder efectuar la instalación."
	exit 1
fi


echo
echo "~ Inicio de instalación del sistema EPLAM ~"
echo "-------------------------------------------"
echo
seteoVariables
echo
echo "-------------------------------------------"
echo
echo "Creando estructuras de directorio..." | tee -a ARCH_LOG
echo

mkdir --parents "$DIRBIN" "$DIRMAE" "$DIRREC" "$DIROK" "$DIRPROC/proc" "$DIRINFO" "$DIRLOG" "$DIRNOK" "$CONFDIR" "$DIRRESG"

generarArchConfiguracion

organizarArchivos

echo
echo "Instalacion CONCLUIDA" | tee -a ARCH_LOG
echo

mv "instalep.sh" "$DIRRESG"

echo "Fin del proceso. $USER $fecha_y_hora" | tee -a ARCH_LOG

cd "$DIRBIN"

exit 0
