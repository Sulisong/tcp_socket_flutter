import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../tcp_socket_set_up.dart';
import 'socket_channel_abstract.dart';

class SocketChannelMobile implements SocketChannel<Socket> {
  static SocketChannelMobile getSocketChannelMobile(Socket socket) {
    final socketChannelMobile = SocketChannelMobile();
    socketChannelMobile.setSocket(socket);
    return socketChannelMobile;
  }

  Socket? _socket;
  StreamSubscription<Uint8List>? _streamSubscription;
  int _sourcePort = 0;

  void setSocket(Socket? socket) => _socket = socket;

  void _setStreamSubscription(StreamSubscription<Uint8List>? streamSubscription) =>
      _streamSubscription = streamSubscription;

  void _setSourcePort(int sourcePort) => _sourcePort = sourcePort;

  @override
  String get infoConnection =>
      '${_socket?.remoteAddress.address}:${_socket?.remotePort}:${_socket?.port}';

  @override
  get socket => _socket;

  @override
  int? get sourcePort => _sourcePort;

  @override
  Stream<String> discoverServerIP(String subnet) {
    final out = StreamController<String>();
    final futuresSocket = <Future<Socket>>[];
    final partOfIP = '${subnet.split('.')[0]}.${subnet.split('.')[1]}';
    for (int i = 1; i <= 256; ++i) {
      for (int y = 1; y <= 256; y++) {
        final host = '$partOfIP.$y.$i';
        final Future<Socket> socket = Socket.connect(
          host,
          TCPSocketSetUp.port,
        );
        futuresSocket.add(socket);
        socket.then(
          (s) {
            s.destroy();
            out.sink.add(host);
          },
        ).catchError(
          (error) {},
        );
      }
    }
    Future.wait<Socket>(futuresSocket)
        .then<void>((sockets) => out.close())
        .catchError((error) => out.close());
    return out.stream;
  }

  @override
  Future connect({
    required String ip,
    required int port,
    int sourcePort = 0,
    sourceAddress,
    Duration? timeout,
  }) async {
    _setSourcePort(sourcePort);
    setSocket(
      await Socket.connect(
        ip,
        port,
        timeout: timeout,
        sourcePort: sourcePort,
        sourceAddress: sourceAddress,
      ),
    );
  }

  @override
  Future disconnect() async {
    if (_streamSubscription != null) {
      _streamSubscription!.pause();
      await _streamSubscription!.cancel();
      _setStreamSubscription(null);
    }
    if (_socket != null) {
      _socket!.destroy();
      await _socket!.close();
      setSocket(null);
    }
  }

  @override
  void listen(
    ValueChanged onData, {
    Function? onError,
    VoidCallback? onDone,
    bool? cancelOnError,
  }) =>
      _setStreamSubscription(
        _socket!.listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        ),
      );

  @override
  void write(String data) => _socket!.write(data);

  @override
  void add(List<int> data) => _socket!.add(data);

  @override
  Future addList(Stream<List<int>> stream) => _socket!.addStream(stream);
}
