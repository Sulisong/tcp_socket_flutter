import 'package:collection/collection.dart';

class WaitingData {
  final String type;
  final int splitNumber;
  final String version;
  final Map<int, String> mapTotalSplitToDataSplit;
  final bool status;

  const WaitingData({
    required this.type,
    required this.splitNumber,
    required this.version,
    required this.mapTotalSplitToDataSplit,
    this.status = false,
  });

  bool isReceivedFullData() =>
      mapTotalSplitToDataSplit.keys.length == splitNumber;

  String getDataAggregated() => mapTotalSplitToDataSplit.entries
      .sorted((a, b) => a.key.compareTo(b.key))
      .map((e) => e.value)
      .join('');

  Map<String, dynamic> toJson() => {
        'type': type,
        'splitNumber': splitNumber,
        'version': version,
        'mapTotalSplitToDataSplit': mapTotalSplitToDataSplit,
        'status': status,
      };

  WaitingData copyWith({
    String? type,
    int? splitNumber,
    String? version,
    Map<int, String>? mapTotalSplitToDataSplit,
    bool? status,
  }) {
    return WaitingData(
      type: type ?? this.type,
      splitNumber: splitNumber ?? this.splitNumber,
      version: version ?? this.version,
      mapTotalSplitToDataSplit:
          mapTotalSplitToDataSplit ?? this.mapTotalSplitToDataSplit,
      status: status ?? this.status,
    );
  }
}
