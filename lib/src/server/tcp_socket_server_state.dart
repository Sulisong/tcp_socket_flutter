import 'dart:async';
import 'dart:io';

import '../models/models.dart';

class TCPSocketServeState {
  ServerSocket? _serverSocket;
  StreamSubscription<Socket>? _streamSubscriptionServer;
  final Map<String, SocketConnection> _mapIPToSocketConnection = {};
  bool _isInTimeDelay = false;
  bool _serverIsRunning = false;
  final _listenerListSocketConnection = StreamController<List<SocketConnection>>();

  ServerSocket? get serverSocket => _serverSocket;

  Map<String, SocketConnection> get mapIPToSocketConnection => _mapIPToSocketConnection;

  List<SocketConnection> get listSocketConnection => _mapIPToSocketConnection.values.toList();

  bool get isInTimeDelay => _isInTimeDelay;

  bool get serverIsRunning => _serverIsRunning;

  Stream<List<SocketConnection>> get listenerListSocketConnection =>
      _listenerListSocketConnection.stream;

  void setServerSocket(ServerSocket? value) => _serverSocket = value;

  void setStreamSubscriptionServer(StreamSubscription<Socket>? value) =>
      _streamSubscriptionServer = value;

  void setIsInTimeDelay(bool isInTimeDelay) => _isInTimeDelay = isInTimeDelay;

  void setServerIsRunning(bool serverIsRunning) => _serverIsRunning = serverIsRunning;

  Future closeSocketConnection(SocketConnection socketConnection) =>
      socketConnection.socketChannel.disconnect();

  void removeSocketConnection(SocketConnection socketConnection) {
    _mapIPToSocketConnection.removeWhere(
      (key, value) => key == socketConnection.deviceInfo.ip,
    );
    _listenerListSocketConnection.sink.add(listSocketConnection);
  }

  Future checkExistAndRemoveSocketConnection(String ip) async {
    if (_mapIPToSocketConnection.containsKey(ip)) {
      final socketConnection = _mapIPToSocketConnection[ip]!;
      await closeSocketConnection(socketConnection);
      removeSocketConnection(socketConnection);
    }
  }

  void addSocketConnection(ip, SocketConnection socketConnection) {
    _mapIPToSocketConnection[ip] = socketConnection;
    _listenerListSocketConnection.sink.add(listSocketConnection);
    print('===================================================');
    print('Server logs - New connection from:');
    print(socketConnection.deviceInfo.toJson());
    print('===================================================');
  }

  Future closeServerSocket() async {
    if (_serverSocket != null) {
      _streamSubscriptionServer!.pause();
      await _streamSubscriptionServer!.cancel();
      await _serverSocket!.close();
      setServerSocket(null);
    }
  }

  Future closeAllSocketConnection() async {
    for (final socketConnection in _mapIPToSocketConnection.values) {
      await closeSocketConnection(socketConnection);
    }
    _mapIPToSocketConnection.clear();
    _listenerListSocketConnection.sink.add(listSocketConnection);
  }
}
