// local server using NodeJS
// to run: nodejs localServer.js
// to test: curl localhost:8080

var http = require('http');

var server = http.createServer(function(req, res) {
  res.writeHead(200);
  res.end('Hello Http'); // returned to client
  console.log('someone just queried me !'); // terminal log
});
server.listen(8080);
