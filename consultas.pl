#!/usr/bin/perl
#CONSULTAS CON PERL

############################## CONSTANTES ###################################
%hashFiles;
%hashFiltroEntidad;
@listaFiltroFecha;
@listaFiltroImporte;
##############################################################################

############################# OPCIONES DETALLE OUTPUT#####################
sub opciones{
	# Recibe como parametro:
	# 1 si es listado
	# 2 si es balance
	# 3 si es ranking

	# Devuelve una lista con:
	# el primer valor en 1 si quiere detalles
	# el primer valor en 2 si no quiere detalles

	# el segundo valor en 1 si debe imprimir por pantalla
	# el segundo valor en 2 si debe imprimir por archivo
	# el segundo valor en 3 si debe imprimir por ambos

	# el tercer valor es el nombre del archivo si el segundo valor es 2 o 3
	my $tipoReporte = @_[0];
	my @opciones = 0;
	while ($opciones[0] != 1 && $opciones[0] != 2){
		print "Seleccione opcion\n\n";

		print "1- Reporte CON detalle\n";
		print "2- Reporte SIN detalle\n";

		print "Rta: ";
		$opciones[0]=<STDIN>;chomp($opciones[0]);
	}
	while ($opciones[1] != 1 && $opciones[1] != 2 && $opciones[1] != 3){
		print "Seleccione opcion\n\n";

		print "1- Mostrar reporte por pantalla\n";
		print "2- Guardar reporte en archivo\n";
		print "3- Ambas anteriores\n";

		print "Rta: ";
		$opciones[1]=<STDIN>;chomp($opciones[1]);
	}
	if ($opciones[1] == 2 || $opciones[1] == 3){
		print "Ingrese nombre de archivo\n\n";
		$opciones[2] = <STDIN>;chomp($opciones[2]);

		my $direct2;
		$direct2="listados/" if ($tipoReporte == 1);
		$direct2="balances/" if ($tipoReporte == 2);
		$direct2="rankings/" if ($tipoReporte == 3);
		
		###TODO: leer de ambiente
		$direct = "./transfer/";

		while (-e $direct.$direct2.$opciones[2]){
			print "El archivo ya existe\n Ingrese otro\n";
			$opciones[2] = <STDIN>;chomp($opciones[2]);
		}
	}
	@return = @opciones;

}

##############################################################################

############################# LISTADOS #################################
sub listarPorEntidadOrigen{
	@opciones = opciones(1);
};
sub listarPorEntidadDestino{
	@opciones = opciones(1);
};
sub listarPorPendiente{
	@opciones = opciones(1);
};
sub listarPorAnulada{
	@opciones = opciones(1);
};
sub listarFiltroFecha{
	@opciones = opciones(1);
};
sub listarFiltroRangoFecha{
	@opciones = opciones(1);
};
sub listarFiltroImporte{
	@opciones = opciones(1);
};
sub listarSinFiltro{
	@opciones = opciones(1);
};
##############################################################################

############################# PROCEDIMIENTOS #################################

sub verificarAmbiente {
	print "Verificando ambiente...\n\n";
};

sub mostrarAyuda {
	print "Modo De Uso:\n\n";
	print "$0 \n\n";

};

sub archivoInput {
	
	my $corte = 0;
	my $opc = 0;

	while ($opc != 1 && $opc != 2 && $opc != 3 && $opc != 4 ) {
		print "Ingrese los archivos de Input\n\n";

		print "1- Todos\n";
		print "2- Uno\n";
		print "3- Varios\n";
		print "4- Rango\n";

		print "Rta: ";
		$opc=<STDIN>;
		chomp($opc);

	}
	###TODO: leer de ambiente
	$direct = "./transfer/";
	if (opendir(DIR, $direct)) {
		@filelist = readdir(DIR);
		closedir(DIR);

		####TODOOOOS
		if ($opc == 1){
			foreach $file (@filelist){
				next if ($file eq "." || $file eq ".." || $file eq ".DS_Store");
				$hashFiles{$file}=0;
			}
		}


		####UNOOOOO
		elsif ($opc == 2){
			print "Ingrese fecha en el formato AAAAMMDD\n";
			my $fecha = <STDIN>;chomp($fecha);
			while (! -e $direct.$fecha.".txt"){
				print "No se encontro el archivo $fecha.txt\n";
				$fecha = <STDIN>;chomp($fecha);
			}
			$hashFiles{$fecha.".txt"}=0;

		}


		####VARIOOOOS
		elsif ($opc == 3){
			print "Ingrese fechas en formato AAAAMMDD, ingrese 'q' para terminar\n";
			my $fecha = <STDIN>;chomp($fecha);
			while ($fecha ne "q"){
				foreach $file (@filelist){
				
					if ($fecha.".txt" eq $file){
						$hashFiles{$file}=0;
						print "Fecha agregada\n";
						print "Ingrese otra fecha o 'q' para salir\n";
						last;
					}
				}
				if (! exists $hashFiles{$fecha.".txt"}) {
					print "No se encontro el archivo $fecha.txt\n";
					print "Ingrese otra fecha o 'q' para salir\n";
				}

				$fecha=<STDIN>;chomp($fecha);
			}
			
		}

		
		####RANGOOOO
		elsif ($opc == 4){
			print "Ingrese rango\n";
			print "Ingrese fecha inicio en formato AAAAMMDD\n";
			my $fechaIni = <STDIN>;chomp($fechaIni);
			while (! -e $direct.$fechaIni.".txt"){
				print "El archivo $fechaIni.txt no existe, vuelva a ingresar\n";
				$fechaIni = <STDIN>;chomp($fechaIni);
			}

			print "Ingrese fecha final en formato AAAAMMDD\n";
			my $fechaFinal = <STDIN>;chomp($fechaFinal);
			while (! -e $direct.$fechaFinal.".txt" || $fechaFinal < $fechaIni){
				print "El archivo $fechaFinal.txt no existe o es menor a $fechaIni, vuelva a ingresar\n";
				$fechaFinal = <STDIN>;chomp($fechaFinal);
			}
			print "\nFecha Inicial: $fechaIni\n";
			print "Fecha Final: $fechaFinal\n";

			foreach $file (@filelist){
				(my $newFile = $file) =~ s/.txt//g;
				if ($newFile >= $fechaIni && $newFile <= $fechaFinal){
					print "$file\n";
					$hashFiles{$file}=0;
				}
			}

			
		}
	
	}else{die "No se puede abrir el directorio\n";}

}


