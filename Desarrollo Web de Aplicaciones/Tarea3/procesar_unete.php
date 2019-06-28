<?php

require_once("validaciones.php");
require_once('db_config.php');
require_once('consultas.php');

error_reporting(E_ALL & E_STRICT);
ini_set('display_errors', '1');
ini_set('log_errors', '0');
ini_set('error_log', './');

$errores = array();
if(!check($_POST,'nombre-voluntario')){
	array_push($errores,"Nombre no válido"); //errores[]="Nombre novalido"
}
if(!check($_POST, 'region-disponible')){
	array_push($errores,"Región no válida");
}

if(!check($_POST, 'comuna-disponible')){
	array_push($errores,"Comuna no válida");
}
if(!check($_POST, 'espacio-disponible')){
    array_push($errores,"Espacio no válido");
}
if(!check($_POST, 'descripcion-voluntario')){
	array_push($errores,"Descripción no válida");
}
if(!check($_POST, 'email-voluntario')){
	array_push($errores,"Email no válido");
}
if(!check($_POST, 'celular-voluntario')){
	array_push($errores,"Celular no válido");
}

if(count($errores)>0){//Si el arreglo $errores tiene elementos, debemos mostrar el error.
	header("Location: traslado.php?errores=".implode("<br>",$errores));//Redirigimos al formulario inicio con los errores encontrados
	return; //No dejamos que continue la ejecución
}

//Si llegamos aqui, las validaciones pasaron


$regionDisponible = $_POST['region-disponible'];
$comunaDisponible = $_POST['comuna-disponible'];
$espacioDisponible = $_POST['espacio-disponible'];
$espacioNuevo = $_POST['espacio-disponible-otro'];
$descripcionVoluntario = $_POST['descripcion-voluntario'];
$nombreVoluntario  = $_POST['nombre-voluntario'];
$emailVoluntario = $_POST['email-voluntario'];
$celularVoluntario = $_POST['celular-voluntario'];


//Guardamos en base de datos
$db = DbConfig::getConnection();
$res = saveUnete($db, $regionDisponible,$comunaDisponible, $espacioDisponible, $descripcionVoluntario, $nombreVoluntario, $emailVoluntario, $celularVoluntario,$espacioNuevo );
echo($db->error);
$db->close();
if(!$res){
	header("Location: index.php?operacion=-1"); //error en la base de datos
}
else{
header("Location: index.php?operacion=1"); //operacion exitosa id 1
}
?>
