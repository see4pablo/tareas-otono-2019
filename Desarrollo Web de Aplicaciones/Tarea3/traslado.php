<!DOCTYPE html>

<html lang="es">
    <head>
        <meta charset="utf-8"/>
        <title>Agenda tu traslado</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Permanent+Marker" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Concert+One" rel="stylesheet"> 
        <script > var contador_comunas = 0;  </script>
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="tarea1.js"></script> 
        <link rel="stylesheet" type="text/css" href="tarea1.css">
    </head>

    <body>  
        
        <br>
        <div class="container"> <img src="icon.png" alt="STALCH" height="60" width="60"> <br> 
                <div class="avisos" style="color: red">
                        <?php
                                if(isset($_GET['errores'])){
                                echo $_GET['errores']; 
                                }
                        ?>
                </div>
        </div>
        
        <h1 class="title text-center">Agenda tu traslado animal</h1>
        <br>
         
        <div class="container" style="background-color:rgba(0, 191, 255, 0.4);">
                <br>
            <form id="formTraslado" method="post" enctype='multipart/form-data'  action="procesar_traslado.php" onsubmit="return dataValidatorTraslado();">
                <div class="form-group">
                <label for="regionOrigen">Región de origen</label>
                <select class="form-control" id="regionOrigen" name="region-origen">
                </select>
                </div>
                
                <div class="form-group">
                <label for="comunaOrigen">Comuna de origen</label>
                <select class="form-control" id="comunaOrigen" name="comuna-origen">
                </select>
                </div>

                <div class="form-group">
                <label for="regionDestino">Región de destino</label>
                <select class="form-control" id="regionDestino" name="region-destino">
                        
                </select>
                </div>

                <div class="form-group"> 
                <label for="comunaDestino">Comuna de destino</label>
                <select class="form-control" id="comunaDestino" name="comuna-destino">
                        
                </select>
                </div>

                <div class="form-group">
                        <label for="fechaViaje">Fecha de viaje</label>
                        <input type="text" class="form-control" id="fechaViaje" name="fecha-viaje" placeholder="AAAA-MM-DD" maxlength="10">
                </div>

                <div class="form-group"> 
                        <label for="espacioNecesario">Espacio necesario para mascota</label>
                        <select class="form-control" id="espacioNecesario" name="espacio-necesario" onchange="checkEspacio('espacioNecesario');">
                                <option value="sin-espacio" style="display:none;" selected>selecciona una...</option>
                                    <option value="10x10x10">10x10x10</option>
                                    <option value="20x20x20">20x20x20</option>
                                    <option value="30x30x30">30x30x30</option>
                                    <option value="mas">más</option>
                        </select>
                        <div class="container" style="background-color: rgba(255, 255, 255, 0)">
                        <input type="text" maxlength="15" style="display:none" id="textoEspacio" name="espacio-necesario-otro">
                </div>
                </div>

                <div class="form-group"> 
                <label for="tipoMascota">Selecciona tu mascota</label>
                <select class="form-control" id="tipoMascota" name="Tipo-mascota">
                        <option value="sin-mascota" style="display:none;" selected>selecciona una...</option>
                            <option value="perro">perro</option>
                            <option value="gato">gato</option>
                            <option value="hámster">hámster</option>
                            <option value="tortuga">tortuga</option>
                            <option value="conejo">conejo</option>
                            <option value="otro">otro</option>
                </select>
                </div>

                <div class="form-group fotos">
                        <label for="fotoMascota">Sube una foto de tu mascota</label>
                        <div id="ingresar">
                        <input type="file" class="form-control-file" id="fotoMascota" name="Foto-mascota[]"  >
                        </div>
                        <span id="agregarfoto" >+ agregar foto</span>
                </div>

                <div class="form-group">
                        <label for="descripcionMascota">Describe a tu mascota</label>
                        <textarea class="form-control" name="descripcion-mascota" id="descripcionMascota" rows="8" cols="40"  maxlength="500" placeholder="cuéntanos de ella..."></textarea>
                      </div>

                <div class="form-group">
                        <label for="nombreContacto">Nombre de contacto</label>
                        <input type="text" class="form-control" id="nombreContacto" name="nombre" placeholder="Pepito Pagadoble" maxlength="80">
                </div>

                <div class="form-group">
                        <label for="email">Correo electrónico</label>
                        <input type="text" class="form-control" name="email" id="email" placeholder="pepitopagadoble@ejemplo.cl" maxlength="30">
                </div>

                <div class="form-group">
                        <label for="celular">Número de celular de contacto</label>
                        <input type="text" class="form-control" id="celular" name="celular" placeholder="+569-XXXX-XXXX" maxlength="15">
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
                regionComunaSetter("regionOrigen","comunaOrigen");
                regionComunaSetter("regionDestino","comunaDestino");
        } )

        let i = 0;
        const k = document.querySelector("#agregarfoto");
        k.addEventListener("click",()=>{
                if(document.getElementsByName("Foto-mascota[]")[i].files.length==0){
                        alert("Agrega una foto antes de solicitar otra porfa");
                }
                else{
                if(i<4){

                
                i++;
                let nuevaFoto = document.createElement("input");
                nuevaFoto.setAttribute("type","file");
                nuevaFoto.setAttribute("class","form-control-file");
                nuevaFoto.setAttribute("name","Foto-mascota[]");
                document.querySelector("#ingresar").appendChild(nuevaFoto);
                }
                else{
                        alert("Has alcanzado el máximo numero de fotos!");
                }
        }
        });
    </script>
</body>
</html>