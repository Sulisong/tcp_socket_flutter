import 'package:collection/collection.dart';

class WaitingData {
  final String type;
  final int splitNumber;
  final String version;
  final Map<int, String> mapTotalSplitToDataSplit;

  const WaitingData({
    required this.type,
    required this.splitNumber,
    required this.version,
    required this.mapTotalSplitToDataSplit,
  });

  bool isReceivedFullData() => mapTotalSplitToDataSplit.keys.length == splitNumber;

  String getDataAggregated() => mapTotalSplitToDataSplit.entries
      .sorted((a, b) => a.key.compareTo(b.key))
      .map((e) => e.value)
      .join('');

  Map<String, dynamic> toJson() => {
        'type': type,
        'splitNumber': splitNumber,
        'version': version,
        'mapTotalSplitToDataSplit': mapTotalSplitToDataSplit,
      };
}
