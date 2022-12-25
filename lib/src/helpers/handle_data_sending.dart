import '../tcp_socket_set_up.dart';

class HandleDataSending {
  static List<String> splitData(String dataString) {
    if (dataString.isEmpty) return [];
    if (dataString.length <= TCPSocketSetUp.numberSplit) return [dataString];
    final listData = <String>[];
    final times = (dataString.length / TCPSocketSetUp.numberSplit).ceil();
    for (int i = 0; i < times; i++) {
      if ((i + 1) * TCPSocketSetUp.numberSplit > dataString.length) {
        listData.add(
          dataString.substring(
            i * TCPSocketSetUp.numberSplit,
          ),
        );
      } else {
        listData.add(
          dataString.substring(
            i * TCPSocketSetUp.numberSplit,
            (i + 1) * TCPSocketSetUp.numberSplit,
          ),
        );
      }
    }
    return listData;
  }
}
