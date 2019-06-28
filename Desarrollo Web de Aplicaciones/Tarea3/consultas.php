<?php
/*
Implementar:
1. Preparar SQL para insertar orden: INSERT INTO ordenes (nombre, direccion, comuna, masa, comentario) VALUES ('%s', '%s', %d, %d, '%s')". Usar sprintf y limpiar los campos con la función limpiar(texto);
2. Ejecutar SQL
3. Recuperar el id de la inserción anterior
4. Preparar SQL para insertar los ingredientes: INSERT INTO ordenes_ingredientes (id_orden, id_ingrediente) VALUES (%d, %d).
x6. retornar true si todo salió bien, false si surgió un problema.
*/
function saveTraslado($db, $regionOrigen,$comunaOrigen, $regionDestino, $comunaDestino, $fechaViaje, $espacioNecesario, $tipoMascota, $fotoMascota, $descripcionMascota, $nombreContacto, $email, $celular, $espacioNuevo){
	//insertar o buscar Id Espacio
	print($espacioNecesario . "||" . $espacioNuevo);
	if($espacioNecesario=="mas"){
		$espacioNecesario1_bd=getIdEspacio($db,$espacioNuevo);
		if($espacioNecesario1_bd==NULL){
			$stmt1 = $db->prepare("INSERT INTO espacio (id,valor) VALUES (?,?)");
		$stmt1->bind_param("is",$idEspacioNuevo,$espacioNecesario1_bd);
		$espacioNecesario1_bd=limpiar($db,$espacioNuevo);
		print("ANTES");
		$idEspacioNuevo=getIdEspacioNuevo($db)+1;
		print($idEspacioNuevo);
		if($stmt1->execute()){
			$espacioNecesario1_bd=$idEspacioNuevo;
		}
		else{
			return false;
		}	
	}
		
	}
	else{
		$espacioNecesario1_bd=getIdEspacio($db, limpiar($db, $espacioNecesario));
	} 
	$stmt = $db->prepare("INSERT INTO traslado (comuna_origen, comuna_destino, fecha_viaje, espacio, tipo_mascota_id, descripcion, nombre_contacto, email_contacto, celular_contacto) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
	$stmt->bind_param("iisiissss", $comunaOrigen_bd, $comunaDestino_bd, $fechaViaje_bd, $espacioNecesario_bd, $tipoMascota_bd, $descripcionMascota_bd,$nombreContacto_bd,$email_bd,$celular_bd);
	$regionOrigen_bd=getIdRegion($db,limpiar($db,$regionOrigen));
	$regionDestino_bd=getIdRegion($db,limpiar($db,$regionDestino));
	$comunaOrigen_bd=getIdComuna($db,limpiar($db,$comunaOrigen),$regionOrigen_bd);
	$comunaDestino_bd=getIdComuna($db,limpiar($db,$comunaDestino),$regionDestino_bd);
	$espacioNecesario_bd=$espacioNecesario1_bd;
	$fechaViaje_bd=limpiar($db,$fechaViaje)." 00:00:00";
	$email_bd=limpiar($db,$email);
	$celular_bd=limpiar($db,$celular);
	$nombreContacto_bd=limpiar($db,$nombreContacto);
	$descripcionMascota_bd=limpiar($db,$descripcionMascota);
	print($regionOrigen_bd .'||');
	print($regionDestino_bd .'||');
	print($comunaOrigen_bd .'||');
	print($comunaDestino_bd .'||');
	print($email_bd .'||');
	print($fechaViaje_bd .'||');
	
	print($celular_bd .'||');
	print($espacioNecesario_bd .'||');
	print($nombreContacto_bd .'||');
	print($descripcionMascota_bd .'||');
	
	//insertar o buscar Id mascota, se asume que id 0 es "otro"
	if($tipoMascota=="otro"){
		$tipoMascota_bd=getIdMascota($db,limpiar($db,$tipoMascota));
		if($tipoMascota_bd == NULL){
			$stmt2 = $db->prepare("INSERT INTO tipo_mascota (descripcion) VALUES (?)");
			$stmt2->bind_param("s",$tipoMascota);
			$tipoMascota=limpiar($db,$tipoMascota);
			if($stmt2->execute()){
				$tipoMascota_bd=$db->insert_id;
			}
			else{
				return false;
			}	
		}
	}
	else{
		$tipoMascota_bd=getIdMascota($db,limpiar($db,$tipoMascota));
	}
	print($tipoMascota_bd . '||');
	
	

	// insertar foto en la base de datos

	if ($stmt->execute()) {
		$last_id = $db->insert_id;

		for($contador=0;$contador<5;$contador++) {
			if(isset($fotoMascota['name'][$contador])){
			
			$stmt_foto=$db->prepare("INSERT INTO foto_mascota (ruta_archivo, nombre_archivo, traslado_id) VALUES (?,?,?)");
			$stmt_foto->bind_param("ssd",$ruta_bd,$nombre_bd,$idTraslado_bd);
			$idTraslado_bd=$last_id;
			$photoName = $fotoMascota['name'][$contador];
			$uploadDir = './uploads/'.$last_id. "/"; //path you wish to store you uploaded files
			$uploadedFile = $uploadDir . basename($photoName);
			
			if (!file_exists($uploadDir)){
				mkdir($uploadDir, 0777, true);
			}
			print("|| " . $photoName . "||");
			print($uploadedFile);
			if(move_uploaded_file($fotoMascota['tmp_name'][$contador], $uploadedFile)) {
				print("AAAGH");
				$ruta_bd=$uploadedFile;
				$nombre_bd=$photoName;
				$stmt_foto->execute();
				
			} else {
				return false;
			}
		}}
		return true;
	}
	return false;
}



function saveUnete($db, $regionDisponible,$comunaDisponible, $espacioDisponible, $descripcionVoluntario, $nombreVoluntario, $emailVoluntario, $celularVoluntario,$espacioNuevo ){
	print($espacioDisponible . "||" . $espacioNuevo);
	if($espacioDisponible=="mas"){
		$espacioNecesario1_bd=getIdEspacio($db,$espacioNuevo);
		if($espacioNecesario1_bd==NULL){
			$stmt1 = $db->prepare("INSERT INTO espacio (id,valor) VALUES (?,?)");
		$stmt1->bind_param("is",$idEspacioNuevo,$espacioNecesario1_bd);
		$espacioNecesario1_bd=limpiar($db,$espacioNuevo);
		print("ANTES");
		$idEspacioNuevo=getIdEspacioNuevo($db)+1;
		print($idEspacioNuevo);
		if($stmt1->execute()){
			$espacioNecesario1_bd=$idEspacioNuevo;
		}
		else{
			return false;
		}	
	}
		
	}
	else{
		$espacioNecesario1_bd=getIdEspacio($db, limpiar($db, $espacioDisponible));
	}
	
	$stmt = $db->prepare("INSERT INTO voluntario (nombre_voluntario, email_voluntario, celular_voluntario, espacio_disponible, comuna_disponible, descripcion) VALUES (?, ?, ?, ?, ?, ?)");
	$stmt->bind_param("sssiis", $nombreVoluntario_bd, $emailVoluntario_bd, $celularVoluntario_bd, $espacioDisponible_bd, $comunaDisponible_bd, $descripcionVoluntario_bd);
	$regionDisponible_bd=getIdRegion($db,limpiar($db,$regionDisponible));
	$comunaDisponible_bd=getIdComuna($db,limpiar($db,$comunaDisponible),$regionDisponible_bd);
	$espacioDisponible_bd=$espacioNecesario1_bd;
	$emailVoluntario_bd=limpiar($db,$emailVoluntario);
	$celularVoluntario_bd=limpiar($db,$celularVoluntario);
	$nombreVoluntario_bd=limpiar($db,$nombreVoluntario);
	$descripcionVoluntario_bd=limpiar($db,$descripcionVoluntario);
	if($stmt->execute()){
		return true;
	}
	return false;

}


function limpiar($db, $str){
	return htmlspecialchars($db->real_escape_string($str));
}





function getIdComuna($db, $nombre, $idRegion){
	$sql = "SELECT id, nombre FROM comuna WHERE nombre='$nombre' AND region_id='$idRegion'";
		$result = $db->query($sql);
		$row = $result->fetch_assoc();
	return $row["id"];
}
function getIdEspacio($db, $espacio){
	$sql = "SELECT id, valor FROM espacio WHERE valor='$espacio'";
		$result = $db->query($sql);
		$row = $result->fetch_assoc();
	return $row["id"];
}

function getIdMascota($db, $mascota){
	$sql = "SELECT id, descripcion FROM tipo_mascota WHERE descripcion='$mascota'";
		$result = $db->query($sql);
		$row = $result->fetch_assoc();
	return $row["id"];
}

function getNameMascota($db, $mascota){
	$sql = "SELECT id, descripcion FROM tipo_mascota WHERE id='$mascota'";
		$result = $db->query($sql);
		$row = $result->fetch_assoc();
	return $row["descripcion"];
}

function getIdRegion($db, $nombre){
	$sql = "SELECT id, nombre FROM region WHERE nombre='$nombre'";
		$result = $db->query($sql);
		$row = $result->fetch_assoc();
	return $row["id"];
}
function getNameEspacio	($db, $idEspacio){
	$sql = "SELECT id, valor FROM espacio WHERE id='$idEspacio'";
		$result = $db->query($sql);
		$row = $result->fetch_assoc();
	return $row["valor"];
}

function getNameComuna($db, $idComuna){
	$sql = "SELECT id, nombre FROM comuna WHERE id='$idComuna'";
		$result = $db->query($sql);
		$row = $result->fetch_assoc(); 
	return $row["nombre"];
}
function getNameRegion($db, $idRegion){
	$sql = "SELECT id, nombre FROM region WHERE id='$idRegion'";
		$result = $db->query($sql);
		$row = $result->fetch_assoc();
	return $row["nombre"];
}
function getIdEspacioNuevo($db){
	$sql = "SELECT id , valor FROM espacio";
	$result = $db->query($sql);
	$maxId = 0;
	while ($row = $result->fetch_assoc()) {
		if($row["id"]>$maxId){
			$maxId = $row["id"];
		}
	}
	return $maxId;
}
function parseJsonComunas(){
	// Get the contents of the JSON file 
	$strJsonFileContents = file_get_contents("chile.json");
	// Convert to array 
	$array = json_decode($strJsonFileContents, true);
	return $array;
}
function getFotosUbicaciones($db){
	$sqlTraslados = "SELECT traslado.id as idTraslado, comuna.nombre as nombre FROM traslado, comuna WHERE comuna.id=traslado.comuna_origen";
	$resultTraslados = $db->query($sqlTraslados);
	$arrayTraslados=array();
	while($row = $resultTraslados->fetch_assoc()){
		$arrayTraslados[]=$row;
	}
	$arrayFotosByComuna=array();
	foreach ($arrayTraslados as $traslado){
		$arrayFotos = array();
		$sqlFotos = "SELECT * FROM foto_mascota WHERE traslado_id='$traslado[idTraslado]'";
		$resultFotos = $db->query($sqlFotos);
		while($row = $resultFotos->fetch_assoc()){
			$arrayFotos[] = $row;
		}

		if(isset($arrayFotosByComuna[$traslado['nombre']])){
			$arrayFotosByComuna[$traslado['nombre']][]=$arrayFotos;
		}
		else{
			$arrayFotosByComuna[$traslado['nombre']]=array();
			$arrayFotosByComuna[$traslado['nombre']][]=$arrayFotos;	
		}
	}
	return $arrayFotosByComuna;

		
}

/*
function getOrders($db){
	$sql = "SELECT ordenes.id, ordenes.nombre, ordenes.direccion, comunas.nombre as comuna_nombre, ordenes.masa
	FROM ordenes, comunas
	WHERE ordenes.comuna = comunas.id";
	$result = $db->query($sql);
	$res = array();
	while ($row = $result->fetch_assoc()) {
		$res[] = $row;
	}
	return $res;
} */


?>
