var app = require('express')();
var path = require('path');
var http = require('http').Server(app);
var URL = require('url');
var io = require('socket.io')(http);

const fs = require("fs");
class TTPatchServer {
  constructor() { }
  watch(callback) {
    fs.watch('./outputs', (eventType, filename) => {
      if (filename) {
        console.log(msg(filename));
        io.emit(msg("refresh"));
 
      }
    });
    fs.watch('./src', (eventType, filename) => {
      if (filename) {
        callback();
      }
    });
  }
  start() {
    console.log('----------------------------------------------------------------------------------------------\n'+msg('本地服务已启动'))
    app.get('/*', function (req, res) {
      res.sendFile(__dirname + "/outputs/" + req.params[0]);
      console.log(msg('read:' + req.params[0]));
    });
    io.on('connection', function (socket) {
      socket.emit(msg('hello'));
    });
    http.listen(8888, function () {
      console.log(msg('listen local port:8888'));
      io.emit(msg('on connection'), { for: 'everyone' });
    });
  }
}
let msg=function(msg){
  return "[TTPatch]: "+msg;
}

module.exports=TTPatchServer; 