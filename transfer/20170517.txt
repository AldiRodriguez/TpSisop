#!/bin/bash
source logep.sh

RUTA_ACTUAL=$PWD
while [[ $PWD != '/' && ${PWD##*/} != 'Grupo10' ]]
do
	cd ..
done

ARCH_CONF="$PWD/dirconf/Instalep.conf"
cd $RUTA_ACTUAL


if [ ! -e "$ARCH_CONF" ]
then
	echo "No existe el archivo de configuracion."
	echo "Presione ENTER para salir."
	read INPUT
	exit 0
fi


#Verifico si el ambiente ya ha sido inicializado
if [[ ${INITREADY+x} ]]
then
	MENSAJE="Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente"
	echo $MENSAJE
	Logep Initep "$MENSAJE" WAR
	echo "Presione ENTER para salir."
	read INPUT
	exit 0
fi


#Seteo de variables de ambiente
export LOGSIZE="1024"

while read linea
do
	nombre=$(echo $linea | cut -f1 -d '=')
	valor=$(echo $linea | cut -f2 -d '=')

	declare $nombre=$valor
	export $nombre
done < "$ARCH_CONF"


export PATH="$PATH:$GRUPO:${GRUPO}bin/"

MENSAJE="Estado del Sistema: INICIALIZADO"
echo $MENSAJE
Logep Initep "$MENSAJE" INFO


#Verificacion de permisos
verificarPermisos() {
	if [ ! -f "$1" ]
	then
		return
	fi

	if [[ "$1" == *.log && ! -w "$1" ]]
	then
		echo "Otorgado permiso de escritura a $1"		
		chmod +w $1
	fi

	if [ ! -r "$1" ]
	then
		echo "Otorgado permiso de lectura a $1"		
		chmod +r $1
	fi

}

find $GRUPO -type f | while read archivo
do
	verificarPermisos $archivo
done



#Arranque del demonio
MENSAJE="¿Desea efectuar la activación de Demonep? Si - No"
echo $MENSAJE
Logep Initep "$MENSAJE" INFO

read INPUT

Logep Initep "$INPUT" INFO
if [ "$INPUT" == "Si" ]
then
	./demonep.sh&
	ID=$!
	MENSAJE="Demonep corriendo bajo el no.: $ID"
	echo $MENSAJE
	Logep Initep "$MENSAJE" INFO
	echo "Para detenerlo ingrese kill $ID"
else
	echo "Para iniciar Demonep manualmente ingrese ./demonep.sh&"
fi

export INITREADY=1
