<?php
// Star Rating Script - coursesweb.net/php-mysql/

define('SVRATING', 'txt');        // change 'txt' with 'mysql' if you want to save rating data in MySQL

// HERE define data for connecting to MySQL database (MySQL server, user, password, database name)
define('DBHOST', 'localhost');
define('DBUSER', 'root');
define('DBPASS', 'passdb');
define('DBNAME', 'dbname');

// if NRRTG is 0, the user can rate multiple items in a day, if it is 1, the user can rate only one item in a day
define('NRRTG', 0);

// If you want than only the logged users to can rate the element(s) on page, sets USRRATE to 0
// And sets $_SESSION['username'] with the session that your script uses to keep logged users
define('USRRATE', 1);
if(USRRATE !== 1) {
  if(!isset($_SESSION)) session_start();
  if(isset($_SESSION['username'])) define('RATER', $_SESSION['username']);
}

     /* From Here no need to modify */

if(!headers_sent()) header('Content-type: text/html; charset=utf-8');      // header for utf-8

include('class.rating.php');        // Include Rating class
$obRtg = new Rating();

// if data from POST 'elm' and 'rate'
if(isset($_POST['elm']) && isset($_POST['rate'])) {
  // removes tags and external whitespaces from 'elm'
  $_POST['elm'] = array_map('strip_tags', $_POST['elm']);
  $_POST['elm'] = array_map('trim', $_POST['elm']);
  if(!empty($_POST['rate'])) $_POST['rate'] = intval($_POST['rate']);

  echo $obRtg->getRating($_POST['elm'], $_POST['rate']);
}