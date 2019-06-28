$(document).ready(function(){
    $('#search').focus();
  
    $('#search').on('keyup', function(){
      var search = $('#search').val()
      if(search.length >= 3){
      $.ajax({
        type: 'POST',
        url: 'search.php',
        data: {'search': search},
        beforeSend: function(){
          $('#result').html('<img src="img/pacman.gif">');
        }
      })
      .done(function(resultado){
        $('#result').html(resultado);
      })
      .fail(function(){
        console.log("Error");
      })
    } else {
      $('#result').html("");
    }
  
      
      
  });
  });
  