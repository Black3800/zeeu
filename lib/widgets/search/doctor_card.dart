import 'package:ZeeU/utils/palette.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard(
      {Key? key,
      required this.image,
      required this.name,
      required this.specialty,
      required this.institute,
      required this.contact,
      this.onTap})
      : super(key: key);

  final String image;
  final String name;
  final String specialty;
  final String institute;
  final String contact;
  final Function(BuildContext)? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: InkWell(
        onTap: () => onTap?.call(context),
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
                    blurRadius: 20),
              ],
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 1),
                width: 1,
              ),
            ),
            child: Row(children: [
              Container(
                width: 7,
                decoration: const BoxDecoration(
                  color: Palette.aquamarine,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                  color: Palette.jet,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                specialty,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w400,
                                  color: Palette.jet,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(
                                height: 2.5,
                              ),
                              Text(
                                institute,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w400,
                                  color: Palette.jet,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                contact,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w400,
                                  color: Palette.gray,
                                  fontSize: 12,
                                ),
                              )
                            ]),
                      ),
                    ]),
              )
            ])),
      ),
    );
  }
}
