<img src="http://stephaneadamgarnier.com/iOS_remoteTerminal/assets/phone.png" align="" height="48" width="48">
<img src="http://stephaneadamgarnier.com/iOS_remoteTerminal/assets/chevron_right.png" align="" height="48" width="48">
<img src="http://stephaneadamgarnier.com/iOS_remoteTerminal/assets/cloud.png" align="" height="48" width="48">
<img src="http://stephaneadamgarnier.com/iOS_remoteTerminal/assets/chevron_right.png" align="" height="48" width="48">
<img src="http://stephaneadamgarnier.com/iOS_remoteTerminal/assets/computer.png" align="" height="48" width="48">

# Terminalog
Quick log to a remote terminal ( handy for debugging code on smartphones &amp; tablets )

the idea behind the smallest version of the script is to use XHRs as debugging tool instead of the traditional call to 'console.log()', while logs can be displayed directly in the remote terminal as well as saved to a (log)file

Nbs:
- CORS is to be added / tested
- out of the 3 solutions below, only 2 seems to work on iOS, probably due to a bug in the way 'POST' XHRs are handled on the platform ( or my code, but googlin' it, I'm not the only one ..)

server-side
===========
as we use quick n' dirty XHRs, we're totally tech agnostic here, hence the 3 small examples in PHP, NodeJS, & Bash

The PHP script is intended to be called using PHP's built-in server, to easily output to a terminal while still allowing the logs to be saved using a standard 'tee' command
Also, the IP address passed to it must be using a wlan interface or the remote device won't be able to XHR
( although we could make use of iptables & Cie to bridge/route localhost to it, I don't know yet if we can pass multiple interface to PHP's built-in server )
```
# run the server & log to the terminal
php -S 192.168.1.8:3000 ./localServer.php
# run the server & log to the terminal as well as to a file
php -S 192.168.1.8:3000 ~/Documents/xhrLogsToTerminal/localServer.php 2>&1 | tee tests.log

```

The NodeJS script is 'bare metal' and only contains the essentials to build upon
`nodejs ./localServer.js`

The Bash script is .. not yet written, but 'll get some code as soon as can be
Nb: also, I'll have to digg how to handle GET/POST requests in pure Bash ;p .. & curl that

using 'POST'
============
```
var xhr = new XMLHttpRequest();
xhr.open( 'POST', 'http://' + serverIp + ':' + serverPort, true);
xhr.overrideMimeType('text/plain; charset=UTF8; base64'); // not sure about this ..
xhr.send( btoa( unescape( encodeURIComponent('\033[31m'+ 'iOP' +' \033[0msays Hi to \n...\n'+ 'Julie') ) ) ); // encode the content
```

using 'GET'
============
```
var xhr = new XMLHttpRequest();
xhr.open( 'GET', 'http://' + serverIp + ':' + serverPort + "?iOS-message=" + btoa( unescape( encodeURIComponent('\033[31m'+ 'iOG' +' \033[0msays Hi to \n...\n'+ 'Julie') ) ), true);
xhr.overrideMimeType('text/plain; charset=UTF8; base64'); // not sure about this .. ubt seems fine
xhr.send(null); // content is encoded & in url params
```

using 'script'
===============
```
var xhrScript = document.createElement('script'); // create a <script> tag
xhrScript.id = 'xhr-script'; // give it an id
xhrScript.type = 'text/javascript'; // set its type
var queryPath = 'http://' + serverIp + ':' + serverPort + "?iOS-message=" + btoa( unescape( encodeURIComponent('\033[31m'+ 'iOS' +' \033[0msays Hi to \n...\n'+ 'Julie') ) );
xhrScript.src = queryPath;
document.getElementsByTagName("head")[0].appendChild(xhrScript); // send the request
document.getElementsByTagName("head")[0].removeChild(xhrScript); // remove it from the head
delete xhrScript; // delete it (> digg the pros/cons (..) )
```

example1:
=========

this snippet demonstrates the simplest usage
```
var serverIp = '192.168.1.8'; // server running whatever: php, bash, nodejs, ..
var serverPort = 3000;
function terminalog( string ){
  var xhr = new XMLHttpRequest();
  xhr.open( 'GET', 'http://' + serverIp + ':' + serverPort + "?iOS-message=" + btoa( unescape( encodeURIComponent(string) ) ), true);
  xhr.overrideMimeType('text/plain; charset=UTF8; base64'); // not sure about this .. ubt seems fine
  xhr.send(null); // encode the content
}
```
example2:
=========
this snippet encapsulates the above & also handles a callback log from the server
```
function terminalog( string ){
  var xhr = new XMLHttpRequest();
  xhr.open( 'GET', 'http://' + serverIp + ':' + serverPort + "?iOS-message=" + btoa( unescape( encodeURIComponent(string) ) ), true);
  xhr.overrideMimeType('text/plain; charset=UTF8; base64'); // not sure about this .. ubt seems fine
  xhr.send(null); // encode the content
  xhr.onreadystatechange = function(){
    if( xhr.readyState == 4 && xhr.status == 200 ){
      // handle the presence of %s & generate console.log colorizing - R: NOT supported by iOS :/
      var myStr2 = decodeURIComponent( escape( atob( xhr.responseText ) ) ).replace(/\\n/g, '\n');
      var styles = myStr2.match(/%s\[([^\]]+)\]/gm); // or myStr2.match(/%s\[[^\]]+\]/gm); since we don't use capture groups with 'match()'
      //styles; // ["%s[color: #FE524C]", "%s[color: #050504]"]
      //styles[0].substr(3, styles[0].length -4) // "color: #FE524C"
      styles.forEach(function(item, index){ styles[index] = styles[index].substr(3, styles[index].length -4) }); // clean the styles array items
      var myStrClean = myStr2.replace(/%s\[[^\]]+\]/gm, '%c'); // clean the log string from its styles
      styles.unshift( myStrClean ); // prepare the console.log call to which we'll pass an array of elements
      console.log.apply(console, styles); // log all that stuff
    }
  }
}
```

example3:
=========
this snippet provides a simple solution to lower the XHR calls by deffering the calls & buffering the logs
```
var serverIp = '192.168.1.8';
var serverPort = 3000;
var lastCallTime = new Date().getTime();
var opList = [];
var thresholdWaitTime = 10000;
var defferedUsesTimeout = true;
var defferedTimeout = -1;
function terminalog(message){
  if( new Date().getTime() < lastCallTime + thresholdWaitTime ){
    console.log('deferring ..'); 
    opList.push( arguments[0] );
    if( defferedUsesTimeout == true ){
      if(  defferedTimeout != -1 ) clearTimeout( defferedTimeout );
      defferedTimeout = setTimeout(function(){
        console.log('deffered timeout');
        terminalog('');
      }, thresholdWaitTime); 
    }
  }
  else {
    if(  defferedTimeout != -1 ) clearTimeout( defferedTimeout );
    console.log('handling deferred');
    opList.push( arguments[0] );
    var messagesBuff = '';
    while ( opList.length ) messagesBuff += opList.shift() //.join('');
    //console.log(messagesBuff); // message to remote terminal
    var xhr = new XMLHttpRequest();
    xhr.open( 'GET', 'http://' + serverIp + ':' + serverPort + "?iOS-message=" + btoa( unescape( encodeURIComponent(messagesBuff) ) ), true);
    xhr.overrideMimeType('text/plain; charset=UTF8; base64'); // not sure about this .. ubt seems fine
    lastCallTime = new Date().getTime();
  }
}
```
