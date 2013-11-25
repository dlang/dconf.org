// Ajax Star Rating Script - http://www.coursesweb.net
var sratings = Array();			// store the items with rating
var ar_elm = Array();	   	// store the items that will be send to rtgAjax()
var srated = '';		      // store the rated value that will be send to rtgAjax()
var i_elm = 0;					// Index for elements aded in ar_elm
var itemrated_rtg = '';       // store the rating of rated item

// gets all DIVs, then add in $ar_elm the DIVs with class="srtgs", and ID which begins with "rt_", and sends to rtgAjax()
var getRtgsElm = function () {
  obj_div = document.getElementsByTagName('div');
  for(var i=0; i<obj_div.length; i++) {
    // if contains class and id
    if(obj_div[i].className && obj_div[i].id) {
	  var val_id = obj_div[i].id;
      // if class="srtgs" and id begins with "rt_"
      if(obj_div[i].className=='srtgs' && val_id.indexOf("rt_")==0) {
	    sratings[val_id] = obj_div[i];
	    ar_elm[i_elm] = val_id;
	    i_elm++;
	  }
    }
  }
  // If there are elements with rates, send them to rtgAjax()
  if(ar_elm.length>0) rtgAjax(ar_elm, srated);      // if items in $ar_elm pass them to rtgAjax()
};

// shows the stars when the user is voting
function rateStars(spn) {
  var i_sp = spn.id.replace('d_', '')*1;		// gets the number from id
  if(spn.parentNode.parentNode) {
    var star_sp = spn.parentNode.parentNode.childNodes[0];		// gets the element with stars

  if(itemrated_rtg == '' && spn.parentNode.parentNode.parentNode) itemrated_rtg = spn.parentNode.parentNode.parentNode.innerHTML;       // store the rating of rated item

   // if(spn.parentNode.parentNode.parentNode) spn.parentNode.parentNode.parentNode.childNodes[0].innerHTML = '<i>Rate:</i><span>'+(i_sp+1)+'</span>';		// shows the choosed rating

    // Modify the length and background of the zone with vizible stars (different for Firefox)
    if (navigator.userAgent.indexOf("Firefox")!=-1) star_sp.setAttribute('style', 'width:'+((i_sp+1)*17)+'px; background:url("ratingfiles/star1.png")');
    else {
      star_sp.style.width = ((i_sp+1)*17)+'px';
      star_sp.style.background = 'url("ratingfiles/star1.png")';
    }
  }
}

// add the ratting data to element in page
function addRtgData(elm, totalrate, nrrates, renot) {
  var avgrating = (nrrates>0) ? totalrate/nrrates : 0;      // sets average rating and length of area with stars

  avgrating = avgrating.toFixed(1);

  var star_n = 17*avgrating;

  // HTML code for rating, adds 5 SPAN tags, each one for a half of star, only if renot=0
  var d_rtg = '';
  if(renot==0) {
    for(var i=0; i<5; i++) {
      d_rtg += '<span id="d_'+i+'" onmouseover="rateStars(this)" onclick="rateIt(this)">&nbsp;</span>';
    }
    d_rtg = '<div class="d_rtg" onmouseout="reRating(event, \''+elm+'\', \''+totalrate+'\', \''+nrrates+'\')">'+d_rtg+'</div>';
  }

  // Create and add HTML with stars, and rating data
  var htmlrtg = '<div class="stars"><div class="star_n" style="width:'+star_n+'px;">&nbsp;</div>'+d_rtg+'</div> <div class="rate">('+avgrating+', '+nrrates+' rating' + (nrrates == 1 ? '' : 's') + ')</div>'
  if(sratings[elm]) sratings[elm].innerHTML = htmlrtg;
}

// Sends data to rtgAjax(), that will be send to PHP to register the vote
function rateIt(spn) {
  var elm = Array();
  elm[0] = spn.parentNode.parentNode.parentNode.id;	     // gets the item-name that will be rated
  var nota = spn.id.replace('d_', '')*1+1;		// gets the rating value from id

  //spn.parentNode.parentNode.parentNode.innerHTML = '<i><b>Thanks for rating</b></i>';
  rtgAjax(elm, nota);
}

// Function called by onmouseout to shows initial rating
function reRating(evt, elm, totalrate, nrrates) {
  itemrated_rtg = '';    // empty itemrated_rtg to can store other data

 // if event from element with class="d_rtg', calls addRtgData()
 // Different for IE
 if(evt.srcElement) {
   if(evt.srcElement.className='d_rtg') addRtgData(elm, totalrate, nrrates, 0);
 }
 else if(evt.target.className=='d_rtg') addRtgData(elm, totalrate, nrrates, 0);
}

/*** Ajax ***/

// create the XMLHttpRequest object, according to browser
function get_XmlHttp() {
  var xmlHttp = null;           // will stere and return the XMLHttpRequest

  if(window.XMLHttpRequest) xmlHttp = new XMLHttpRequest();     // Forefox, Opera, Safari, ...
  else if(window.ActiveXObject) xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");     // IE

  return xmlHttp;
}

// sends data to PHP and receives the response
function rtgAjax(elm, ratev) {
  var cerere_http =  get_XmlHttp();		// get XMLHttpRequest object

  // define data to be send via POST to PHP (Array with name=value pairs)
  var datasend = Array();
  for(var i=0; i<elm.length; i++) datasend[i] = 'elm[]='+elm[i];
  // joins the array items into a string, separated by '&'
  datasend = datasend.join('&')+'&rate='+ratev;

  cerere_http.open("POST", 'ratingfiles/ratings.php', true);			// crate the request

  cerere_http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");    // header for POST
  cerere_http.send(datasend);		//  make the ajax request, poassing the data

  // checks and receives the response
  cerere_http.onreadystatechange = function() {
    if (cerere_http.readyState == 4) {
      // receives a JSON with one or more item:['totalrate', 'nrrates', renot]
      eval("var jsonitems = "+ cerere_http.responseText);

      // if jsonitems is defined variable
      if (jsonitems) {
        // parse the jsonitems object
        for(var rtgitem in jsonitems) {
          var renot = jsonitems[rtgitem][2];		// determine if the user can rate or not

          // if renot=3 displaies alert that already voted, else, continue with the rating reactualization
           if(renot == 3) {
            alert("You have already rated this talk");
            window.location.reload(true);		// Reload the page
          }
          else addRtgData(rtgitem, jsonitems[rtgitem][0], jsonitems[rtgitem][1], renot);	// calls function that shows rating
        }
      }

      // if renot is undefined or 2 (set to 1 item rated per day), after vote, removes the element for rate from each elm (removing childNode 'd_rtg')
      if(ratev != '' && (renot == undefined || renot == 2)) {
        if(renot == undefined) document.getElementById(elm[0]).innerHTML = itemrated_rtg;

        for(var i=0; i<ar_elm.length; i++) {
        if(sratings[ar_elm[i]].childNodes[1].childNodes[1])
          sratings[ar_elm[i]].childNodes[1].removeChild(sratings[ar_elm[i]].childNodes[1].childNodes[1]);
        }
      }
	  }
  }
}

setTimeout("getRtgsElm()", 88);		// calls getRtgsElm() at 88 milliseconds after page loads