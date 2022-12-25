import 'dart:convert';

import 'package:equatable/equatable.dart';

class DeviceInfo extends Equatable {
  final String ip;
  final String subnet;
  final int? sourcePort;
  final String deviceName;

  const DeviceInfo({
    required this.ip,
    required this.subnet,
    this.sourcePort,
    required this.deviceName,
  });

  static const DeviceInfo none = DeviceInfo(
    ip: '',
    subnet: '',
    sourcePort: null,
    deviceName: '',
  );

  static genSubnet(String ip) => ip.substring(0, ip.lastIndexOf('.'));

  bool isNotNone() => this != DeviceInfo.none;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        ip: json['ip'] as String,
        subnet: json['subnet'] as String,
        sourcePort: json['sourcePort'] as int?,
        deviceName: json['nameDevice'] as String,
      );

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'subnet': subnet,
        'sourcePort': sourcePort,
        'nameDevice': deviceName,
      };

  factory DeviceInfo.fromJsonString(String json) =>
      DeviceInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());

  DeviceInfo copyWith({
    String? ip,
    String? subnet,
    int? sourcePort,
    String? deviceName,
  }) =>
      DeviceInfo(
        ip: ip ?? this.ip,
        subnet: subnet ?? this.subnet,
        sourcePort: sourcePort ?? this.sourcePort,
        deviceName: deviceName ?? this.deviceName,
      );

  @override
  List<Object?> get props => [
        ip,
        subnet,
        sourcePort,
        deviceName,
      ];
}
