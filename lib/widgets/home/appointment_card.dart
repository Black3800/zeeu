import 'dart:ui';

import 'package:ZeeU/utils/palette.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard(
      {Key? key,
      required this.image,
      required this.name,
      required this.institute,
      this.startTime,
      this.endTime})
      : super(key: key);

  final String image;
  final String name;
  final String institute;
  final String? startTime;
  final String? endTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Container(
        width: double.infinity,
        height: 92,
        decoration: BoxDecoration(
            color: Palette.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(53, 53, 53, 0.10000000149011612),
                offset: Offset(2, 3),
                blurRadius: 20,
              ),
            ],
            border: Border.all(
              color: const Color.fromRGBO(225, 225, 225, 1),
              width: 1,
            )),
        child: Row(
          children: [
            Container(
              width: 7,
              decoration: const BoxDecoration(
                  color: Palette.aquamarine,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  )),
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
                        future: FirebaseStorage.instance
                            .refFromURL(image)
                            .getDownloadURL(),
                        builder: (context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image(
                              image: NetworkImage(snapshot.data!),
                              fit: BoxFit.cover,
                            );
                          }
                          return const CircularProgressIndicator();
                        }),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Palette.jet,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              institute,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w400,
                                color: Palette.gray,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        if (startTime != null)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(startTime!),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(endTime!),
                            ],
                          )
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
