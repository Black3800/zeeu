import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/utils/upload.dart';
import 'package:ZeeU/widgets/chats/appointment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MessageBar extends StatefulWidget {
  const MessageBar(
      {Key? key,
      required this.textController,
      required this.onSubmitText,
      required this.onSubmitImage,
      this.onSubmitAppointment})
      : super(key: key);

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
        context: context, builder: (context) => const AppointmentDialog());
    if (pickedTime != null)
      widget.onSubmitAppointment!(pickedTime['start'], pickedTime['end']);
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
                final XFile? image =
                    await picker.pickImage(source: ImageSource.camera);
                if (image == null) return;
                final bytes = await image.readAsBytes();
                final path = await Upload.image(bytes);
                widget.onSubmitImage(path);
              },
              icon: const Icon(
                Icons.camera_alt,
                size: 24,
                color: Palette.gray,
              ),
              iconSize: 24,
              padding: EdgeInsets.zero,
              splashRadius: 24),
          IconButton(
              onPressed: () async {
                final picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image == null) return;
                final bytes = await image.readAsBytes();
                final path = await Upload.image(bytes);
                widget.onSubmitImage(path);
              },
              icon: const Icon(
                Icons.photo_library,
                size: 24,
                color: Palette.gray,
              ),
              iconSize: 24,
              padding: EdgeInsets.zero,
              splashRadius: 24),
          if (widget.onSubmitAppointment != null)
            IconButton(
                onPressed: () => _showAppointmentDialog(context),
                icon: const Icon(
                  Icons.calendar_month,
                  size: 24,
                  color: Palette.gray,
                ),
                iconSize: 24,
                padding: EdgeInsets.zero,
                splashRadius: 24),
          Expanded(
            child: TextFormField(
              controller: widget.textController,
              minLines: 1,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 17.0),
                fillColor: Palette.white.withOpacity(0.5),
                filled: true,
                hintText: 'Aa',
                hintStyle: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  color: Palette.gray,
                  fontSize: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(255, 255, 255, 0.5),
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
              onPressed: widget.onSubmitText,
              icon: const Icon(
                Icons.send,
                size: 24,
                color: Palette.gray,
              ),
              iconSize: 24,
              padding: EdgeInsets.zero,
              splashRadius: 24),
        ],
      ),
    );
  }
}
