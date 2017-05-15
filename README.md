# TpSisop

1- Descomprimir zip en el directorio donde se desea instalar el programa

  Esto va a generar :

    - Archivos necesarios para la instalacion, ejecucion y utilidades del sistema:
    - - instalador.sh 
    - - inicializador.sh
    - - demonio.sh
    - - start.sh
    - - stop.sh
    - - consultas.pl
    - Carpeta de Datos

2- Dar permisos al comando "instalador" de la siguiente manera:

        ```sh
        chmod +x instalador.sh
        ```

3- Fijarse si se encuentra instalado el programa:

        ```sh
            ./instalador -t
        ```

4- En caso negativo, instalarlo:

        ```sh
            ./instalador -i
        ```

Al ejecutarlo, se pedirá que ingrese los nombres de los directorios. Siga las instrucciones y complete la instalacion

5- Una vez finalizado, iniciarlo:


        ```sh
            . ./inicializador.sh
        ```
        o
        ```sh
            source ./inicializador.sh
        ```

7- Seguir las instrucciones