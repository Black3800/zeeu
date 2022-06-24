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
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(children: [
                const SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Search',
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .apply(color: Palette.jet),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
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
                                widget.notifyRouteChange('push', '/doctors');
                              },
                            ))
                        .toList())
              ])),
        ));
  }
}
