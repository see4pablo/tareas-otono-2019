<?php 
require_once('db_config.php');
require_once('consultas.php');

$db = DbConfig::getConnection();

if(isset($_GET['id'])){
  $voluntario=$_GET['id'];

  $sql="SELECT * FROM voluntario WHERE id='$voluntario'";
  $result=$db->query($sql);
  $result=$result->fetch_assoc();
  $idComuna=$result['comuna_disponible'];
  $idEspacio=$result['espacio_disponible'];
  $resultComuna=getNameComuna($db, $idComuna);
  $resultEspacio=getNameEspacio($db, $idEspacio);
}

?>

<!DOCTYPE html>
<html lang="es">
    <head>
            <meta charset="utf-8"/>
            <title> Voluntario </title>
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
            <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css?family=Permanent+Marker" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css?family=Concert+One" rel="stylesheet"> 
            <link rel="stylesheet" type="text/css" href="tarea1.css">
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
    </head>
    <body>
       
    <div class="container" style="margin-top:50px; background-color: LightGray; width: 40%">
        <br> 
            <h3 class="title"> Información de voluntario </h3>
        <br>
        

        <p> <?php  echo $result['nombre_voluntario'] ?> </p>
        <p> <?php  echo $result['email_voluntario'] ?> </p>
        <p> <?php  echo $result['celular_voluntario'] ?> </p>
        <p> <?php  echo $resultComuna ?> </p>
        <p> <?php  echo $resultEspacio ?> </p>
        <p> <?php  echo $result['descripcion'] ?> </p>
        <br> 
    </div> <br>
    <div class="container" style="width: 20%">
        <div class="input-group">
            <span class="input-group-addon"><span class="glyphicon glyphicon glyphicon-search" aria-hidden="true"></span></span>
            <input type="text" class="form-control" id="search" placeholder="Busca otro voluntario">
            </div>
                <br>
            <div  id="result">
		
	    </div>
            <button type="button" class="btn btn-outline-dark" onclick="location.href='index.php';" value="Home!">Volver</button>
        
        </div>

        <script src='busqueda.js'></script>
    </body>


</html>