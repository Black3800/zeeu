import 'package:ZeeU/utils/constants.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/search/specialty_card.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.notifyRouteChange})
      : super(key: key);

  final Function(String, String) notifyRouteChange;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: GreenClipper(),
                    child: Container(
                      color: Palette.honeydew,
                      height: 145,
                    ),
                  ),
                  ClipPath(
                    clipper: WhiteClipper(),
                    child: Container(
                      color: Palette.white,
                      height: 140,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Search',
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .apply(color: Palette.jet),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(children: [
                    const Align(
                      alignment: Alignment.topCenter,
                      child: Text('Who are you seeking help from?'),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Wrap(
                        alignment: WrapAlignment.spaceAround,
                        runAlignment: WrapAlignment.spaceAround,
                        spacing: 20,
                        runSpacing: 20,
                        children: Constants.specialties
                            .map((e) => SpecialtyCard(
                                  specialty: e,
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed('/doctors', arguments: e);
                                    widget.notifyRouteChange(
                                        'push', '/doctors');
                                  },
                                ))
                            .toList()),      
                    const SizedBox(
                      height: 80,
                    )
                  ])),
            ],
          ),
        ));
  }
}

class WhiteClipper extends CustomClipper<Path> {
  double pi = 3.14;
  @override
  Path getClip(Size size) {
    final roundingHeight = size.height * 4 / 5;

    final filledRectangle =
        Rect.fromLTRB(0, 0, size.width, size.height - roundingHeight);

    final roundingRectangle = Rect.fromLTRB(
        -75, size.height - roundingHeight * 2, size.width + 75, size.height);

    final path = Path();
    path.addRect(filledRectangle);
    path.arcTo(roundingRectangle, pi, -pi, true);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class GreenClipper extends CustomClipper<Path> {
  double pi = 3.14159265359;
  @override
  Path getClip(Size size) {
    final roundingHeight = size.height * 4 / 5;

    final filledRectangle =
        Rect.fromLTRB(0, 0, size.width, size.height - roundingHeight);

    final roundingRectangle = Rect.fromLTRB(
        -75, size.height - roundingHeight * 2, size.width + 90, size.height);

    final path = Path();
    path.addRect(filledRectangle);
    path.arcTo(roundingRectangle, pi, -pi, true);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
