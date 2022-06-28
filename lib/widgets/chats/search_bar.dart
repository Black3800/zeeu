import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key, required this.onSubmit}) : super(key: key);

  final Function(String)? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: TextFormField(
            minLines: 1,
            decoration: InputDecoration(
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 50, maxHeight: 20),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(0.0),
                child: Icon(
                  Icons.search_outlined,
                  color: Palette.aquamarine,
                ),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 22.0),
              fillColor: Palette.honeydew,
              filled: true,
              hintText: 'Search',
              hintStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: Palette.aquamarine.shade500,
                fontSize: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: Palette.aquamarine,
                  width: 0.7,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: Palette.aquamarine.shade600,
                  width: 1,
                ),
              ),
            ),
            onFieldSubmitted: onSubmit,
            autofocus: false));
  }
}
