<?php

/**
 * Validación fecha
 */
function checkDate1($post,$fecha){
	if(!isset($post[$fecha])){
		return false; 
	}
	$now = date('Y-m-d');
	if($now <= $post[$fecha]){
		return true;
	}
	return false;
}
function checkDateTest($fecha){
	$now = date('Y-m-d');
	if($now <= $fecha){
		return true;
	}
	return false;
}



/**
 * Validación general, se valida que el campo esté setteado
 */
function check($post,$campo){
	return isset($post,$campo);
}




?>