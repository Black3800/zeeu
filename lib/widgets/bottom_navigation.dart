import 'dart:ui';

import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/utils/tab_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation(
      {Key? key, required this.currentTab, required this.onSelectTab})
      : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.5),
                width: 0.5,
              ),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Palette.white.withOpacity(.3),
                    Palette.white.withOpacity(.225)
                  ])),
          child: Row(children: [
            _buildItem(TabItem.home),
            _buildItem(TabItem.chats),
            _buildItem(TabItem.search),
            _buildItem(TabItem.settings)
          ]),
        ),
      ),
    );
  }

  Widget _buildItem(TabItem tabItem) {
    return Expanded(
        child: InkWell(
      onTap: () => onSelectTab(tabItem),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color:
                  _isCurrentTab(tabItem) ? Palette.white : Colors.transparent),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(tabIcons[tabItem],
                color: _isCurrentTab(tabItem)
                    ? activeTabColor[tabItem]
                    : Palette.gray),
            Text(tabName[tabItem]!,
                style: GoogleFonts.roboto(
                    color: _isCurrentTab(tabItem)
                        ? activeTabColor[tabItem]
                        : Palette.gray))
          ])),
    ));
  }

  bool _isCurrentTab(TabItem item) {
    return currentTab == item;
  }
}
