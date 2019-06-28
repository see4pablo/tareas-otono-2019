<?php
  require_once('db_config.php');
  require_once('consultas.php');

  $db = DbConfig::getConnection();

  if(isset($_GET['page'])){
    $page=$_GET['page'];
  }
  else{
    $page=1;
  }

  $num_per_page=5;
  $start_from = ($page-1)*$num_per_page;

  $query = " SELECT * FROM voluntario LIMIT $start_from,$num_per_page";
  $result = $db->query($query);
  
?>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="utf-8"/>
        <title>Ver ayudantes</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Permanent+Marker" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Concert+One" rel="stylesheet"> 
        <link rel="stylesheet" type="text/css" href="tarea1.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
    </head>
    <body>
            <br>
            <div class="container" style="background-color: rgba(250, 0, 33, 0.644); width:35%">
            <h1 class="text-center title">Ayudantes actuales</h1>
            

        </div>
            <br>
            <div class="container">
            <div class="input-group">
		<span class="input-group-addon"><span class="glyphicon glyphicon glyphicon-search" aria-hidden="true"></span></span>
		<input type="text" class="form-control" id="search" placeholder="Busca un voluntario">
	      </div>
		    <br>
	    <div  id="result">
		
	    </div>
      </div>
		 
            </div>

            <div class="container container-table">
            <table class="table table-bordered">
                    <thead>
                      <tr >
                        <th scope="col">#</th>
                        <th scope="col">Nombre</th>
                        <th scope="col">Email</th>
                        <th scope="col">Espacio disponible</th>
                        <th scope="col">Comunas disponibles</th>
                        <th scope="col">Numero de celular</th>
                        
                      </tr>
                    </thead>
                    

                    
                    <tbody>
                      
                      
                      <?php
                       $contador=0;
                        while($data = mysqli_fetch_assoc($result))
                        {
                            $contador++;
                            $idPersona="person".$contador;
                            $idPersonaMas="person".$contador."prof";
                            $comuna=getNameComuna($db,$data['comuna_disponible']);
                            $espacio=getNameEspacio($db,$data['espacio_disponible']);
                      ?>
                      <tr id=<?php echo $idPersona; ?>> 
                        
                        <th scope="row"><?php echo $data['id']; ?></th>
                        <td><?php echo $data['nombre_voluntario']; ?></td>
                        <td><?php echo $data['email_voluntario']; ?></td>
                        <td><?php echo $espacio ?></td>
                        <td><?php echo $comuna ?></td>
                        <td><?php echo $data['celular_voluntario']; ?></td>
                      </tr>
                      <tr id=<?php echo $idPersonaMas; ?> style="display: none">
                      <td colspan="6">
                          <span><?php echo $data['nombre_voluntario'].'<br>'; ?><span>
                          <span><?php echo $data['email_voluntario'].'<br>'; ?><span>
                          <span><?php echo $espacio.'<br>'; ?><span>
                          <span><?php echo $comuna. '<br>'; ?><span>
                          <span><?php echo $data['celular_voluntario'].'<br>'; ?><span>
                          <span><?php echo $data['descripcion']; ?><span>
                          </td>
                        </tr>
                      <?php 
                        }
                      ?>
                      
                      
                      
                    </tbody>
                  </table>
                </div>
                  <br>
                
                <br>
                <div class="container" style="width: 50%"> 
                  <?php
                    $query = "SELECT * FROM voluntario";
                    $pr_result= $db->query($query);
                    $totalrecord = mysqli_num_rows($pr_result);
                    $totalpages=ceil($totalrecord/$num_per_page);

                    for($i=1;$i<=$totalpages;$i++){
                      echo "<a href='staff.php?page=".$i."'class='btn btn-success'>$i</a>";
                    }
                  ?>
                </div>
                <div class="container" style="width: 20%">
                        <button type="button" class="btn btn-outline-dark" onclick="location.href='index.php';" value="Home!">Volver</button>
                        </div>
                        
    <script>
    for(let i=1; i <= <?php echo $contador; ?>;i++){
      document.querySelector("#person"+i).addEventListener("click",()=>{
        for(let j=1; j <= <?php echo $contador; ?>;j++){
          if(i==j){
            document.getElementById("person"+j+"prof").style.display="";
          } 
          else{
            document.getElementById("person"+j+"prof").style.display="none";
          }
        }
        })
      
    }
    
    
    </script>
    <script src='busqueda.js'></script>
    </body>
</html>