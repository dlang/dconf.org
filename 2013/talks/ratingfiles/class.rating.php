<?php
class Rating {
  // properties
  static protected $conn = false;            // stores the connection to mysql
  public $affected_rows = 0;        // number of affected, or returned rows in SQL query
  protected $rater = '';                    // the user who rate, or its IP
  protected $nrrtg = 0;                 // if it is 1, the user can rate only one item in a day, 0 for multiple items
  protected $svrating = 'd';         // 'mysql' to register data in database, any other value register in TXT files
  public $rtgitems = 'rtgitems';        // Table /or file_name to store items that are ranted
  public $rtgusers = 'rtgusers';             // Table /or filename that stores the users who rated in current day
  protected $tdy;                // will store the number of current day
  public $eror = false;          // to store and check for errors

  // constructor
  public function __construct() {
    // sets $nrrtg, $svrating, $rater, and $tdy properties
    if(defined('NRRTG')) $this->nrrtg = NRRTG;
    if(defined('SVRATING')) $this->svrating = SVRATING;
    if(defined('USRRATE') && USRRATE === 0) { if(defined('RATER')) $this->rater = RATER; }
    else $this->rater = $_SERVER['REMOTE_ADDR'];
    $this->tdy = date('j');

    // if set to use TXT files, set the path and name of the files
    if($this->svrating != 'mysql') {
      $this->rtgitems = '../ratingtxt/'.$this->rtgitems.'.txt';
      $this->rtgusers = '../ratingtxt/'.$this->rtgusers.'.txt';
    }
  }

  // for connecting to mysql
  protected function setConn() {
    try {
      // Connect and create the PDO object
      self::$conn = new PDO("mysql:host=".DBHOST."; dbname=".DBNAME, DBUSER, DBPASS);

      // Sets to handle the errors in the ERRMODE_EXCEPTION mode
      self::$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

      self::$conn->exec('SET CHARACTER SET utf8');      // Sets encoding UTF-8
      
    }
    catch(PDOException $e) {
      $this->eror = 'Unable to connect to MySQL: '. $e->getMessage();
    }
  }

  // Performs SQL queries
  public function sqlExecute($sql) {
    if(self::$conn===false OR self::$conn===NULL) $this->setConn();      // sets the connection to mysql
    $re = true;           // the value to be returned

    // if there is a connection set ($conn property not false)
    if(self::$conn !== false) {
      // gets the first word in $sql, to determine whenb SELECT query
      $ar_mode = explode(' ', trim($sql), 2);
      $mode = strtolower($ar_mode[0]);

      // performs the query and get returned data
      try {
        if($sqlprep = self::$conn->prepare($sql)) {
          // execute query
          if($sqlprep->execute()) {
            // if $mode is 'select', gets the result_set to return
            if($mode == 'select') {
              $re = array();
              // if fetch() returns at least one row (not false), adds the rows in $re for return
              if(($row = $sqlprep->fetch(PDO::FETCH_ASSOC)) !== false){
                do {
                  // check each column if it has numeric value, to convert it from "string"
                  foreach($row AS $k=>$v) {
                    if(is_numeric($v)) $row[$k] = $v + 0;
                  }
                  $re[] = $row;
                }
                while($row = $sqlprep->fetch(PDO::FETCH_ASSOC));
              }
              $this->affected_rows = count($re);                   // number of returned rows
            }
          }
          else $this->eror = 'Cannot execute the sql query';
        }
        else {
          $eror = self::$conn->errorInfo();
          $this->eror = 'Error: '. $eror[2];
        }
      }
      catch(PDOException $e) {
        $this->eror = $e->getMessage();
      }
    }

    // sets to return false in case of error
    if($this->eror !== false) { echo $this->eror; $re = false; }
    return $re;
  }

