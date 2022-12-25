TCP Socket Flutter
===========

* [Introduction](#introduction)
* [Set up](#setup)
* [License and contributors](#license-and-contributors)

Introduction
------------

This is a Flutter package that allows you to connect to a socket over the net. All data is then read using UTF-8.

Setup
-------
Config
```Dart
  TCPSocketSetUp.setConfig(
    const SocketConfig(
      port: 8000,
      numberSplit: 10000,
      timeoutEachTimesSendData: Duration(milliseconds: 50),
    ),
  );
```
Device Info
```Dart
await TCPSocketSetUp.init();
```
Server
```Dart
  final TCPSocketServer _server = TCPSocketServer();
  final result = await _server.initServer(
    onData: (ip, sourcePort, event) {
        print('Server receive data from: $ip:$sourcePort');
        print('Server receive data: $event');
    },
    onDone: (ip, sourcePort) {},
    onError: (error, ip, sourcePort) {},
  );
  print(result);
```
Server send data
```Dart
  await _server.sendData(
    FormDataSending(
      type: 'Server send info',
      data: getRandomString(1000000),
    ),
  );
```
Client
```Dart
  final TCPSocketClient _client = TCPSocketClient();
  final result = await _client.connectToServer(
    '192.168.0.101',
    onData: (event) {
      print('Client receive data: $event');
    },
    onDone: () {},
    onError: (error) {},
  );
  print('Connect to server $result');
```
Client send data
```Dart
  await _client.sendData(
    FormDataSending(
      type: 'Client send info',
      data: getRandomString(1000000),
    ),
  );
```

License and contributors
------------------------

* The MIT License, see [LICENSE](https://github.com/nghetien/tcp_socket_flutter/blob/main/LICENSE).
* For contributors, see [AUTHORS](https://github.com/nghetien/tcp_socket_flutter/blob/main/AUTHORS).