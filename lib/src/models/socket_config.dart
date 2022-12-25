class SocketConfig {
  final int port;
  final Duration timeoutEachTimesSendData;
  final int numberSplit;

  const SocketConfig({
    this.port = 3001,
    this.timeoutEachTimesSendData = const Duration(milliseconds: 500),
    this.numberSplit = 10000,
  });

  Map<String, dynamic> toJson() {
    return {
      'port': port,
      'timeoutEachTimesSendData': timeoutEachTimesSendData.inMilliseconds,
      'numberSplit': numberSplit,
    };
  }
}
