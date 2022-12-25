import 'package:flutter/material.dart';

import 'socket_channel_abstract.dart';

class TCPSocketWeb {}

class SocketChannelWeb implements SocketChannel<TCPSocketWeb> {
  @override
  String get infoConnection =>
      throw Exception('TCP Socket not support on web, develop feature later');

  @override
  get socket =>
      throw Exception('TCP Socket not support on web, develop feature later');

  @override
  int? get sourcePort =>
      throw Exception('TCP Socket not support on web, develop feature later');

  @override
  Stream<String> discoverServerIP(String subnet) =>
      throw Exception('TCP Socket not support on web, develop feature later');

  @override
  Future connect({
    required String ip,
    required int port,
    int sourcePort = 0,
    sourceAddress,
    Duration? timeout,
  }) =>
      throw Exception('TCP Socket not support on web, develop feature later');

  @override
  Future disconnect() =>
      throw Exception('TCP Socket not support on web, develop feature later');

  @override
  void listen(
    ValueChanged onData, {
    Function? onError,
    VoidCallback? onDone,
    bool? cancelOnError,
  }) =>
      throw Exception('TCP Socket not support on web, develop feature later');

  @override
  void write(String data) =>
      throw Exception('TCP Socket not support on web, develop feature later');

  @override
  void add(List<int> data) =>
      throw Exception('TCP Socket not support on web, develop feature later');

  @override
  Future addList(Stream<List<int>> stream) =>
      throw Exception('TCP Socket not support on web, develop feature later');
}
