import 'package:ZeeU/utils/palette.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatCard extends StatelessWidget {
  const ChatCard(
      {Key? key,
      required this.image,
      required this.name,
      required this.text,
      required this.time,
      required this.seen,
      this.onTap})
      : super(key: key);

  final Function()? onTap;
  final String image, name, text, time;
  final bool seen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0.2),
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: Palette.gray.shade100,
            width: 0.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.white.withOpacity(.5),
              Palette.white.withOpacity(.3)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder(
                  future: FirebaseStorage.instance
                      .refFromURL(image)
                      .getDownloadURL(),
                  builder: (context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(53, 53, 53, 0.25),
                                offset: Offset(1, 2),
                                blurRadius: 10)
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28.0,
                          backgroundImage: NetworkImage(snapshot.data!),
                          backgroundColor: Colors.transparent,
                        ),
                      );
                      //     Image(
                      //   image: NetworkImage(snapshot.data!),
                      //   fit: BoxFit.cover,
                      // );
                    }
                    return const CircularProgressIndicator();
                  }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w700,
                          color: Palette.jet,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          color: Palette.jet,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w400,
                      color: Palette.gray,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    height: seen ? 10 : 0,
                  ),
                  if (!seen) disc()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget disc() => Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(130, 245, 195, 0.5),
              offset: Offset(1, 2),
              blurRadius: 5)
        ], shape: BoxShape.circle, color: Palette.aquamarine),
      );
}
