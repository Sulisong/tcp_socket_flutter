import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../tcp_socket_set_up.dart';

class SocketServerInfo extends Equatable {
  final String ip;
  final String deviceServerName;
  final bool serverIsRunning;
  final dynamic moreInfo;

  const SocketServerInfo({
    required this.ip,
    required this.deviceServerName,
    required this.serverIsRunning,
    this.moreInfo,
  });

  String get hostServer => '$ip:${TCPSocketSetUp.port}';

  bool isNotNone() => this != SocketServerInfo.none;

  static const SocketServerInfo none = SocketServerInfo(
    ip: '',
    deviceServerName: '',
    serverIsRunning: false,
    moreInfo: null,
  );

  factory SocketServerInfo.fromJson(Map<String, dynamic> json) =>
      SocketServerInfo(
        ip: json['ip'] as String,
        deviceServerName: json['nameDevice'] as String,
        serverIsRunning: json['serverIsRunning'] as bool,
        moreInfo: json['moreInfo'],
      );

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'nameDevice': deviceServerName,
        'serverIsRunning': serverIsRunning,
        'moreInfo': moreInfo,
      };

  String toJsonString() => jsonEncode(toJson());

  factory SocketServerInfo.fromJsonString(String json) =>
      SocketServerInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);

  SocketServerInfo copyWith({
    String? ip,
    String? deviceServerName,
    bool? serverIsRunning,
    dynamic moreInfo,
  }) =>
      SocketServerInfo(
        ip: ip ?? this.ip,
        deviceServerName: deviceServerName ?? this.deviceServerName,
        serverIsRunning: serverIsRunning ?? this.serverIsRunning,
        moreInfo: moreInfo ?? this.moreInfo,
      );

  @override
  List<Object?> get props => [
        ip,
        deviceServerName,
        serverIsRunning,
        moreInfo,
      ];
}
