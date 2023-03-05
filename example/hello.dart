import 'package:dart_odbc/src/model.dart';
import 'package:json_annotation/json_annotation.dart' as json_annotation;

part 'hello.g.dart';

@json_annotation.JsonSerializable()
class HelloModel extends Model {
  HelloModel({
    required this.userId,
    required this.message,
    required this.timestamp,
    required this.metric,
  });

  HelloModel.empty()
      : userId = 0,
        message = '',
        timestamp = '',
        metric = 0;

  final int userId;
  final String message;
  final String timestamp;
  final double metric;

  Map<String, dynamic> toJson() => _$HelloModelToJson(this);

  @override
  String toString() => toJson().toString();

  @override
  HelloModel fromJson(Map<String, dynamic> json) {
    return _$HelloModelFromJson(json);
  }
}
