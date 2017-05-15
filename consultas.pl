#!/usr/bin/perl
#CONSULTAS CON PERL

use Term::ANSIColor qw(:constants);
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

	# el tercer valor es la ruta del archivo si el segundo valor es 2 o 3
	my $tipoReporte = @_[0];
	my @opciones = 0;
	while ($opciones[0] != 1 && $opciones[0] != 2){
		print BOLD BLUE,"Seleccione opcion\n\n",RESET;

		print "1- Reporte CON detalle\n";
		print "2- Reporte SIN detalle\n";

		print "Rta: ";
		$opciones[0]=<STDIN>;chomp($opciones[0]);
	}
	while ($opciones[1] != 1 && $opciones[1] != 2 && $opciones[1] != 3){
		print BOLD BLUE,"Seleccione opcion\n\n",RESET;

		print "1- Mostrar reporte por pantalla\n";
		print "2- Guardar reporte en archivo\n";
		print "3- Ambas anteriores\n";

		print "Rta: ";
		$opciones[1]=<STDIN>;chomp($opciones[1]);
	}
	if ($opciones[1] == 2 || $opciones[1] == 3){
		print BOLD BLUE,"Ingrese nombre de archivo\n\n",RESET;
		$opciones[2] = <STDIN>;chomp($opciones[2]);

		my $direct2;
		$direct2="listados/" if ($tipoReporte == 1);
		$direct2="balances/" if ($tipoReporte == 2);
		$direct2="rankings/" if ($tipoReporte == 3);
		
		###TODO: leer de ambiente
		$direct = "./transfer/";

		while (-e $direct.$direct2.$opciones[2]){
			print RED,"El archivo ya existe\nIngrese otro\n",RESET;
			$opciones[2] = <STDIN>;chomp($opciones[2]);
		}
		$opciones[2]=$direct.$direct2.$opciones[2]
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

############################# BALANCES #################################
sub balancearEntidad{
	my @entidades = @_;
	@opciones = opciones(2);
	print $opciones[2];
	open(SALIDA, ">$opciones[2]") or die "NO SE PUEDE ABRIR $opciones[2]\n" if ($opciones[1] == 2 || $opciones[1] == 3);
	my @listaHash = keys(%hashFiles);
	my $i = 0;
	
	my %desde, %hacia;
	while ($i <= $#listaHash)  {
		open(ENTRADA, "<$listaHash[$i]");
		my @lineas = <ENTRADA>;
		foreach $linea (@lineas) {
			($desde = $linea) =~ s/^[^;]*;([^;]*);[^;]*;[^;]*;[^;]*;[^;]*;([^;]*);.*$/\1;\2/g;
			($hacia = $linea) =~ s/^[^;]*;[^;]*;[^;]*;([^;]*);[^;]*;[^;]*;([^;]*);.*$/\1;\2/g;

			my ($orig, $valor1) = split(/;/, $desde);
			my ($dest, $valor2) = split(/;/, $hacia);
			
			$desde{$orig} = $desde{$orig} + $valor1 if ($orig);
			$hacia{$dest} = $hacia{$dest} + $valor2 if ($dest);
		}
		close(ENTRADA);
		$i++;
	}
	my $entidad = pop @entidades;
	if ($opciones[1] == 2 || $opciones[1] == 3){
		print BLUE BOLD, "Balance de entidades\n\n", RESET;
	}
	if ($opciones[1] == 1 || $opciones[1] == 3){
		print SALIDA "Balance de entidades\n\n";
	}

	while ($entidad){
		if (exists $hacia{$entidad} || exists $desde{$entidad}){
			$positivo = $hacia{$entidad};
			$negativo = $desde{$entidad};
			if ($opciones[1] == 2 || $opciones[1] == 3){
				print "Desde $entidad\t\t\t\t$negativo\t\t hacia otras entidades\n";
				print "Hacia $entidad\t\t\t\t$positivo\t\t desde otras entidades\n";
				print "Balance NEGATIVO para $entidad" if ($negativo > $positivo);
				print "Balance POSITIVO para $entidad" if ($negativo <= $positivo);
				my $total = $positivo - $negativo;
				print BOLD RED,"  \t$total\n\n",RESET if ($total<0);
				print BOLD GREEN,"  \t$total\n\n",RESET if ($total>0);
			}
			if ($opciones[1] == 1 || $opciones[1] == 3){
				print SALIDA "Desde $entidad\t\t\t\t$negativo\t\t hacia otras entidades\n";
				print SALIDA "Hacia $entidad\t\t\t\t$positivo\t\t desde otras entidades\n";
				print SALIDA "Balance NEGATIVO para $entidad" if ($negativo > $positivo);
				print SALIDA "Balance POSITIVO para $entidad" if ($negativo <= $positivo);
				my $total = $positivo - $negativo;
				print SALIDA "  \t$total\n\n" if ($total<0);
				print SALIDA "  \t$total\n\n" if ($total>0);
			}

		}

		$entidad = pop @entidades;

	}
	close(SALIDA);

}

sub balancerEntreEntidades{
	my ($entidad1, $entidad2) = @_;
	@opciones = opciones(2);
	open(SALIDA, ">$opciones[2]") or die "NO SE PUEDE ABRIR $opciones[2]\n" if ($opciones[1] == 2 || $opciones[1] == 3);
	
	my @listaHash = keys(%hashFiles);
	my $i = 0;
	print BLUE BOLD,"Transferencias entre $entidad1 y $entidad2\n\n", RESET;
	my %bal;
	if ($opciones[0] == 1){
		if ($opciones[1] == 1 || $opciones[1] == 3){
			print BLUE BOLD,"FECHA\t\tIMPORTE\t\tESTADO\t\tORIGEN\t\tDESTINO\n\n",RESET;
		}
		if ($opciones[1] == 2 || $opciones[1] == 3){
			print SALIDA "FECHA\t\tIMPORTE\t\tESTADO\t\tORIGEN\t\tDESTINO\n\n";
		}
	}elsif ($opciones[0] == 2){
		if ($opciones[1] == 1 || $opciones[1] == 3){
			print BLUE BOLD,"ENTIDAD\t\t\t\t\tIMPORTE\n\n",RESET;
		}
		if ($opciones[1] == 2 || $opciones[1] == 3){
			print SALIDA "ENTIDAD\t\t\t\t\tIMPORTE\n\n";
		}
	}
	while ($i <= $#listaHash)  {
		open(ENTRADA, "<$listaHash[$i]");
		my @lineas = <ENTRADA>;
		foreach $linea (@lineas) {
			(my $linea1 = $linea) =~ s/^[^;]*;([^;]*);[^;]*;([^;]*);[^;]*;([^;]*);([^;]*);([^;]*);([^;]*);([^;]*)$/\1;\2;\3;\4;\5;\6;\7/g;
			
			my ($orig, $dest, $fecha, $importe, $estado, $CBUorig, $CBUdest) = split(/;/, $linea1);
			
			if ($orig eq $entidad1 && $dest eq $entidad2 ){
				if ($opciones[0] == 1){
					if ($opciones[1] == 1 || $opciones[1] == 3){
						print "$fecha\t\t$importe\t\t$estado\t\t$CBUorig\t\t$CBUdest\n";
					}
					if ($opciones[1] == 2 || $opciones[1] == 3){
						print SALIDA "$fecha\t\t$importe\t\t$estado\t\t$CBUorig\t\t$CBUdest\n";
					}
				}
				$bal{$orig} = $bal{$orig} + $importe;
			}
			
		}
		close(ENTRADA);
		$i++;
	}
	
	if ($opciones[1] == 1 || $opciones[1] == 3){
		print BOLD GREEN,"Desde $entidad1 hacia $entidad2\t\t$bal{$entidad1}\n",RESET;
	}
	if ($opciones[1] == 2 || $opciones[1] == 3){
		print SALIDA "Desde $entidad1 hacia $entidad2\t\t$bal{$entidad1}\n";
	}

	$i = 0;
	while ($i <= $#listaHash)  {
		open(ENTRADA, "<$listaHash[$i]");
		my @lineas2 = <ENTRADA>;
		foreach $linea2 (@lineas2) {
			$linea2 =~ s/^[^;]*;([^;]*);[^;]*;([^;]*);[^;]*;([^;]*);([^;]*);([^;]*);([^;]*);([^;]*)$/\1;\2;\3;\4;\5;\6;\7/g;

			my ($orig2, $dest2, $fecha2, $importe2, $estado2, $CBUorig2, $CBUdest2) = split(/;/, $linea2);

			if ($orig2 eq $entidad2 && $dest2 eq $entidad1){
				if ($opciones[0] == 1){
					if ($opciones[1] == 1 || $opciones[1] == 3){
						print "$fecha2\t\t$importe2\t\t$estado2\t\t$CBUorig2\t\t$CBUdest2\n";
					}
					if ($opciones[1] == 2 || $opciones[1] == 3){
						print SALIDA "$fecha2\t\t$importe2\t\t$estado2\t\t$CBUorig2\t\t$CBUdest2\n";
					}
				}
				$bal{$orig2} = $bal{$orig2} + $importe2;
			}
			
		}
		close(ENTRADA);
		$i++;
	}
	if ($opciones[1] == 1 || $opciones[1] == 3){
		print BOLD GREEN,"Desde $entidad2 hacia $entidad1\t\t$bal{$entidad2}\n";
		print "Balance POSITIVO para $entidad2\t\t".($bal{$entidad1} - $bal{$entidad2})."\n" if ($bal{$entidad1} > $bal{$entidad2});
		print "Balance POSITIVO para $entidad1\t\t".($bal{$entidad2} - $bal{$entidad1})."\n" if ($bal{$entidad2} > $bal{$entidad1});	
	}
	if ($opciones[1] == 2 || $opciones[1] == 3){
		print SALIDA "Desde $entidad2 hacia $entidad1\t\t$bal{$entidad2}\n";
		print SALIDA "Balance POSITIVO para $entidad2\t\t".($bal{$entidad1} - $bal{$entidad2})."\n" if ($bal{$entidad1} > $bal{$entidad2});
		print SALIDA "Balance POSITIVO para $entidad1\t\t".($bal{$entidad2} - $bal{$entidad1})."\n" if ($bal{$entidad2} > $bal{$entidad1});
	}
		
}
#############################################################################

############################# RANKINGS #################################
sub rankearIngresos{
	@opciones = opciones(3);
	open(SALIDA, ">$opciones[2]") or die "NO SE PUEDE ABRIR $opciones[2]\n" if ($opciones[1] == 2 || $opciones[1] == 3);

	if ($opciones[1] == 2 || $opciones[1] == 3){
		print GREEN BOLD,"Ranking TOP 3 INGRESOS\n\n", RESET;
		print GREEN,"Entidad\t\t\tImporte Total\n",RESET;
	}
	if ($opciones[1] == 1 || $opciones[1] == 3){
		print SALIDA "Ranking TOP 3 INGRESOS\n\n";
		print SALIDA "Entidad\t\t\tImporte Total\n";
	}


	my @listaHash = keys(%hashFiles);
	my $i = 0;
	my %rank;
	while ($i <= $#listaHash)  {
		open(ENTRADA, "<$listaHash[$i]");
		my @lineas = <ENTRADA>;
		foreach $linea (@lineas) {
			$linea =~ s/^[^;]*;[^;]*;[^;]*;([^;]*);[^;]*;[^;]*;([^;]*);.*$/\1;\2/g;
			my ($dest, $valor) = split(/;/, $linea);
			
			$rank{$dest} = $rank{$dest} + $valor;
		}
		close(ENTRADA);
		$i++;

	}
	my $cuenta = 0;
	foreach my $name (sort { $rank{$b} <=> $rank{$a} } keys %rank) {
    	if ($opciones[1] == 2 || $opciones[1] == 3){
    		printf "$name\t\t\t$rank{$name}\n" if $cuenta < 3;
    	}
    	if ($opciones[1] == 1 || $opciones[1] == 3){
    		printf SALIDA "$name\t\t\t$rank{$name}\n" if $cuenta < 3;
    	}
    	$cuenta ++;
	}
	close(SALIDA);
}

sub rankearEgresos{
	@opciones = opciones(3);
	open(SALIDA, ">$opciones[2]") or die "NO SE PUEDE ABRIR $opciones[2]\n" if ($opciones[1] == 2 || $opciones[1] == 3);

	if ($opciones[1] == 2 || $opciones[1] == 3){
		print GREEN BOLD,"Ranking TOP 3 EGRESOS\n\n", RESET;
		print GREEN,"Entidad\t\t\tImporte Total\n",RESET;
	}
	if ($opciones[1] == 1 || $opciones[1] == 3){
		print SALIDA "Ranking TOP 3 EGRESOS\n\n";
		print SALIDA "Entidad\t\t\tImporte Total\n";
	}
	

	my @listaHash = keys(%hashFiles);
	my $i = 0;
	my %rank;
	while ($i <= $#listaHash)  {
		open(ENTRADA, "<$listaHash[$i]");
		my @lineas = <ENTRADA>;
		foreach $linea (@lineas) {
			$linea =~ s/^[^;]*;([^;]*);[^;]*;[^;]*;[^;]*;[^;]*;([^;]*);.*$/\1;\2/g;
			my ($orig, $valor) = split(/;/, $linea);
			
			$rank{$orig} = $rank{$orig} + $valor;
		}
		close(ENTRADA);
		$i++;

	}
	my $cuenta = 0;
	foreach my $name (sort { $rank{$b} <=> $rank{$a} } keys %rank) {
    	if ($opciones[1] == 2 || $opciones[1] == 3){
    		printf "$name\t\t\t$rank{$name}\n" if $cuenta < 3;
    	}
    	if ($opciones[1] == 1 || $opciones[1] == 3){
    		printf SALIDA "$name\t\t\t$rank{$name}\n" if $cuenta < 3;
    	}
    	$cuenta ++;
	}
	close(SALIDA);
}

##############################################################################

############################# PROCEDIMIENTOS #################################

sub verificarAmbiente {
	print "Verificando ambiente...\n\n";
};

sub mostrarAyuda {
	print BOLD BLUE,"Modo De Uso:\n\n",RESET;
	print "$0 \n";
	print "Siga las instrucciones ingresando numeros de lista o dato solicitado.\n\n";

};

sub archivoInput {
	
	my $corte = 0;
	my $opc = 0;

	while ($opc != 1 && $opc != 2 && $opc != 3 && $opc != 4 ) {
		print BOLD BLUE,"Ingrese los archivos de Input\n\n",RESET;

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
				$hashFiles{$direct.$file}=0;
			}
		}


		####UNOOOOO
		elsif ($opc == 2){
			print BOLD BLUE,"Ingrese fecha en el formato AAAAMMDD\n",RESET;
			my $fecha = <STDIN>;chomp($fecha);
			while (! -e $direct.$fecha.".txt"){
				print RED,"No se encontro el archivo $fecha.txt\n",RESET;
				$fecha = <STDIN>;chomp($fecha);
			}
			$hashFiles{$direct.$fecha.".txt"}=0;

		}


		####VARIOOOOS
		elsif ($opc == 3){
			print BOLD BLUE,"Ingrese fechas en formato AAAAMMDD, ingrese 'q' para terminar\n", RESET;
			my $fecha = <STDIN>;chomp($fecha);
			while ($fecha ne "q"){
				foreach $file (@filelist){
				
					if ($fecha.".txt" eq $file){
						$hashFiles{$direct.$file}=0;
						print GREEN,"Fecha agregada\n",RESET;
						print BOLD BLUE,"Ingrese otra fecha o 'q' para terminar\n",RESET;
						last;
					}
				}
				if (! exists $hashFiles{$direct.$fecha.".txt"}) {
					print RED,"No se encontro el archivo $fecha.txt\n",RESET;
					print BOLD BLUE,"Ingrese otra fecha o 'q' para terminar\n",RESET;
				}

				$fecha=<STDIN>;chomp($fecha);
			}
			
		}

		
		####RANGOOOO
		elsif ($opc == 4){
			print BOLD BLUE,"Ingrese rango\n";
			print "Ingrese fecha inicio en formato AAAAMMDD\n",RESET;
			my $fechaIni = <STDIN>;chomp($fechaIni);
			while (! -e $direct.$fechaIni.".txt"){
				print RED,"El archivo $fechaIni.txt no existe, vuelva a ingresar\n",RESET;
				$fechaIni = <STDIN>;chomp($fechaIni);
			}

			print BOLD BLUE,"Ingrese fecha final en formato AAAAMMDD\n",RESET;
			my $fechaFinal = <STDIN>;chomp($fechaFinal);
			while (! -e $direct.$fechaFinal.".txt" || $fechaFinal < $fechaIni){
				print RED,"El archivo $fechaFinal.txt no existe o es menor a $fechaIni, vuelva a ingresar\n",RESET;
				$fechaFinal = <STDIN>;chomp($fechaFinal);
			}
			print GREEN,"\nFecha Inicial: $fechaIni\n";
			print "Fecha Final: $fechaFinal\n",RESET;

			foreach $file (@filelist){
				(my $newFile = $file) =~ s/.txt//g;
				if ($newFile >= $fechaIni && $newFile <= $fechaFinal){
					$hashFiles{$direct.$file}=0;
				}
			}

			
		}
	
	}else{die RED,"No se puede abrir el directorio\n",RESET;}

}


