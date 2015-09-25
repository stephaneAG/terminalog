<?php

  // local server using PHP
  // R: launch with php -S localhost:<port> <filename>.php
  //
  // usage:
  /*

  // from any device:
  var xhr = new XMLHttpRequest();
  xhr.open( 'POST', 'http://' + serverIp + ':' + serverPort, true);
  xhr.overrideMimeType('text/plain; charset=UTF8; base64'); // not sure about this ..
  xhr.send( btoa( unescape( encodeURIComponent('tef') ) ) ); // encode the content

  // from iOS devices:
  var xhr = new XMLHttpRequest();
  xhr.open( 'GET', 'http://' + serverIp + ':' + serverPort + "?iOS-message=" + btoa( unescape( encodeURIComponent('tef') ) ), true); // set the content as an url var
  xhr.overrideMimeType('text/plain; charset=UTF8; base64'); // not sure about this ..
  xhr.send(null);

  ====

  // example specific to the current test/poc implm of the server in PHP

  // syntax: '\033[31m'+ dude +' \033[0msays Hi to \n...\n'+ lady
  // ex:     '\033[31m'+ 'Tef' +' \033[0msays Hi to \n...\n'+ 'Julie'

  // from any device:
  var xhr = new XMLHttpRequest();
  xhr.open( 'POST', 'http://' + serverIp + ':' + serverPort, true);
  xhr.overrideMimeType('text/plain; charset=UTF8; base64'); // not sure about this ..
  xhr.send( btoa( unescape( encodeURIComponent('\033[31m'+ 'Tef' +' \033[0msays Hi to \n...\n'+ 'Julie') ) ) ); // encode the content

  // from iOS devices:
  var xhr = new XMLHttpRequest();
  xhr.open( 'GET', 'http://' + serverIp + ':' + serverPort + "?iOS-message=" + btoa( unescape( encodeURIComponent('\033[31m'+ 'Tef' +' \033[0msays Hi to \n...\n'+ 'Julie') ) ), true);
  xhr.overrideMimeType('text/plain; charset=UTF8; base64'); // not sure about this ..
  xhr.send(null); // encode the content

  */

  header("HTTP/1.0 200 OK"); // trying to make that !****** iOS xhr & Cie work !
  // WARN /!\ -> NOT secure ;p
  header('Access-Control-Allow-Origin: *');

  // GET DATA FROM CLIENT
  // for an iOS fix, it seems we may need to send(null) & pass data along as url var in a GET requests
  // chek if getting data from an iOS GET xhr

  /* the beow works ! */
  if ( empty($_GET) ) $data = file_get_contents('php://input');
  else if( $_GET["iOS-message"] != '' ) $data = $_GET["iOS-message"];
  //$data = file_get_contents('php://input');

  //$postData = file_get_contents('php://input'); // get raw POST data from client
  // R: less memory intensive alternative to $HTTP_RAW_POST_DATA that doesn't need any special php.ini directives.
  //    /!\ not available with enctype="multipart/form-data"
  //echo 'something just happened !'; // to the client
  // quick dummy parse
  /*
  $testStr = 'Tef says Hi to
...

Kelly';
  $testStr = '\033[31mTef \033[0msays Hi to \n...\nKelly';
  */
  //$testStr = '\033[31mTef \033[0msays Hi to \n...\nKelly';
  //$testStr = preg_replace( '#\\\033\[[0-9].m#', '', preg_replace( '#\\\n#', '', $testStr) ); // STRIP BASH COLOR CODES & LINEFEEDS BEFORE PARSING, doesn't hurt ;)
  // R: the above is commented out since I use the last linefeed to locate the last part of the data I'm interested in
  //$testStr = base64_decode( $postData );
  $testStr = base64_decode( $data );
  $spaceChar = ' ';
  //$lineFeed = '\n';                                                                                   // working in php -a interactive console
  $lineFeed = "\n";                                                                                     // working in real situation ( double quote mumbo jumbo ? )
  $firstSpaceCharPos = strpos($testStr, $spaceChar);
  //$dudeName =  substr($testStr, $firstSpaceCharPos);
  $lastlineFeedCharPos = strrpos($testStr, $lineFeed);
  $dudeName =  substr($testStr, 0, $firstSpaceCharPos);
  //$dudeName = preg_replace( '#\\\033\[[0-9].m#', '',$dudeName); // cleanup ( strip bash color codes ) // working in php -a interactive console
  $dudeName = preg_replace( '#\\033\[[0-9].m#', '',$dudeName); // cleanup ( strip bash color codes )    // working in real situation ( not escaping the escape char ;p )
  $ladyName =  substr($testStr, $lastlineFeedCharPos , strlen($testStr) - $lastlineFeedCharPos );
  //$ladyName = preg_replace( '#\\\n#', '', $ladyName); // cleanup ( strip linefeeds )                  // working in php -a interactive console
  $ladyName = preg_replace( '#\n#', '', $ladyName); // cleanup ( strip linefeeds )                      // working in real situation ( not escaping the escape char ;p )
  //echo $dudeName . ' welcomed ' . $ladyName . PHP_EOL;

  // LOG DATA TO SERVER TERMINAL
  //fwrite( STDOUT, "Hello World! \n" ); // to stdout in terminal ? => not working
  $handle = fopen( 'php://stdout', 'w' ) ;
  //fwrite( $handle, "Hello World! \n" ); // dumb test
  fwrite( $handle, "\n\nDATA FROM CLIENT: \n" ); // easier reading R: KEEP DOUBLE QUOTES OR IT WON'T PRINT LINEFEEDS !!
  //fwrite( $handle, $postData ); // get the data from the client, untouched
  //fwrite( $handle, base64_decode( $postData ) ); // get the data from the client when the following javascript was used to encode it:
  fwrite( $handle, base64_decode( $data ) );
  // btoa( unescape( encodeURIComponent(string) ) ) ); // encode the content
  //fwrite( $handle, "\n\nINFOS FROM CLIENT:\n" . 'Dude => '. $dudeName . "\n" . 'Lady => ' . $ladyName . "\n" ); // log the infos parsed from the client data
  fwrite( $handle, "\n\nINFOS FROM CLIENT:\n" . 'Dude => '."\033[32m". $dudeName . "\033[0m". "\n" . 'Lady => ' . $ladyName . "\n" ); // log the infos parsed from the client data - colored
  // R: the above also needs double quotes to allow the bash color codes escape sequences to be interpreted as such
  fclose( $handle );

  // RETURN DATA TO CLIENT
  // the following works

  echo base64_encode( 'DATA FROM SERVER: \n'.
                      'Hello World from the localServer [PHP] !'.
                      '%s[color: #FE524C]INFOS:%s[color: #050504] from the localServer => '. $dudeName .' welcomed '. $ladyName .' [PHP]'
  );

  /*
  echo rawurlencode(
    base64_encode( 'DATA FROM SERVER: \n'. 'INFOS: message logged localServer [PHP] !'
      )
  );

  // need to save that to a file ?
  //file_put_contents('<someFilename>', base64_decode( $postData ) );

?>
