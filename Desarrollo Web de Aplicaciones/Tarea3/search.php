<?php 
if(!isset($_POST['search'])) exit('No se recibió el valor a buscar');

require_once 'db_config.php';

function search()
{
  $mysqli = DbConfig::getConnection();
  $search = $mysqli->real_escape_string($_POST['search']);
  $query = "SELECT * FROM voluntario WHERE nombre_voluntario LIKE '%$search%' ";
	$res = $mysqli->query($query);
	$x = array();
  if ($res->num_rows == 0){
	echo "<p>No se encontraron resultados</p>";	
	}
  else{	
	echo "<ul class='w3-animate-right'>";
	while ($row = $res->fetch_array(MYSQLI_ASSOC)) {
   	 echo "<li><a href='perfilVoluntario.php?id=". $row['id'] ."'>$row[nombre_voluntario]</a></li>";
  	}
	echo "</ul>";
}  
}

search(); ?>
