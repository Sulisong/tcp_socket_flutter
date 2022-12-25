import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tcp_socket_flutter/tcp_socket_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TCPSocketServer _server = TCPSocketServer();
  final TCPSocketClient _client = TCPSocketClient();

  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                TCPSocketSetUp.setConfig(
                  const SocketConfig(
                    port: 8000,
                    numberSplit: 10000,
                    timeoutEachTimesSendData: Duration(milliseconds: 50),
                  ),
                );
                print(TCPSocketSetUp.config.toJson());
              },
              child: const Text('Set port 8000'),
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                await TCPSocketSetUp.init();
                print('Get device info done');
              },
              child: const Text('Get info IP'),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Server ------------'),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                final result = await _server.initServer(
                  onData: (ip, sourcePort, event) {
                    print('Server receive data from: $ip:$sourcePort');
                    print('Server receive data: $event');
                  },
                  onDone: (ip, sourcePort) {},
                  onError: (error, ip, sourcePort) {},
                );
                print(result);
                print('Run server thành công');
              },
              child: const Text('Start Server'),
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                await _server.sendData(
                  FormDataSending(
                    type: 'Server send info',
                    data: getRandomString(1000000),
                  ),
                );
              },
              child: const Text('Server send data'),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Client ------------'),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                final result = await _client.connectToServer(
                  '192.168.0.101',
                  onData: (event) {
                    print('Client receive data: $event');
                  },
                  onDone: () {},
                  onError: (error) {},
                );
                print('Connect to server $result');
              },
              child: const Text('Connect to server'),
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                await _client.sendData(
                  FormDataSending(
                    type: 'Client send info',
                    data: getRandomString(1000000),
                  ),
                );
              },
              child: const Text('Client send data'),
            ),
          ],
        ),
      ),
    );
  }
}
