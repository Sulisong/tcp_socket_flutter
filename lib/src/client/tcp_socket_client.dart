import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../data_sent_manager/data_sent_management.dart';
import '../events/events.dart';
import '../helpers/helpers.dart';
import '../models/models.dart';
import '../socket_channel/socket_channel.dart';
import '../tcp_socket_set_up.dart';
import 'tcp_socket_client_state.dart';

class TCPSocketClient {
  final Duration timeDelayToggleConnect;

  TCPSocketClient({
    this.timeDelayToggleConnect = const Duration(milliseconds: 500),
  });

  final TCPSocketClientState _state = TCPSocketClientState();
  final DataSentManagement _dataSentManagement = DataSentManagement();

  get socketChannel => _state.socketChannel;

  /// Logic state
  void _setTimeDelay() {
    _state.setIsInTimeDelay(true);
    Future.delayed(
      timeDelayToggleConnect,
      () => _state.setIsInTimeDelay(false),
    );
  }

  /// Logic listen
  void _onHandleData(
    dynamic data, {
    required ValueChanged<TCPSocketEvent> onData,
  }) {
    String stringData = '';
    if (kIsWeb) {
      throw Exception('Not support web');
    } else {
      stringData = String.fromCharCodes(data as Uint8List);
    }
    final TCPSocketEvent event = TCPSocketEvent.fromJsonString(stringData);
    final String version = event.version;
    final String type = event.type;
    if (type == TCPSocketDefaultType.$errorSending) return;
    if (type == TCPSocketDefaultType.$receiveSuccessData) {
      _dataSentManagement.deleteStatusDataSent(version, event);
      return;
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
    WaitingData? waitingData =
        _dataSentManagement.mapVersionToWaitingData[version];
    if (waitingData != null && waitingData.status) return;
    if (waitingData == null) {
      _dataSentManagement.addNewWaitingData(event);
    } else {
      _dataSentManagement.updateWaitingData(event);
    }
    waitingData = _dataSentManagement.mapVersionToWaitingData[version];
    if (waitingData!.isReceivedFullData()) {
      _dataSentManagement.replaceWaitingData(
          version, waitingData.copyWith(status: true));
      onData(event.copyWith(data: waitingData.getDataAggregated()));
    }
  }

  void _onHandleDone({
    required VoidCallback onDone,
  }) async {
    print('===================================================');
    print('Client logs: server is disconnected');
    print('===================================================');
    await _state.closeSocketChannel();
    _setTimeDelay();
    onDone();
  }

  /// API Logic
  Stream<String> discoverServerIP(String subnet) {
    if (kIsWeb) {
      throw Exception('Not support web');
    } else {
      return SocketChannelMobile.discoverServerIP(subnet);
    }
  }

  Future<bool> connectToServer(
    String connectIP, {
    required ValueChanged<TCPSocketEvent> onData,
    required VoidCallback onDone,
    required ValueChanged<dynamic> onError,
  }) async {
    if (_state.isInTimeDelay) {
      throw Exception('Please wait for a while before connecting again');
    }
    if (!TCPSocketSetUp.deviceInfo.isNotNone()) {
      throw Exception('Please set up device info before connecting');
    }
    try {
      await _state.closeSocketChannel();
      if (kIsWeb) {
        _state.setSocketChannel(SocketChannelWeb());
      } else {
        _state.setSocketChannel(SocketChannelMobile());
      }
      await _state.socketChannel!.connect(
        ip: connectIP,
        port: TCPSocketSetUp.port,
        timeout: timeDelayToggleConnect,
        sourcePort: Random().nextInt(90000) + 10000,
      );
      _state.socketChannel!.listen(
        (data) => _onHandleData(data, onData: onData),
        onDone: () => _onHandleDone(onDone: onDone),
        onError: onError,
      );
      _setTimeDelay();
      return true;
    } catch (e) {
      throw Exception('Connect to server failed: $e');
    }
  }

  Future disposeConnection() async {
    await _state.closeSocketChannel();
    _setTimeDelay();
  }

  Future _send(FormDataSending formDataSending) async {
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
    final List<String> splitData =
        HandleDataSending.splitData(formDataSending.data);
    final int splitNumber = splitData.length;
    final String version = DateTime.now().microsecondsSinceEpoch.toString();
    for (int i = 0; i < splitData.length; i++) {
      final event = TCPSocketEvent(
        type: formDataSending.type,
        data: r'' + splitData[i] + r'',
        splitNumber: splitNumber,
        totalSplit: i + 1,
        version: version,
      );
      _dataSentManagement.addItemToListStatusDataSent(
        version,
        StatusDataSent(
          event: event,
          socketChannel: _state.socketChannel!,
          status: false,
          timesToDelete: 0,
        ),
      );
      socketChannel!.write(event.toJsonString());
      await Future.delayed(TCPSocketSetUp.timeoutEachTimesSendData);
    }
    await Future.delayed(TCPSocketSetUp.timeoutEachTimesSendData);
    _dataSentManagement.sendDataError(version);
  }

  Future sendData(FormDataSending formDataSending) async {
    if (_state.socketChannel == null) {
      throw Exception('SocketChannel is null');
    }
    await _send(formDataSending);
  }
}
