import 'request_model.dart';

class IdRequestModel extends RequestModel {
  IdRequestModel({
    required this.id,
    RequestProgressListener? progressListener,
  }) : super(progressListener);

  final int id;

  @override
  List<Object?> get props => [id];

  @override
  Future<Map<String, dynamic>> toMap() async => {'id': id};
}
