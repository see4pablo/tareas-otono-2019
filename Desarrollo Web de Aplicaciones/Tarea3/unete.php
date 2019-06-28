<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="utf-8"/>
        <title>Únete</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Permanent+Marker" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Concert+One" rel="stylesheet"> 
        <script> var contador_comunas = 0;  </script>
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="tarea1.js"></script>
        <link rel="stylesheet" type="text/css" href="tarea1.css">
    </head>

    <body>
            <br>
        <div class="container"> <img src="icon.png" alt="STALCH" height="60" width="60">
        <div class="avisos" style="color:red">
                        <?php
                                if(isset($_GET['errores'])){
                                echo $_GET['errores']; 
                                }
                        ?>
                </div>
         </div>
        
        <h1 class="title text-center">Únete al equipo!</h1>
        <br>

        <div class="container" style="background-color: rgba(130, 255, 47, 0.696)">
               
                
                <form id="formUnete" method="post" action="procesar_unete.php" enctype='multipart/form-data' onsubmit="return dataValidatorUnete();">
                    <br>
                        <div class="form-group">
                                <label for="nombreVoluntario">Nombre</label>
                                <input type="text" class="form-control" id="nombreVoluntario" name="nombre-voluntario" placeholder="Pepito Pagadoble" maxlength="80">
                        </div>

                        <div class="form-group">
                                <label for="email">Correo electrónico</label>
                                <input type="text" class="form-control" name="email-voluntario" id="email" placeholder="pepitopagadoble@ejemplo.cl" maxlength="30">
                        </div>

                        <div class="form-group">
                                <label for="celular">Número de celular</label>
                                <input type="text" class="form-control" id="celular" name="celular-voluntario" placeholder="+569-XXXX-XXXX" maxlength="15">
                        </div>

                        <div class="form-group"> 
                                <label for="espacioDisponible">Espacio disponible para mascota</label>
                                <select class="form-control" id="espacioDisponible" name="espacio-disponible" onchange="checkEspacio('espacioDisponible');">
                                        <option value="sin-espacio" style="display:none;" selected>selecciona una...</option>
                                            <option value="10x10x10">10x10x10</option>
                                            <option value="20x20x20">20x20x20</option>
                                            <option value="30x30x30">30x30x30</option>
                                            <option value="mas">más...</option>
                                </select>
                                <div class="container" style="background-color: rgba(255, 255, 255, 0)">
                                <input type="text" maxlength="15" style="display:none" id="textoEspacio" name="espacio-disponible-otro">
                        </div>
                        </div>

                        <div class="form-group"> 
                                <label for="regionDisponible1">Región disponible</label>
                                <select class="form-control" id="regionDisponible1" name="region-disponible">
                                        
                                </select>
                        </div>
                        <div class="form-group"> 
                                <label for="comunaDisponible1">Comuna disponible</label>
                                <select class="form-control" id="comunaDisponible1" name="comuna-disponible">        
                                </select>     
                        </div>
                        <div id="lugar2" class="escondido">
                        <div class="form-group"> 
                                <label for="regionDisponible2">Región disponible</label>
                                <select class="form-control" id="regionDisponible2" name="1region-disponible">
                                        
                                </select>
                        </div>
                        <div class="form-group"> 
                                <label for="comunaDisponible2">Comuna disponible</label>
                                <select class="form-control" id="comunaDisponible2" name="1comuna-disponible">        
                                </select>     
                        </div>
                        </div>
                        <div id="lugar3" class="escondido">
                        <div class="form-group"> 
                                <label for="regionDisponible3">Región disponible</label>
                                <select class="form-control" id="regionDisponible3" name="1region-disponible">
                                        
                                </select>
                        </div>
                        <div class="form-group"> 
                                <label for="comunaDisponible3">Comuna disponible</label>
                                <select class="form-control" id="comunaDisponible3" name="1comuna-disponible">        
                                </select>     
                        </div>
                        </div>
                        <div id="lugar4" class="escondido" >
                        <div class="form-group"> 
                                <label for="regionDisponible4">Región disponible</label>
                                <select class="form-control" id="regionDisponible4" name="1region-disponible">
                                        
                                </select>
                        </div>
                        <div class="form-group"> 
                                <label for="comunaDisponible4">Comuna disponible</label>
                                <select class="form-control" id="comunaDisponible4" name="1comuna-disponible">        
                                </select>     
                        </div>
                        </div>
                        
                        <div id="lugar5" class="escondido">
                        <div class="form-group"> 
                                <label for="regionDisponible5">Región disponible</label>
                                <select class="form-control" id="regionDisponible5" name="1region-disponible">
                                        
                                </select>
                        </div>
                        <div class="form-group"> 
                                <label for="comunaDisponible5">Comuna disponible</label>
                                <select class="form-control" id="comunaDisponible5" name="1comuna-disponible">        
                                </select>     
                        </div>
                        </div>

                       
                        <div class="form-group">
                                <span id="agregarComuna" >+ agregar otra ubicación</span>
                        </div>

                        <div class="form-group">
                                <label for="descripcionVoluntario">Cuentanos de ti</label>
                                <textarea class="form-control" name="descripcion-voluntario" id="descripcionVoluntario" rows="8" cols="40"  maxlength="500" placeholder="cuéntanos de ti..."></textarea>
                        </div>

                        <button type="submit" class="btn btn-primary mb-2">Enviar info</button>

                        

                </form>
        </div>

        <br>
        <div class="container" style="width: 20%">
        <button type="button" class="btn btn-outline-dark" onclick="location.href='index.php';" value="Home!">Volver</button>
        </div>  
        <script>
              jQuery(document).ready(function () {
                regionComunaSetter("regionDisponible1","comunaDisponible1");
                regionComunaSetter("regionDisponible2","comunaDisponible2");
                regionComunaSetter("regionDisponible3","comunaDisponible3");
                regionComunaSetter("regionDisponible4","comunaDisponible4");
                regionComunaSetter("regionDisponible5","comunaDisponible5");
                })

              let contador=0;
              let j=0;
              const k= document.querySelector("#agregarComuna");
              k.addEventListener("click", ()=>{
                if(document.getElementsByName("region-disponible")[contador].value == "sin-region" || document.getElementsByName("comuna-disponible")[contador].value == "sin-comuna"){
                              alert("Agrega una comuna antes de querer agregar más!");
              }
                      else{
                              if(contador<4){
                                      
                                      contador++;
                                      console.log(contador);
                                      j = contador + 1;
                                      console.log("lugar"+j);
                                      document.getElementById("lugar"+j).style.display='block';      
                              }
                              else{
                                      alert("Has alcanzado el máximo número de comunas");
                              }
                      }
              })  
        </script>
    </body>
</html>