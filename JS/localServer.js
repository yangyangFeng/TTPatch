var app = require('express')();
var path = require('path');
// const socketServer = require('http').createServer();
var http = require('http').Server(app);
var URL = require('url');
var io = require('socket.io')(http,{
  serveClient: false,
  // below are engine.IO options
  pingInterval: 10000,
  pingTimeout: 60000,
  cookie: false
});
// socketServer.listen(3000);
global.users = [];
// console.log('num'+io.attach(http));
var clientSocket=[]
const fs = require("fs");
class TTPatchServer {
  constructor() { }
  watch(callback) {
    fs.watch('./outputs', (eventType, filename) => {
      if (filename) {
        console.log(msg(filename));
        io.emit(eventId,msg("refresh:"+filename));
        clientSocket.forEach(element => {
          // element.emit(msg("<refresh:"+filename, { some: 'new message' }));
        });
 
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
      // socket.emit(msg('hello'));
      // clientSocket.push(socket);
      socket.on('disconnect', (reason) => {
        console.log(reason);
   
      });
      socket.on('error', (error) => {
        console.log('error:'+reason);
      });
      socket.on('user_login', function(info) {
        const { tokenId, userId, socketId } = info;
        // addSocketId(users, { tokenId, socketId, userId });
        console.log("user info"+tokenId,userId,socketId);
    });
    });

    // 只向 id = socketId 的这一连接发送消息 
// io.sockets.to(socketId).emit('receive_message', {
//   entityType,
//   data
// });
    
    
    http.listen(3000, function () {
      console.log(msg('listen local port:3000'));
      // io.emit(msg('on connection'), { for: 'everyone' });
    });
  }
}
let eventId="message"
let msg=function(msg){
  return "[TTPatch]: "+msg;
}


module.exports=TTPatchServer; 