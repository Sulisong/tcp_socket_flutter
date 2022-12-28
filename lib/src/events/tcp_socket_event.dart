import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'events.dart';

class TCPSocketEvent extends Equatable {
  final String type;
  final String data;
  final int splitNumber;
  final int totalSplit;
  final String version;

  const TCPSocketEvent({
    required this.type,
    required this.data,
    this.splitNumber = 1,
    this.totalSplit = 1,
    this.version = '',
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        'splitNumber': splitNumber,
        'totalSplit': totalSplit,
        'version': version,
      };

  factory TCPSocketEvent.fromJson(Map<String, dynamic> json) => TCPSocketEvent(
        type: json['type'] as String,
        data: json['data'] as String,
        splitNumber: json['splitNumber'] as int? ?? 1,
        totalSplit: json['totalSplit'] as int? ?? 1,
        version: json['version'] as String? ?? '',
      );

  String toJsonString() => jsonEncode(toJson());

  factory TCPSocketEvent.fromJsonString(String json) {
    {
      try {
        return TCPSocketEvent.fromJson(
            jsonDecode(json) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('------------------------------------------------------------');
        debugPrint('TCPSocketEvent.fromJsonString: $e');
        debugPrint('------------------------------------------------------------');
        return const TCPSocketEvent(
          type: TCPSocketDefaultType.$errorSending,
          data: '',
          splitNumber: 1,
          totalSplit: 1,
          version: '',
        );
      }
    }
  }

  TCPSocketEvent copyWith({
    String? type,
    String? data,
    int? splitNumber,
    int? totalSplit,
    String? version,
  }) =>
      TCPSocketEvent(
        type: type ?? this.type,
        data: data ?? this.data,
        splitNumber: splitNumber ?? this.splitNumber,
        totalSplit: totalSplit ?? this.totalSplit,
        version: version ?? this.version,
      );

  @override
  List<Object?> get props => [
        type,
        data,
        splitNumber,
        totalSplit,
        version,
      ];
}
