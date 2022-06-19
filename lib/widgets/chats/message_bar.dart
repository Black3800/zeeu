import 'package:ZeeU/utils/upload.dart';
import 'package:ZeeU/widgets/chats/appointment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MessageBar extends StatefulWidget {
  const MessageBar({
    Key? key,
    required this.textController,
    required this.onSubmitText,
    required this.onSubmitImage,
    this.onSubmitAppointment
  }) : super(key: key);

  final TextEditingController textController;
  final Function() onSubmitText;
  final Function(String) onSubmitImage;
  final Function(DateTime, DateTime)? onSubmitAppointment;

  @override
  State<MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  Future<void> _showAppointmentDialog(context) async {
    final pickedTime = await showDialog(
      context: context,
      builder: (context) => AppointmentDialog()
    );
    if(pickedTime != null) widget.onSubmitAppointment!(pickedTime['start'], pickedTime['end']);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () async {
              final picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.camera);
              if (image == null) return;
              final bytes = await image.readAsBytes();
              final path = await Upload.image(bytes);
              widget.onSubmitImage(path);
            },
            icon: const Icon(Icons.camera_alt, size: 24),
            iconSize: 24,
            padding: EdgeInsets.zero,
            splashRadius: 24
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.photo, size: 24),
            iconSize: 24,
            padding: EdgeInsets.zero,
            splashRadius: 24
          ),
          if (widget.onSubmitAppointment != null)
            IconButton(
              onPressed: () => _showAppointmentDialog(context),
              icon: const Icon(Icons.calendar_month, size: 24),
              iconSize: 24,
              padding: EdgeInsets.zero,
              splashRadius: 24
            ),
          Expanded(child:
            TextFormField(
              controller: widget.textController
            )
          ),
          IconButton(
            onPressed: widget.onSubmitText,
            icon: const Icon(Icons.send, size: 24),
            iconSize: 24,
            padding: EdgeInsets.zero,
            splashRadius: 24
          ),
        ]
      )
    );
  }
}