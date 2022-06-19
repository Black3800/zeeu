import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/appointment.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentDialog extends StatefulWidget {
  const AppointmentDialog({ Key? key }) : super(key: key);

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  late DateTime? _appointmentStart;
  late DateTime? _appointmentEnd;

  @override
  void initState() {
    super.initState();
    _appointmentStart = DateTime.now();
    _appointmentStart = DateTime(_appointmentStart!.year, _appointmentStart!.month, _appointmentStart!.day);
    _appointmentEnd = DateTime.parse(_appointmentStart!.toIso8601String());
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(builder: (context, user, child) =>
      AlertDialog(
        title: const Text('Make an appointment'),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 220),
          child: Column(
            children: [
              const Text('Date'),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _appointmentStart!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365))
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _appointmentStart = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        _appointmentStart!.hour,
                        _appointmentStart!.minute
                      );
                      _appointmentEnd = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        _appointmentEnd!.hour,
                        _appointmentEnd!.minute
                      );
                    });
                  }
                },
                child: Text(DateFormat('yMMMMd').format(_appointmentStart!))
              ),
              const Text('From'),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 0, minute: 0)
                  );
                  if (pickedTime != null) {
                    setState(() => _appointmentStart = DateTime(
                      _appointmentStart!.year,
                      _appointmentStart!.month,
                      _appointmentStart!.day,
                      pickedTime.hour,
                      pickedTime.minute)
                    );
                  }
                },
                child: Text(DateFormat('Hm').format(_appointmentStart!))
              ),
              const Text('Until'),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 0, minute: 0)
                  );
                  if (pickedTime != null) {
                    setState(() => _appointmentEnd = DateTime(
                      _appointmentStart!.year,
                      _appointmentStart!.month,
                      _appointmentStart!.day,
                      pickedTime.hour,
                      pickedTime.minute)
                    );
                  }
                },
                child: Text(DateFormat('Hm').format(_appointmentEnd!))
              ),
            ]
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Close')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop({
                'start': _appointmentStart,
                'end': _appointmentEnd
              });
            },
            child: const Text('Confirm')
          )
        ],
      )
    );
  }
}