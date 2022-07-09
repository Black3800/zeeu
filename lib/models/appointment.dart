import 'package:ZeeU/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  AppUser doctor;
  AppUser patient;
  DateTime start;
  DateTime end;
  String? id;
  
  Appointment({
    required this.doctor,
    required this.patient,
    required this.start,
    required this.end,
    this.id
  });

  Appointment.fromJson(Map<dynamic, dynamic> json)
    : doctor = AppUser(uid: json['doctor']),
      patient = AppUser(uid: json['patient']),
      start = Timestamp(json['start']['_seconds'], json['start']['_nanoseconds']).toDate(),
      end = Timestamp(json['end']['_seconds'], json['end']['_nanoseconds']).toDate(),
      id = json['id'];

  Map<String, Object?> toJson() => <String, Object?>{
    'doctor': doctor.uid,
    'patient': patient.uid,
    'start': start.toIso8601String(),
    'end': end.toIso8601String()
  };
}