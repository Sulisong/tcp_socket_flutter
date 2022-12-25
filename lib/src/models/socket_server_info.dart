import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../tcp_socket_set_up.dart';

class SocketServerInfo extends Equatable {
  final String ip;
  final String deviceServerName;
  final bool serverIsRunning;

  const SocketServerInfo({
    required this.ip,
    required this.deviceServerName,
    required this.serverIsRunning,
  });

  String get hostServer => '$ip:${TCPSocketSetUp.port}';

  bool isNotNone() => this != SocketServerInfo.none;

  static const SocketServerInfo none = SocketServerInfo(
    ip: '',
    deviceServerName: '',
    serverIsRunning: false,
  );

  factory SocketServerInfo.fromJson(Map<String, dynamic> json) => SocketServerInfo(
        ip: json['ip'] as String,
        deviceServerName: json['nameDevice'] as String,
        serverIsRunning: json['serverIsRunning'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'nameDevice': deviceServerName,
        'serverIsRunning': serverIsRunning,
      };

  String toJsonString() => jsonEncode(toJson());

  factory SocketServerInfo.fromJsonString(String json) =>
      SocketServerInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);

  SocketServerInfo copyWith({
    String? ip,
    String? deviceServerName,
    bool? serverIsRunning,
  }) =>
      SocketServerInfo(
        ip: ip ?? this.ip,
        deviceServerName: deviceServerName ?? this.deviceServerName,
        serverIsRunning: serverIsRunning ?? this.serverIsRunning,
      );

  @override
  List<Object?> get props => [
        ip,
        deviceServerName,
        serverIsRunning,
      ];
}
