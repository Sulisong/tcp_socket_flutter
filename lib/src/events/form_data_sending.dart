import 'dart:convert';

import 'package:equatable/equatable.dart';

class FormDataSending extends Equatable {
  final String type;
  final String data;

  const FormDataSending({
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
      };

  factory FormDataSending.fromJson(Map<String, dynamic> json) => FormDataSending(
        type: json['type'] as String,
        data: json['data'] as String,
      );

  String toJsonString() => jsonEncode(toJson());

  factory FormDataSending.fromJsonString(String json) =>
      FormDataSending.fromJson(jsonDecode(json) as Map<String, dynamic>);

  FormDataSending copyWith({
    String? type,
    String? data,
  }) =>
      FormDataSending(
        type: type ?? this.type,
        data: data ?? this.data,
      );

  @override
  List<Object?> get props => [
        type,
        data,
      ];
}
