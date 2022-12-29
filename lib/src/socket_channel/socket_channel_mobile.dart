import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../tcp_socket_set_up.dart';
import 'socket_channel_abstract.dart';

class SocketChannelMobile implements SocketChannel<Socket> {
  static SocketChannelMobile getSocketChannelMobile(Socket socket) {
    final socketChannelMobile = SocketChannelMobile();
    socketChannelMobile.setSocket(socket);
    socketChannelMobile.setSourcePort(socket.remotePort);
    return socketChannelMobile;
  }

  static Stream<String> discoverServerIP(String subnet) {
    final out = StreamController<String>();
    final futuresSocket = <Future<Socket>>[];
    final partOfIP =
        '${subnet.split('.')[0]}.${subnet.split('.')[1]}.${subnet.split('.')[2]}';
    for (int i = 1; i <= 256; ++i) {
      final host = '$partOfIP.$i';
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
    Future.wait<Socket>(futuresSocket)
        .then<void>((sockets) => out.close())
        .catchError((error) => out.close());
    return out.stream;
  }

  Socket? _socket;
  StreamSubscription<Uint8List>? _streamSubscription;
  int _sourcePort = 0;

  void setSocket(Socket? socket) => _socket = socket;

  void _setStreamSubscription(
          StreamSubscription<Uint8List>? streamSubscription) =>
      _streamSubscription = streamSubscription;

  void setSourcePort(int sourcePort) => _sourcePort = sourcePort;

  @override
  String get infoConnection =>
      '${_socket?.remoteAddress.address}:${_socket?.remotePort}:${_socket?.port}';

  @override
  get socket => _socket;

  @override
  int? get sourcePort => _sourcePort;

  @override
  Future connect({
    required String ip,
    required int port,
    int sourcePort = 0,
    sourceAddress,
    Duration? timeout,
  }) async {
    setSourcePort(sourcePort);
    setSocket(
      await Socket.connect(
        ip,
        port,
        timeout: timeout,
        sourcePort: sourcePort,
        sourceAddress: sourceAddress,
      ),
    );
    _socket!.encoding = Encoding.getByName('utf-8')!;
  }

  @override
  Future disconnect() async {
    try {
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
    } catch (e) {
      debugPrint(
          '------------------------------------------------------------');
      debugPrint('SocketChannelMobile disconnect error: $e');
      debugPrint(
          '------------------------------------------------------------');
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
  void writeUTF8(String data) => _socket!.add(utf8.encode(data));

  @override
  Future addList(Stream<List<int>> stream) => _socket!.addStream(stream);
}