  // returns JSON string with item:['totalrate', 'nrrates', renot] for each element in $items array 
  public function getRating($items, $rate = '') {
    $rtgstdy = $this->rtgstdyCo($items);     // gets from Cookie array with items ranked by the user today

    // if $rate not empty, perform to register the rating, $items contains one item to rate
    if(!empty($rate)) {
      // if $rater empty means user not loged
      if($this->rater === '') return "alert('Vote Not registered.\\nYou must be logged in to can rate')";
      else {
        // gets array with items rated today from mysql, or txt-files (according to $svrating), and merge unique to $rtgstdy
        if($this->svrating == 'mysql') {
          $rtgstdy = array_unique(array_merge($rtgstdy, $this->rtgstdyDb()));
        }
        else {
          $all_rtgstdy = $this->rtgstdyTxt();     // get 2 array: 'all'-rows ranked today, 'day'-items by rater today
          $rtgstdy = array_unique(array_merge($rtgstdy, $all_rtgstdy[$this->tdy]));
        }

        // if already rated, add in cookie, returns JSON from which JS alert message and will reload the page
        // else, accesses the method to add the new rating, in mysql or TXT file
        if(in_array($items[0], $rtgstdy)) {
          $rtgstdy[] = $items[0];
          setcookie("ratings", implode(',', array_unique($rtgstdy)), strtotime('+100 years'));
          return '{"'.$items[0].'":[0,0,3]}';
        }
        else if($this->svrating == 'mysql') $this->setRtgDb($items, $rate, $rtgstdy);       // add the new rate in mysql
        else $this->setRtgTxt($items, $rate, $all_rtgstdy);          // add the new rate, and rater in TXT files

       array_push($rtgstdy, $items[0]);        // adds curent item as rated
     }
    }

    // if $nrrtg is 1, and $rtgstdy has item, set $setrated=1 (user already ranked today)
    // else, user can rate multiple items, after Select is checked if already rated the existend $item
    $setrated = ($this->nrrtg === 1 && count($rtgstdy) > 0) ? 1 : 0;

    // get array with items and their ratings from mysql or TXT file
    $rtgitems = ($this->svrating == 'mysql') ? $this->getRtgDb($items, $rtgstdy, $setrated) : $this->getRtgTxt($items, $rtgstdy, $setrated);

    return json_encode($rtgitems);
  }

  // insert /update rating item in #rtgitems, delete rows in $rtgusers which are not from today, insert $rater in $rtgusers
  protected function setRtgDb($items, $rate, $rtgstdy) {
    $this->sqlExecute("INSERT INTO `$this->rtgitems` (`item`, `totalrate`) VALUES ('".$items[0]."', $rate) ON DUPLICATE KEY UPDATE `totalrate`=`totalrate`+$rate, `nrrates`=`nrrates`+1");

    $this->sqlExecute("DELETE FROM `$this->rtgusers` WHERE `day`!=$this->tdy");

    $this->sqlExecute("INSERT INTO `$this->rtgusers` (`day`, `rater`, `item`) VALUES ($this->tdy, '$this->rater', '".$items[0]."')");

    // add curent rated item to the others today, and save them as string ',' in cookie (till the end of day)
    $rtgstdy[] = $items[0];
    setcookie("ratings", implode(',', array_unique($rtgstdy)), strtotime('+100 years'));
  }

  // select 'totalrate' and 'nrrates' of each element in $items, $rtgstdy stores items rated by the user today
  // returns array with item:['totalrate', 'nrrates', renot] for each element in $items array
  protected function getRtgDb($items, $rtgstdy, $setrated) {
    $re = array_fill_keys($items, array(0,0,$setrated));    // makes each value of $items as key with an array(0,0,0)

    function addSlhs($elm){return "'".$elm."'";}      // function to be used in array_map(), adds "'" to each $elm
    $resql = $this->sqlExecute("SELECT * FROM `$this->rtgitems` WHERE `item` IN(".implode(',', array_map('addSlhs', $items)).")");
    if($this->affected_rows > 0) {
      for($i=0; $i<$this->affected_rows; $i++) {
        $rated = in_array($resql[$i]['item'], $rtgstdy) ? $setrated + 1 : $setrated;   // add 1 if the item was ranked by the user today
        $re[$resql[$i]['item']] = array($resql[$i]['totalrate'], $resql[$i]['nrrates'], $rated);
      }
    }

    return $re;
  }

