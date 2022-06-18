import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class Message {
  String content;
  String type;
  bool isFromDoctor;
  DateTime time;

  Message({
    required this.content,
    required this.type,
    required this.isFromDoctor,
    required this.time
  });

  Message.fromJson(Map<dynamic, dynamic> json)
    : content = json['content'],
      type = json['type'],
      isFromDoctor = json['from_doctor'],
      time = (json['time'] as Timestamp).toDate();

  Map<String, Object?> toJson() => <String, Object?>{
    'content': content,
    'type': type,
    'from_doctor': isFromDoctor,
    'time': Timestamp.fromDate(time)
  };
}