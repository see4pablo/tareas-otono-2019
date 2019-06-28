<?php

require_once("validaciones.php");
require_once('db_config.php');
require_once('consultas.php');

error_reporting(E_ALL & E_STRICT);
ini_set('display_errors', '1');
ini_set('log_errors', '0');
ini_set('error_log', './');

$errores = array();
if(!check($_POST,'name')){
	array_push($errores,"Nombre no válido"); //errores[]="Nombre novalido"
}
if(!check($_POST,'region-origen')){
	array_push($errores,"Región de origen no válida");
}
if(!check($_POST, 'region-destino')){
	array_push($errores,"Región de destino no válida");
}
if(!check($_POST, 'comuna-origen')){
	array_push($errores,"Comuna de origen no válida");
}
if(!check($_POST, 'comuna-destino')){
	array_push($errores,"Comuna de destino no válida");
}
if(!checkDate1($_POST, 'fecha-viaje')){
	array_push($errores,"Fecha no válida");
}
if(!check($_POST, 'espacio-necesario')){
	array_push($errores,"Espacio no válido");
}
if(!check($_POST, 'Tipo-mascota')){
	array_push($errores,"Mascota no válida");
}
if(!check($_FILES, 'Foto-mascota')){
	array_push($errores,"Foto no válida");
}
if(!check($_POST, 'descripcion-mascota')){
	array_push($errores,"Descripción no válida");
}
if(!check($_POST, 'email')){
	array_push($errores,"Email no válido");
}
if(!check($_POST, 'celular')){
	array_push($errores,"Celular no válido");
}

if(count($errores)>0){//Si el arreglo $errores tiene elementos, debemos mostrar el error.
	header("Location: traslado.php?errores=".implode("<br>",$errores ));//Redirigimos al formulario inicio con los errores encontrados
	return; //No dejamos que continue la ejecución
}

//Si llegamos aqui, las validaciones pasaron


$regionOrigen = $_POST['region-origen'];
$comunaOrigen = $_POST['comuna-origen'];
$regionDestino = $_POST['region-destino'];
$comunaDestino = $_POST['comuna-destino'];
$fechaViaje = $_POST['fecha-viaje'];
$espacioNecesario = $_POST['espacio-necesario'];
$espacioNuevo = $_POST['espacio-necesario-otro'];
$tipoMascota = $_POST['Tipo-mascota'];
$fotoMascota = $_FILES['Foto-mascota'];
$descripcionMascota = $_POST['descripcion-mascota'];
$nombreContacto  = $_POST['nombre'];
$email = $_POST['email'];
$celular = $_POST['celular'];


//Guardamos en base de datos
$db = DbConfig::getConnection();
$res = saveTraslado($db, $regionOrigen,$comunaOrigen, $regionDestino, $comunaDestino, $fechaViaje, $espacioNecesario, $tipoMascota, $fotoMascota, $descripcionMascota, $nombreContacto, $email, $celular,$espacioNuevo );
echo($db->error);
$db->close();
if(!$res){
	header("Location: index.php?operacion=-1"); //error en la base de datos
}
else{
	header("Location: index.php?operacion=1"); //operacion exitosa id 1

}

?>
