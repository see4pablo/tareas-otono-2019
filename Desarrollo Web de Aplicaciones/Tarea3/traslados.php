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

  $query = " SELECT * FROM traslado LIMIT $start_from,$num_per_page";
  $result = $db->query($query);
  
?>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="utf-8"/>
        <title>Ver Traslados</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Permanent+Marker" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Concert+One" rel="stylesheet"> 
        <link rel="stylesheet" type="text/css" href="tarea1.css">
    </head>
    <body>
        
        <br>

      
        <br>
        <div class="container" style="background-color: rgba(255, 255, 0, 0.611); width:35%">
        <h1 class="title text-center">Traslados actuales</h1>
    </div>
        <br>
        <div class="container container-table">
        <table class="table table-bordered">
                <thead>
                  <tr>
                    <th scope="col">#</th>
                    <th scope="col">Origen</th>
                    <th scope="col">Destino</th>
                    <th scope="col">Fecha de viaje</th>
                    <th scope="col">Espacio</th>
                    <th scope="col">Tipo mascota</th>
                  </tr>
                </thead>
                <tbody>
                  
                  <?php
                       $contador=0;
                        while($data = mysqli_fetch_assoc($result))
                        {
                            $contador++;
                            $idAnimal="a".$contador;
                            $idAnimalMas="animal".$contador;
                            $id=$data['id'];
                            $comunaOrigen=getNameComuna($db,$data['comuna_origen']);
                            $comunaDestino=getNameComuna($db,$data['comuna_destino']);
                            $espacio=getNameEspacio($db,$data['espacio']);
                            $mascota=getNameMascota($db,$data['tipo_mascota_id']);
                            
                      ?>
                      <tr id=<?php echo $idAnimal; ?>> 
                        
                        <th scope="row"><?php echo $id; ?></th>
                        <td><?php echo $comunaOrigen; ?></td>
                        <td><?php echo $comunaDestino; ?></td>
                        <td><?php echo $data['fecha_viaje'] ?></td>
                        <td><?php echo $espacio ?></td>
                        <td><?php echo $mascota; ?></td>
                      </tr>
                      <tr id=<?php echo $idAnimalMas; ?> style="display: none">
                      <td colspan="6">
                          <span><?php echo $comunaOrigen.'<br>'; ?></span>
                          <span><?php echo $comunaDestino.'<br>'; ?></span>
                          <span><?php echo $data['fecha_viaje'].'<br>'; ?></span>
                          <span><?php echo $espacio. '<br>'; ?></span>
                          <span><?php echo $mascota.'<br>'; ?></span>
                          <span><?php echo $data['nombre_contacto'].'<br>'; ?></span>
                          <span><?php echo $data['email_contacto'].'<br>'; ?></span>
                          <span><?php echo $data['celular_contacto'].'<br>'; ?></span>
                          <span><?php echo $data['descripcion'].'<br>'; ?></span>
                          <span>
                          <?php
                            $sql2="SELECT * FROM foto_mascota WHERE traslado_id='$id'";
                            $resultFoto=$db->query($sql2);
                            while($row = mysqli_fetch_assoc($resultFoto)){
                              $idFoto=$row['id'];
                              echo "<div>";
                              echo "<a href='fotoAnimal.php?image=".$idFoto."'><img  width='320px' height='240 px' src='".$row['ruta_archivo']."' ></a>";
                              echo "</div>";
                              echo "<br>";
                            }
                          ?>
                          
                          </span>
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
                    $query = "SELECT * FROM traslado";
                    $pr_result= $db->query($query);
                    $totalrecord = mysqli_num_rows($pr_result);
                    $totalpages=ceil($totalrecord/$num_per_page);

                    for($i=1;$i<=$totalpages;$i++){
                      echo "<a href='traslados.php?page=".$i."'class='btn btn-success'>$i</a>";
                    }
                  ?>
                </div>
            <div class="container" style="width: 20%">
                    <button type="button" class="btn btn-outline-dark" onclick="location.href='index.php';" value="Home!">Volver</button>
                    </div>  

    <script>
    
    for(let i=1;i<= <?php echo $contador; ?>;i++){

      document.getElementById("a"+i).addEventListener("click",()=>{
        for(let j=1;j<= <?php echo $contador;?>;j++){
          if(i==j){
            document.getElementById("animal"+j).style.display="";
          }
          else{
            document.getElementById("animal"+j).style.display="none";
          }
        }
      })
    }

    document.querySelectorAll(".foto-animal").forEach(function(item){
      item.addEventListener("click",()=>{
      location.href="exampleanimal.html"
    })
    })
    </script>
    </body>
</html>