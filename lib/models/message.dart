import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class Message {
  String text;
  bool isText;
  bool isFromDoctor;
  DateTime time;

  Message({
    required this.text,
    required this.isText,
    required this.isFromDoctor,
    required this.time
  });

  Message.fromJson(Map<dynamic, dynamic> json)
    : text = json['text'],
      isText = json['is_text'],
      isFromDoctor = json['from_doctor'],
      time = (json['time'] as Timestamp).toDate();

  Map<String, Object?> toJson() => <String, Object?>{
    'text': text,
    'is_text': isText,
    'from_doctor': isFromDoctor,
    'time': time.toIso8601String()
  };
}