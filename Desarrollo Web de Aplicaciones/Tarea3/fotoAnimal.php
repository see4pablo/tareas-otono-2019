<?php 
require_once('db_config.php');
require_once('consultas.php');

$db = DbConfig::getConnection();

if(isset($_GET['image'])){
  $image=$_GET['image'];

  $sql="SELECT * FROM foto_mascota WHERE id='$image'";
  $result=$db->query($sql);

}

?>

<!DOCTYPE html>
<html lang="es">
    <head>
            <meta charset="utf-8"/>
            <title> Animal</title>
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
            <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css?family=Permanent+Marker" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css?family=Concert+One" rel="stylesheet"> 
            <link rel="stylesheet" type="text/css" href="tarea1.css">
    </head>
    <body>
       
    <div class="text-center " style="width:100%; text-align: center;"> <br><br>
    <img  width='800px' height='600 px' src= <?php echo $result->fetch_assoc()['ruta_archivo'] ?> >
        <br><br>
    </div> <br><br>
    <div class="container" style="width: 20%">
            <button type="button" class="btn btn-outline-dark" onclick="location.href='traslados.php';" value="Home!">Volver</button>
        </div>
    </body>
</html>