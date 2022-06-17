import 'package:ZeeU/utils/palette.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    Key? key,
    required this.image,
    required this.name,
    required this.institute,
    required this.startTime,
    required this.endTime
  }) : super(key: key);

  final String image;
  final String name;
  final String institute;
  final String startTime;
  final String endTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Container(
        width: double.infinity,
        height: 92,
        decoration: BoxDecoration(
          color: Palette.white
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              color: Palette.aquamarine,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: FutureBuilder(
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
                  ),
                  Column(
                    children: [
                      Text(name),
                      Text(institute)
                    ]
                  ),
                  Column(
                    children: [
                      Text(startTime),
                      Text(endTime)
                    ]
                  )
                ]
              ),
            )
          ]
        )
      ),
    );
  }
}