  // add /update rating item in TXT file, keep rows from today in $rtgusers, and add new row with $rater
  protected function setRtgTxt($items, $rate, $all_rtgstdy) {
    // get the rows from file with items, if exists
    if(file_exists($this->rtgitems)) {
      $rows = file($this->rtgitems, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
      $nrrows = count($rows);

      // if exist rows registered, get array for each row, with - item^totalrate^nrrates
      // if row with item, update it and stop, else, add the row at the end
      if($nrrows > 0) {
        for($i=0; $i<$nrrows; $i++) {
          $row = explode('^', $rows[$i]);
          if($row[0] == $items[0]) {
            $rows[$i] = $items[0].'^'.($row[1] + $rate).'^'.($row[2] + 1);
            $rowup = 1; break;
          }
        }
      }
    }
    if(!isset($rowup)) $rows[] = $items[0].'^'.$rate.'^1';

    file_put_contents($this->rtgitems, implode(PHP_EOL, $rows));      // save the items in file

    // add row with curent item rated and the rater (today^rater^item), and save all the rows
    $all_rtgstdy['all'][] = $this->tdy.'^'.$this->rater.'^'.$items[0];
    file_put_contents($this->rtgusers, implode(PHP_EOL, $all_rtgstdy['all']));

    // add curent rated item to the others today, and save them as string ',' in cookie (till the end of day)
    $all_rtgstdy[$this->tdy][] = $items[0];
    setcookie("ratings", implode(',', array_unique($all_rtgstdy[$this->tdy])), strtotime('+100 years'));
  }

  // get from TXT 'totalrate' and 'nrrates' of each element in $items, $rtgstdy stores items rated by the user today
  // returns array with item:['totalrate', 'nrrates', renot] for each element in $items array
  protected function getRtgTxt($items, $rtgstdy, $setrated) {
    $re = array_fill_keys($items, array(0,0,$setrated));    // makes each value of $items as key with an array(0,0,0)

    if(file_exists($this->rtgitems)) {
      $rows = file($this->rtgitems, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
      $nrrows = count($rows);

      // if exist rows registered, get array for each row, with - item^totalrate^nrrates
      // if row with item is in $items, add its data in $re
      if($nrrows > 0) {
        for($i=0; $i<$nrrows; $i++) {
          $row = explode('^', $rows[$i]);
          $rated = in_array($row[0], $rtgstdy) ? $setrated + 1 : $setrated;   // add 1 if the item was ranked by the user today
          if(in_array($row[0], $items)) $re[$row[0]] = array($row[1], $row[2], $rated);
        }
      }
    }

    return $re;
  }

  // gets and returns from Cookie an array with items ranked by the user ($rater) today
  protected function rtgstdyCo() {
    $rtgstdy = array();

    // if exists cookie 'ratings', adds items rated today in $rtgstdy (array_filter() - removes null, empty elements)
    if(isset($_COOKIE['ratings'])) {
      $rtgstdy = array_filter(explode(',', $_COOKIE['ratings']));     // cookie stores string with: item1, item2, ...
    }

    return $rtgstdy;
  }

  // returns from mysql an array with items ranked by the user today
  protected function rtgstdyDb() {
    $rtgstdy = array();
    $resql = $this->sqlExecute("SELECT `item` FROM `$this->rtgusers` WHERE `day`=$this->tdy AND `rater`='$this->rater'");
    if($this->affected_rows > 0) {
      for($i=0; $i<$this->affected_rows; $i++) {
        $rtgstdy[] = $resql[$i]['item'];
      }
    }

    return $rtgstdy;
  }

  // returns from TXT file an array with 2 arrays: all rows ranked today, and items ranked by the user today
  protected function rtgstdyTxt() {
    $re['all'] = array();  $re[$this->tdy] = array();
    if(file_exists($this->rtgusers)) {
      $rows = file($this->rtgusers, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
      $nrrows = count($rows);

      // if exist rows registered, get array for each row, with - day^rater^item , compare 'day', and 'rater'
      if($nrrows > 0) {
        for($i=0; $i<$nrrows; $i++) {
          $row = explode('^', $rows[$i]);
          if($row[0] == $this->tdy) {
            $re['all'][] = $rows[$i];
            if($row[1] == $this->rater) $re[$this->tdy][] = $row[2];
          }
        }
      }
    }

    return $re;
  }
}