sub output {

	my ($opc, $opc2, $opc3) = 0;

	while ($opc != 1 && $opc != 2 && $opc != 3 ) {
		print "Ingrese el tipo de reporte\n\n";

		print "1- Listado\n";
		print "2- Balance\n";
		print "3- Ranking\n";

		print "Rta: ";
		$opc=<STDIN>;chomp($opc);

	}

	if ($opc == 1){
		while ($opc2 != 1 && $opc2 != 2 && $opc2 != 3 && $opc2 != 4 && $opc2 != 5 && $opc2 != 6) {
			print "Seleccione filtro para el listado\n\n";

			print "1- Por entidad de origen\n";
			print "2- Por entidad de destino\n";
			print "3- Por estado\n";
			print "4- Por fecha de transferencia\n";
			print "5- Por importe\n";
			print "6- Sin filtro\n";

			print "Rta: ";
			$opc2=<STDIN>;chomp($opc2);

		}
		if ($opc2 == 1 || $opc2 == 2){
			print "Ingrese el nombre de la entidad\n\n";
			my $entidad = <STDIN>;chomp($entidad);

			while ($entidad ne "q"){
				$hashFiltroEntidad{$entidad}=0;
				print "Ingrese otra entidad o 'q' para finalizar el filtro\n\n";

				$entidad = <STDIN>;chomp($entidad);
			}

			listarPorEntidadOrigen if ($opc2 == 1);
			listarPorEntidadDestino if ($opc2 == 2);
			
		}elsif ($opc2 == 3){
			while ($opc3 != 1 && $opc3 != 2){
				print "Ingrese el estado por el cual desea filtar\n\n";

				print "1- Pendiente\n";
				print "2- Anulada\n";

				print "Rta: ";
				$opc3=<STDIN>;chomp($opc3);
			}

			listarPorPendiente if ($opc3 == 1);
			listarPorAnulada if ($opc3 == 2);
			
		}elsif ($opc2 == 4){
			$opc3 = 0;
			while ($opc3 != 1 && $opc3 != 2){
				print "Ingrese opcion para filtrar por fecha\n\n";

				print "1- Una\n";
				print "2- Rango\n";

				print "Rta: ";
				$opc3=<STDIN>;chomp($opc3);
			}
			if ($opc3 == 1){
				print "Ingrese fecha en formato AAAAMMDD\n\n";
				#TODO: verificar que sea formato correcto
				$listaFiltroFecha[0] = <STDIN>;
				chomp($listaFiltroFecha[0]);

				listarFiltroFecha;

			}elsif ($opc3 == 2){
				print "Ingrese fecha inicio en formato AAAAMMDD\n";
				my $fechaIni = <STDIN>;chomp($fechaIni);

				print "Ingrese fecha final en formato AAAAMMDD\n";
				my $fechaFinal = <STDIN>;chomp($fechaFinal);
				while ( $fechaFinal < $fechaIni){
					print "La fecha final no puede ser menor a fecha inicial ($fechaIni), vuelva a ingresar\n";
					$fechaFinal = <STDIN>;chomp($fechaFinal);
				}
				print "\nFecha Inicial: $fechaIni\n";
				print "Fecha Final: $fechaFinal\n";

				$listaFiltroFecha[0] = $fechaIni;
				$listaFiltroFecha[1] = $fechaFinal;

				listarFiltroRangoFecha;

			}
		}elsif ($opc2 == 5){
			print "Ingrese importe minimo\n";
			my $importeMin = <STDIN>;chomp($importeMin);

			print "Ingrese importe maximo\n";
			my $importeMax = <STDIN>;chomp($importeMax);
			while ( $importeMax <= $importeMin){
				print "El importe maximo no puede ser menor o igual al minimo (\$$importeMin), vuelva a ingresar\n";
				$importeMax = <STDIN>;chomp($importeMax);
			}
			print "\nImporte minimo: $importeMin\n";
			print "Importe maximo: $importeMax\n";

			$listaFiltroImporte[0] = $importeMin;
			$listaFiltroImporte[1] = $importeMax;


			listarFiltroImporte;
		}elsif ($opc2 == 6) {listarSinFiltro;}
	}elsif ($opc1 == 2){
		$opc2 = 0; $opc3 = 0;
		#TODO: balance

	}elsif ($opc1 == 3){
		$opc2 = 0; $opc3 = 0;
		#TODO: ranking
	}


}
##############################################################################

################################### MAIN ####################################

if (@ARGV > 0){
	mostrarAyuda;
} else {
	verificarAmbiente;


	archivoInput;
	if (keys(%hashFiles) == 0) {die "NO HAY ARCHIVOS VALIDOS.\n";}
	print "\n\nArchivos a Utilizar:\n\n";
	foreach (keys(%hashFiles)){
		print "$_\n";
	}

	output;
}



##############################################################################