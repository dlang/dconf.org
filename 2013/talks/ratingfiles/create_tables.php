<?php
include('ratings.php');

// Table that stores the users who rated in current day
$sqlc[$obRtg->rtgusers] = "CREATE TABLE `$obRtg->rtgusers` (`day` INT(2), `rater` VARCHAR(15), `item` VARCHAR(200) NOT NULL DEFAULT '') CHARACTER SET utf8 COLLATE utf8_general_ci";

// Table to store items that are ranted
$sqlc[$obRtg->rtgitems] = "CREATE TABLE `$obRtg->rtgitems` (`item` VARCHAR(200) PRIMARY KEY NOT NULL DEFAULT '', `totalrate` INT(10) NOT NULL DEFAULT 0, `nrrates` INT(9) NOT NULL DEFAULT 1) CHARACTER SET utf8 COLLATE utf8_general_ci";

// traverse the $sqlc array, and calls the method to create the tables
foreach($sqlc AS $tab=>$sql) {
  if($obRtg->sqlExecute($sql) !== false) echo "<h4>The '$tab' table was created</h4>";
}