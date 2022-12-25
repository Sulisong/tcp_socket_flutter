import 'dart:async';

import '../socket_channel/socket_channel.dart';

class TCPSocketClientState {
  SocketChannel? _socketChannel;
  bool _isInTimeDelay = false;

  get socketChannel => _socketChannel;

  get isInTimeDelay => _isInTimeDelay;

  void setSocketChannel(SocketChannel? value) => _socketChannel = value;

  void setIsInTimeDelay(bool isInTimeDelay) => _isInTimeDelay = isInTimeDelay;

  Future closeSocketChannel() async {
    if (_socketChannel != null) {
      await _socketChannel!.disconnect();
      setSocketChannel(null);
    }
  }
}
