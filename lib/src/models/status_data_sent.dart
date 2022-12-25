import '../events/events.dart';
import '../socket_channel/socket_channel.dart';

class StatusDataSent {
  final TCPSocketEvent event;
  final SocketChannel socketChannel;
  final bool status;
  final int timesToDelete;

  const StatusDataSent({
    required this.event,
    required this.socketChannel,
    required this.status,
    this.timesToDelete = 0,
  });

  StatusDataSent copyWith({
    TCPSocketEvent? event,
    SocketChannel? socketChannel,
    bool? status,
    int? timesToDelete,
  }) {
    return StatusDataSent(
      event: event ?? this.event,
      socketChannel: socketChannel ?? this.socketChannel,
      status: status ?? this.status,
      timesToDelete: timesToDelete ?? this.timesToDelete,
    );
  }

  bool isOutOfTimeLimit() => timesToDelete >= 10;

  Map<String, dynamic> toJson() => {
        'event': event.toJson(),
        'socketChannel': socketChannel,
        'status': status,
        'timesToDelete': timesToDelete,
      };
}
