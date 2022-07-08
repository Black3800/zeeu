import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class Chat {
  AppUser doctor;
  AppUser patient;
  String latestMessageText;
  DateTime latestMessageTime;
  bool latestMessageSeenDoctor;
  bool latestMessageSeenPatient;
  List<Message>? messages;
  String? id;

  Chat({
    required this.doctor,
    required this.patient,
    required this.latestMessageText,
    required this.latestMessageTime,
    required this.latestMessageSeenDoctor,
    required this.latestMessageSeenPatient,
    this.messages,
    this.id
  });

  Chat.fromJson(Map<dynamic, dynamic> json, { String? id })
    : doctor = AppUser(uid: json['doctor']),
      patient = AppUser(uid: json['patient']),
      latestMessageText = json['latest_message_text'],
      latestMessageTime = Timestamp(json['latest_message_time']['_seconds'], json['latest_message_time']['_nanoseconds']).toDate(),
      latestMessageSeenDoctor = json['latest_message_seen_doctor'],
      latestMessageSeenPatient = json['latest_message_seen_patient'],
      messages = json['messages'],
      this.id = id;

  Map<String, Object?> toJson() => <String, Object?>{
    'doctor': doctor,
    'patient': patient,
    'latest_message_text': latestMessageText,
    'latest_message_time': latestMessageTime,
    'latest_message_seen_doctor': latestMessageSeenDoctor,
    'latest_message_seen_patient': latestMessageSeenPatient,
    'messages': messages
  };
}