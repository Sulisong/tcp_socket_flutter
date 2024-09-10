import 'dart:async';
import 'dart:io';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:network_info_plus/network_info_plus.dart';

import 'models/models.dart';

class TCPSocketSetUp {
  static SocketConfig _config = const SocketConfig();
  static DeviceInfo _deviceInfo = DeviceInfo.none;
  static final StreamController<DeviceInfo> _streamDeviceInfo =
      StreamController<DeviceInfo>.broadcast();

  static void setConfig(SocketConfig config) => _config = config;

  static void setDeviceInfo(DeviceInfo deviceInfo) => _deviceInfo = deviceInfo;

  static void _addSinkDeviceInfo(DeviceInfo deviceInfo) =>
      _streamDeviceInfo.sink.add(deviceInfo);

  static SocketConfig get config => _config;

  static int get port => config.port;

  static Duration get timeoutEachTimesSendData =>
      config.timeoutEachTimesSendData;

  static int get numberSplit => config.numberSplit;

  static DeviceInfo get deviceInfo => _deviceInfo;

  static Stream<DeviceInfo> get streamDeviceInfoStream =>
      _streamDeviceInfo.stream;

  static String get ip => deviceInfo.ip;

  static String get subnet => deviceInfo.subnet;

  static int? get sourcePort => deviceInfo.sourcePort;

  static String get deviceName => deviceInfo.deviceName;

  static Future init(String ip) async {
    String wifiIP = ip;
    // if (kIsWeb) {
    //   wifiIP = await Ipify.ipv4();
    // } else {
    //   wifiIP = await NetworkInfo().getWifiIP() ?? '';
    // }
    String wifiSubnet = '';
    String deviceName = '';
    if (wifiIP.isEmpty) throw Exception('Get IP address failed');
    wifiSubnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      deviceName = '${deviceInfo.brand} ${deviceInfo.model}';
    }
    if (Platform.isIOS) {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      deviceName = '${deviceInfo.model} IOS: ${deviceInfo.systemVersion}';
    }
    if (kIsWeb) {
      final deviceInfo = await DeviceInfoPlugin().webBrowserInfo;
      deviceName = '${deviceInfo.platform} ${deviceInfo.hardwareConcurrency}';
    }
    setDeviceInfo(
      DeviceInfo(
        ip: wifiIP,
        subnet: wifiSubnet,
        deviceName: deviceName,
      ),
    );
    _addSinkDeviceInfo(deviceInfo);
  }
}
