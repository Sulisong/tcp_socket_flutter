import 'package:flutter/material.dart';

abstract class SocketChannel<SocketType> {
  SocketType? get socket;

  String get infoConnection;

  int? get sourcePort;

  Future connect({
    required String ip,
    required int port,
    int sourcePort = 0,
    dynamic sourceAddress,
    Duration? timeout,
  });

  Future disconnect();

  void listen(
    ValueChanged<dynamic> onData, {
    Function? onError,
    VoidCallback? onDone,
    bool? cancelOnError,
  });

  void write(String data);

  void writeUTF8(String data);

  Future addList(Stream<List<int>> stream);
}
