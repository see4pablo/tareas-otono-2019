<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="utf-8"/>
        <title>STAL Chile</title>
        
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css" integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA==" crossorigin=""/>
        <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js" integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg==" crossorigin=""></script>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Permanent+Marker" rel="stylesheet">
	 <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css"> 
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>

        <link rel="stylesheet" type="text/css" href="tarea1.css">
       <style>
           .leaflet {
               margin: auto;
           }
           </style>
    
    </head>

    

    <body>
        <br>
        <div class="container ">
            <br>
            <div>   
                <h1 class="title">  <img src="icon.png" alt="STALCH" height="42" width="42"> STALCH</h1>
                <h3 class="title">Servicio de Traslado de Animales</h3> <br>
		
		   
	      <div class="input-group">
		<span class="input-group-addon"><span class="glyphicon glyphicon glyphicon-search" aria-hidden="true"></span></span>
		<input type="text" class="form-control" id="search" placeholder="Busca un voluntario">
	      </div>
		    <br>
	    <div  id="result">
		
	    </div>
		 
            </div>
           
            <?php
                                if(isset($_GET['operacion'])){
                                    if($_GET['operacion']==1){
                                        echo "<div style='color: blue'>Operación exitosa</div>";
                                    }
                                    if($_GET['operacion']==-1){
                                        echo "<div style='color: red'>Operación fallida: error en la base de datos</div>";
                                    }
                                 
                                }
                        ?>
    
            <br>
            ¿Necesitas ayuda para trasladar a tu animal?, prueba nuestro servicio STALCH online para buscar algun ayudante STACH 
                 ¿Quieres ser parte del equipo STALCH? únete a nuestra red de voluntarios, los animales te lo agradecerán
        
                 <br>
                 <br>
            <button type="button" class="btn btn-primary" onclick="location.href='traslado.php';" value="Pide tu traslado!">Solicitar traslado</button>
            <button type="button" class="btn btn-warning" onclick="location.href='traslados.php';" value="Ir a traslados">Lista de traslados</button>
            <button type="button" class="btn btn-success" onclick="location.href='unete.php';" value="Únete al equipo!">Postula de ayudante</button>
            <button type="button" class="btn btn-danger" onclick="location.href='staff.php';" value="Ver staff actual">Ayudantes</button>
       </div>

    <br><br>
    <div id='map' style='width: 100%; height: 600px;'></div>
<script>
  // initialize the map on the "map" div with a given center and zoom
  var map = L.map('map', {
    center: [-33.437, -70.6506],
    zoom: 5
});
<?php 
require_once 'db_config.php';
require_once 'consultas.php';
$db = DbConfig::getConnection();
$fotosByComuna = getFotosUbicaciones($db);
$jsonArray = parseJsonComunas();
//L.marker([-33.437, -70.6506], {title: 'Texto'}).addTo(map).bindPopup("<b>Hola busca a tu perrito</b>").openPopup();


foreach($fotosByComuna as $nombreComuna => $gruposFotos){
    $contador=0;
    $latitud=0;
    $longitud=0;
    foreach($jsonArray as $locComuna){
        if($locComuna['name']==$nombreComuna){
            $latitud=$locComuna['lat'];
            $longitud=$locComuna['lng'];
            break;
        }
    }
    $html="'<table>";
    $htmlInterno="";
    foreach($gruposFotos as $grupoFoto){
        foreach($grupoFoto as $foto){
            $contador++;
            $htmlInterno = $htmlInterno . '<tr><td><a href="fotoAnimal.php?image='. $foto['id'] .'" > <img height="40px" width="60px" src="'. $foto['ruta_archivo']. '" </a> </td></tr> ' ;
    
        }
        }
    $html=$html . $htmlInterno . "</table>'";

    echo "L.marker([". $latitud .", ". $longitud ."], {title: 'Cantidad de Fotos: ". $contador ."'}).addTo(map).bindPopup(". $html ."); \n";

}

?>
L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
    attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
    maxZoom: 18,
    id: 'mapbox.streets',
    accessToken: 'pk.eyJ1IjoicGFibG9vYWxpYWdhIiwiYSI6ImNqdXJtY2w0YjBqYnIzeXA4cmZnc3l6NWQifQ.RXvMmLQOm09ZeLFjxkm8Tw'
}).addTo(map);
</script>
<script src='busqueda.js'></script>

    </body>


    
</html>