sub output {

	my ($opc, $opc2, $opc3) = 0;

	while ($opc != 1 && $opc != 2 && $opc != 3 ) {
		print BOLD BLUE,"Ingrese el tipo de reporte\n\n",RESET;

		print "1- Listado\n";
		print "2- Balance\n";
		print "3- Ranking\n";

		print "Rta: ";
		$opc=<STDIN>;chomp($opc);

	}

	if ($opc == 1){
		while ($opc2 != 1 && $opc2 != 2 && $opc2 != 3 && $opc2 != 4 && $opc2 != 5 && $opc2 != 6) {
			print BOLD BLUE,"Seleccione filtro para el listado\n\n",RESET;

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
			print BOLD BLUE,"Ingrese el nombre de la entidad\n",RESET;
			my $entidad = <STDIN>;chomp($entidad);

			while ($entidad ne "q"){
				if ($entidad) {$hashFiltroEntidad{$entidad}=0;}
				print BOLD BLUE,"Ingrese otra entidad o 'q' para finalizar el filtro\n",RESET;

				$entidad = <STDIN>;chomp($entidad);
			}
			if (keys(%hashFiltroEntidad) == 0) {die RED,"ERROR, no hay entidades\n",RESET;}
			listarPorEntidadOrigen if ($opc2 == 1);
			listarPorEntidadDestino if ($opc2 == 2);
			
		}elsif ($opc2 == 3){
			while ($opc3 != 1 && $opc3 != 2){
				print BOLD BLUE,"Ingrese el estado por el cual desea filtar\n\n",RESET;

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
				print BOLD BLUE,"Ingrese opcion para filtrar por fecha\n\n",RESET;

				print "1- Una\n";
				print "2- Rango\n";

				print "Rta: ";
				$opc3=<STDIN>;chomp($opc3);
			}
			if ($opc3 == 1){
				print BOLD BLUE,"Ingrese fecha en formato AAAAMMDD\n\n",RESET;
				#TODO: verificar que sea formato correcto
				$listaFiltroFecha[0] = <STDIN>;
				chomp($listaFiltroFecha[0]);

				listarFiltroFecha;

			}elsif ($opc3 == 2){
				print BOLD BLUE,"Ingrese fecha inicio en formato AAAAMMDD\n",RESET;
				my $fechaIni = <STDIN>;chomp($fechaIni);

				print BOLD BLUE,"Ingrese fecha final en formato AAAAMMDD\n",RESET;
				my $fechaFinal = <STDIN>;chomp($fechaFinal);
				while ( $fechaFinal < $fechaIni){
					print RED,"La fecha final no puede ser menor a fecha inicial ($fechaIni), vuelva a ingresar\n",RESET;
					$fechaFinal = <STDIN>;chomp($fechaFinal);
				}
				print GREEN,"\nFecha Inicial: $fechaIni\n";
				print "Fecha Final: $fechaFinal\n",RESET;

				$listaFiltroFecha[0] = $fechaIni;
				$listaFiltroFecha[1] = $fechaFinal;

				listarFiltroRangoFecha;

			}
		}elsif ($opc2 == 5){
			print BOLD BLUE,"Ingrese importe minimo\n",RESET;
			my $importeMin = <STDIN>;chomp($importeMin);

			print BOLD BLUE,"Ingrese importe maximo\n",RESET;
			my $importeMax = <STDIN>;chomp($importeMax);
			while ( $importeMax <= $importeMin){
				print RED,"El importe maximo no puede ser menor o igual al minimo (\$$importeMin), vuelva a ingresar\n", RESET;
				$importeMax = <STDIN>;chomp($importeMax);
			}
			print GREEN,"\nImporte minimo: $importeMin\n";
			print "Importe maximo: $importeMax\n",RESET;

			$listaFiltroImporte[0] = $importeMin;
			$listaFiltroImporte[1] = $importeMax;


			listarFiltroImporte;
		}elsif ($opc2 == 6) {listarSinFiltro;}
	}elsif ($opc == 2){
		$opc2 = 0; $opc3 = 0;
		while ($opc2 != 1 && $opc2 != 2) {
			print BOLD BLUE, "Ingrese el modo de balance\n\n", RESET;

			print "1- Balance por entidad\n";
			print "2- Balance entre dos entidades\n";

			print "Rta: "; 
			$opc2 =<STDIN>;chomp($opc2);
		}
		if ($opc2 == 1){
			
			@listaEntidades;
			print BOLD BLUE,"Ingrese entidad o 'q' para terminar\n",RESET;
			my $entidad = <STDIN>;chomp($entidad);

			while ($entidad ne "q"){
				if ($entidad) {push @listaEntidades, $entidad;}
				print BOLD BLUE,"Ingrese otra entidad o 'q' para finalizar\n",RESET;

				$entidad = <STDIN>;chomp($entidad);
			}
				
			balancearEntidad(@listaEntidades);

		}elsif ($opc2 == 2){
			while ($opc3 != 1){
				print BOLD BLUE,"Ingrese primera entidad\n",RESET;
				$entidad1 = <STDIN>; chomp($entidad1);
				print BOLD BLUE,"Ingrese segunda entidad\n",RESET;
				$entidad2 = <STDIN>; chomp($entidad2);

				print BOLD BLUE, "¿Entidades correctas? $entidad1 \/ $entidad2\n", RESET;
				print "1- Si\n";
				print "2- No\n";
				print "Rta: ";
				$opc3 =<STDIN>;chomp($opc3);
			}

			balancerEntreEntidades($entidad1, $entidad2);
				
			
		}

	}elsif ($opc == 3){
		$opc2 = 0; $opc3 = 0;
		while ($opc2 != 1 && $opc2 != 2){

			print BOLD BLUE,"Ingrese el modo de ranking\n\n",RESET;

			print "1- Ranking TOP 3 entidades mayor INGRESOS\n";
			print "2- Ranking TOP 3 entidades mayor EGRESOS\n";

			print "Rta: ";
			$opc2 = <STDIN>;chomp($opc2);

		}
		if ($opc2 == 1){
			rankearIngresos;
		}elsif($opc2 == 2){
			rankearEgresos;
		}
	}


}
##############################################################################

################################### MAIN ####################################

if (@ARGV > 0){
	mostrarAyuda;
} else {
	verificarAmbiente;


	archivoInput;
	if (keys(%hashFiles) == 0) {die RED,"NO HAY ARCHIVOS VALIDOS.\n",RESET;}
	print GREEN,"\n\nArchivos a Utilizar:\n\n",RESET;
	foreach (keys(%hashFiles)){
		print "$_\n";
	}

	output;
}



##############################################################################