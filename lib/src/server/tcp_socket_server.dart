import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../data_sent_manager/data_sent_management.dart';
import '../events/events.dart';
import '../helpers/helpers.dart';
import '../models/models.dart';
import '../socket_channel/socket_channel.dart';
import '../tcp_socket_set_up.dart';
import 'tcp_socket_server_state.dart';

class TCPSocketServer {
  final Duration timeDelayToggleConnect;

  TCPSocketServer({
    this.timeDelayToggleConnect = const Duration(milliseconds: 500),
  });

  final TCPSocketServeState _state = TCPSocketServeState();
  final DataSentManagement _dataSentManagement = DataSentManagement();

  List<SocketConnection> get listSocketConnection => _state.listSocketConnection;

  bool get serverIsRunning => _state.serverIsRunning;

  /// Logic state
  void _setTimeDelay() {
    _state.setIsInTimeDelay(true);
    Future.delayed(
      timeDelayToggleConnect,
      () => _state.setIsInTimeDelay(false),
    );
  }

  /// Logic listen
  void _onRequest(
    Socket socket, {
    required Function(String ip, int? sourcePort, TCPSocketEvent event) onData,
    required Function(String ip, int? sourcePort) onDone,
    required Function(dynamic error, String ip, int? sourcePort) onError,
  }) async {
    final ip = socket.remoteAddress.address;
    final sourcePort = socket.remotePort;
    final SocketChannel socketChannel = SocketChannelMobile.getSocketChannelMobile(socket);
    _state.checkExistAndRemoveSocketConnection(ip);
    _state.addSocketConnection(
      ip,
      SocketConnection(
        socketChannel: socketChannel,
        deviceInfo: DeviceInfo(
          ip: ip,
          subnet: DeviceInfo.genSubnet(ip),
          sourcePort: sourcePort,
          deviceName: '',
        ),
      ),
    );
    socketChannel.listen(
      (data) => _onHandleData(
        data: data,
        ip: ip,
        sourcePort: sourcePort,
        socketChannel: socketChannel,
        onData: onData,
      ),
      onDone: () => _onHandleDone(
        ip: ip,
        sourcePort: sourcePort,
        onDone: onDone,
      ),
      onError: (error) => onError(
        error,
        ip,
        sourcePort,
      ),
    );
  }

  void _onHandleData({
    required Uint8List data,
    required String ip,
    int? sourcePort,
    required SocketChannel socketChannel,
    required Function(String ip, int? sourcePort, TCPSocketEvent event) onData,
  }) {
    final stringData = String.fromCharCodes(data);
    final TCPSocketEvent event = TCPSocketEvent.fromJsonString(stringData);
    final String version = event.version;
    final String type = event.type;
    if (type == TCPSocketDefaultType.$errorSending) return;
    if (type == TCPSocketDefaultType.$receiveSuccessData) {
      _dataSentManagement.deleteStatusDataSent(version, event);
      return;
    }
    if (_dataSentManagement.mapVersionToWaitingData[version] == null) {
      _dataSentManagement.addNewWaitingData(event);
    } else {
      _dataSentManagement.updateWaitingData(event);
    }
    socketChannel.write(
      TCPSocketEvent(
        type: TCPSocketDefaultType.$receiveSuccessData,
        data: '',
        splitNumber: event.splitNumber,
        totalSplit: event.totalSplit,
        version: event.version,
      ).toJsonString(),
    );
    WaitingData? waitingData = _dataSentManagement.mapVersionToWaitingData[version];
    if (waitingData!.isReceivedFullData()) {
      onData(ip, sourcePort, event.copyWith(data: waitingData.getDataAggregated()));
      _dataSentManagement.removeWaitingData(version);
    }
  }

  void _onHandleDone({
    required String ip,
    int? sourcePort,
    required Function(String ip, int? sourcePort) onDone,
  }) async {
    print('===================================================');
    print('Server logs - $ip:$sourcePort - disconnected');
    print('===================================================');
    await _state.checkExistAndRemoveSocketConnection(ip);
    onDone(ip, sourcePort);
  }

  /// API Logic
  Future<bool> initServer({
    required Function(String ip, int? sourcePort, TCPSocketEvent event) onData,
    required Function(String ip, int? sourcePort) onDone,
    required Function(dynamic error, String ip, int? sourcePort) onError,
  }) async {
    if (_state.serverIsRunning) {
      throw Exception('Server is running');
    }
    if (!TCPSocketSetUp.deviceInfo.isNotNone()) {
      throw Exception('Please set up device info before connecting');
    }
    if (_state.isInTimeDelay) {
      throw Exception('Please wait for a while before starting again');
    }
    await runZoned(
      () async {
        try {
          _state.setServerSocket(
            await ServerSocket.bind(
              TCPSocketSetUp.ip,
              TCPSocketSetUp.port,
            ),
          );
          _state.setStreamSubscriptionServer(
            _state.serverSocket!.listen(
              (socket) => _onRequest(
                socket,
                onData: onData,
                onDone: onDone,
                onError: onError,
              ),
            ),
          );
          _state.setServerIsRunning(true);
          _setTimeDelay();
        } catch (e) {
          disposeServer();
          throw Exception('Init server failed: $e');
        }
      },
    );
    return true;
  }

  Future disposeServer() async {
    if (!_state.serverIsRunning) {
      throw Exception('Server is not running');
    }
    if (_state.isInTimeDelay) {
      throw Exception('Please wait for a while before starting again');
    }
    await _state.closeAllSocketConnection();
    await _state.closeServerSocket();
    _state.setServerIsRunning(false);
    _setTimeDelay();
  }

  Future _send(
    FormDataSending formDataSending,
    SocketChannel socketChannel,
  ) async {
    if (formDataSending.data.isEmpty) {
      socketChannel.write(
        TCPSocketEvent(
          type: formDataSending.type,
          data: formDataSending.data,
          splitNumber: 1,
          totalSplit: 1,
          version: DateTime.now().microsecondsSinceEpoch.toString(),
        ).toJsonString(),
      );
      return;
    }
    final List<String> splitData = HandleDataSending.splitData(formDataSending.data);
    final int splitNumber = splitData.length;
    final String version = DateTime.now().microsecondsSinceEpoch.toString();
    for (int i = 0; i < splitData.length; i++) {
      final subEvent = TCPSocketEvent(
        type: formDataSending.type,
        data: r'' + splitData[i] + r'',
        splitNumber: splitNumber,
        totalSplit: i + 1,
        version: version,
      );
      _dataSentManagement.addItemToListStatusDataSent(
        version,
        StatusDataSent(
          event: subEvent,
          socketChannel: socketChannel,
          status: false,
          timesToDelete: 0,
        ),
      );
      socketChannel.write(subEvent.toJsonString());
      await Future.delayed(TCPSocketSetUp.timeoutEachTimesSendData);
    }
    await Future.delayed(TCPSocketSetUp.timeoutEachTimesSendData);
    _dataSentManagement.sendDataError(version);
  }

  Future sendData(
    FormDataSending formDataSending, {
    SocketChannel? targetSocketChannel,
  }) async {
    if (targetSocketChannel != null) {
      await _send(formDataSending, targetSocketChannel);
      return;
    }
    for (final socketConnection in listSocketConnection) {
      await _send(formDataSending, socketConnection.socketChannel);
    }
  }
}
