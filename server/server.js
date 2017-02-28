// *    1.面向express框架开发，加载express框架，方便处理get,post请求
// *    2.因为socket依赖http,创建http服务器，使用http模块.
// *    3.可以通过express创建http服务器http.server(express)
// *    4.通过http服务器创建socket
// *    5.监听http服务器

// 引入express
var http = require('http');
var express = require('express');
// 创建web服务器
var server = http.Server(express);
// 引入socker
var socketIO = require('socket.io');
// 需要传入服务器，socket基于http
var socket = socketIO(server);
// 监听web服务器
server.listen(8080);

var simpleRooms = new Map();
console.log('正在监听8080端口');
// 监听socket连接
socket.on('connection', function(s) {

    console.log('监听到客户端连接');
    var rooms = [];
    s.on('createRoom', function(roomName) {
        s.join(roomName);
        rooms.push(roomName);
        console.log('创建房间' + roomName);
        var text = "";
        if (simpleRooms.get(s)) { //如果找到原来房间则退出
            text = "你已经退出房间" + simpleRooms.get(s) + "\n";
            simpleRooms.delete(s);
        }
        text += "你已经进入房间" + roomName;
        simpleRooms.set(s, roomName);
        s.emit('roomInfo', text);

    });

    s.on('chatRoom', function(data) {
        console.log(simpleRooms.get(s) + '说话' + data);
        socket.to(simpleRooms.get(s)).emit('chat', '房间1的数据' + data);
    });
});

// socket.on('connection',function(s){

//     console.log('监听到客户端连接');
//     socket.emit('chat','服务器'+"data");

//     // data:客户端数组第0个元素
//     // data1:客户端数组第1个元素
//     // s.on('chat',function(data,data1){

//     //     console.log('监听到chat事件');

//     //     console.log(data,data1);

//     // });
//     // 
// });
