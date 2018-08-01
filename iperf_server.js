const http = require('http');
const fs = require('fs');
var spawn = require('child_process').spawn;

spawn('/bin/bash', ['throughput.sh'], {
    detached: false
});

http.createServer(function (req, res) {
	res.writeHead(200, {'Content-Type': 'application/json'});
	res.write(fs.readFileSync('data.json'));
	res.end();
}).listen(8080);
