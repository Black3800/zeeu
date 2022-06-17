import 'package:ZeeU/utils/palette.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.image,
    required this.name,
    required this.text,
    required this.time,
    this.seen = true,
    this.onTap
  }) : super(key: key);

  final Function()? onTap;
  final String image, name, text, time;
  final bool seen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Palette.white
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
              future: FirebaseStorage.instance.refFromURL(image).getDownloadURL(),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Image(
                    image: NetworkImage(snapshot.data!),
                    fit: BoxFit.cover,
                  );
                }
                return const CircularProgressIndicator();
              }
            ),
            Column(
              children: [
                Text(name),
                Text(text)
              ],
            ),
            Column(
              children: [
                Text(time),
                if (!seen) disc()
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget disc() => Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Palette.aquamarine
                  ),
                );
}