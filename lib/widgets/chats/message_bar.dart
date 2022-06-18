import 'package:ZeeU/utils/upload.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageBar extends StatelessWidget {
  const MessageBar({
    Key? key,
    required this.textController,
    required this.onSubmitText,
    required this.onSubmitImage
  }) : super(key: key);

  final TextEditingController textController;
  final Function() onSubmitText;
  final Function(String) onSubmitImage;

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
              onSubmitImage(path);
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
          Expanded(child:
            TextFormField(
              controller: textController
            )
          ),
          IconButton(
            onPressed: onSubmitText,
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