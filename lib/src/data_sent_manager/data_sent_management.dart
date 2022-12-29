import '../events/events.dart';
import '../models/models.dart';
import '../tcp_socket_set_up.dart';

class DataSentManagement {
  final Map<String, WaitingData> _mapVersionToWaitingData = {};
  final Map<String, List<StatusDataSent>> _mapVersionToStatusDataSent = {};

  get mapVersionToWaitingData => _mapVersionToWaitingData;

  get mapVersionToStatusDataSent => _mapVersionToStatusDataSent;

  void addItemToListStatusDataSent(
      String version, StatusDataSent statusDataSent) {
    if (_mapVersionToStatusDataSent.containsKey(version)) {
      _mapVersionToStatusDataSent[version]!.add(statusDataSent);
      Future.delayed(
        const Duration(minutes: 3),
        () {
          if (_mapVersionToStatusDataSent[version] != null) {
            _mapVersionToStatusDataSent.remove(version);
          }
        },
      );
    } else {
      _mapVersionToStatusDataSent[version] = [statusDataSent];
    }
  }

  void deleteStatusDataSent(String version, TCPSocketEvent tcpSocketEvent) {
    if (_mapVersionToStatusDataSent[version] != null) {
      _mapVersionToStatusDataSent[version]!.removeWhere(
          (element) => element.event.totalSplit == tcpSocketEvent.totalSplit);
      if (_mapVersionToStatusDataSent[version]!.isEmpty) {
        _mapVersionToStatusDataSent.remove(version);
      }
    }
  }

  void addNewWaitingData(TCPSocketEvent tcpSocketEvent) {
    _mapVersionToWaitingData[tcpSocketEvent.version] = WaitingData(
      type: tcpSocketEvent.type,
      splitNumber: tcpSocketEvent.splitNumber,
      version: tcpSocketEvent.version,
      mapTotalSplitToDataSplit: {
        tcpSocketEvent.totalSplit: tcpSocketEvent.data,
      },
    );
    Future.delayed(
      const Duration(minutes: 3),
      () {
        if (_mapVersionToWaitingData[tcpSocketEvent.version] != null) {
          _mapVersionToWaitingData.remove(tcpSocketEvent.version);
        }
      },
    );
  }

  void updateWaitingData(TCPSocketEvent tcpSocketEvent) =>
      _mapVersionToWaitingData[tcpSocketEvent.version]!
              .mapTotalSplitToDataSplit[tcpSocketEvent.totalSplit] =
          tcpSocketEvent.data;

  void replaceWaitingData(String version, WaitingData waitingData) =>
      _mapVersionToWaitingData[version] = waitingData;

  void removeWaitingData(String version) =>
      _mapVersionToWaitingData.remove(version);

  void sendDataError(String version) async {
    while (_mapVersionToStatusDataSent[version] != null) {
      if (_mapVersionToStatusDataSent[version]!.isEmpty) {
        _mapVersionToStatusDataSent.remove(version);
        break;
      }
      final List<StatusDataSent> listStatusDataSent = List.from(
        _mapVersionToStatusDataSent[version] ?? [],
      );
      final List<StatusDataSent> needToRemove = [];
      for (final statusDataSent in listStatusDataSent) {
        if (statusDataSent.timesToDelete > 9) {
          needToRemove.add(statusDataSent);
          continue;
        }
        statusDataSent.socketChannel
            .writeUTF8(statusDataSent.event.toJsonString());
        final indexOf =
            _mapVersionToStatusDataSent[version]!.indexOf(statusDataSent);
        _mapVersionToStatusDataSent[version]![indexOf] =
            statusDataSent.copyWith(
          timesToDelete: statusDataSent.timesToDelete + 1,
        );
        await Future.delayed(TCPSocketSetUp.timeoutEachTimesSendData);
      }
      for (var remover in needToRemove) {
        _mapVersionToStatusDataSent[version]?.removeWhere(
          (element) => element.event.totalSplit == remover.event.totalSplit,
        );
      }
    }
  }
}
