import '../socket_channel/socket_channel.dart';
import 'device_info.dart';

class SocketConnection {
  final SocketChannel socketChannel;
  final DeviceInfo deviceInfo;

  const SocketConnection({
    required this.socketChannel,
    required this.deviceInfo,
  });

  SocketConnection copyWith({
    SocketChannel? socketChannel,
    DeviceInfo? deviceInfo,
  }) =>
      SocketConnection(
        socketChannel: socketChannel ?? this.socketChannel,
        deviceInfo: deviceInfo ?? this.deviceInfo,
      );
}
