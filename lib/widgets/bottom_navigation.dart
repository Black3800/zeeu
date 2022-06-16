import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/utils/tab_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key? key,
    required this.currentTab,
    required this.onSelectTab
  }) : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Palette.white.withOpacity(.3), Palette.white.withOpacity(.225)]
        )
      ),
      child: Row(
        children: [
          _buildItem(TabItem.home),
          _buildItem(TabItem.chats),
          _buildItem(TabItem.search),
          _buildItem(TabItem.settings)
        ]
      ),
    );
  }

  Widget _buildItem(TabItem tabItem) {
    return Expanded(
      child: InkWell(
        onTap: () => onSelectTab(tabItem),
        child: Container(
          decoration: BoxDecoration(
            color: _isCurrentTab(tabItem) ? Palette.white : Colors.transparent
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tabIcons[tabItem],
                color: _isCurrentTab(tabItem) ? activeTabColor[tabItem] : Palette.gray
              ),
              Text(
                tabName[tabItem]!,
                style: GoogleFonts.roboto(
                  color: _isCurrentTab(tabItem) ? activeTabColor[tabItem] : Palette.gray
                )
              )
            ]
          )
        ),
      )
    );
  }

  bool _isCurrentTab(TabItem item) {
    return currentTab == item;
  }
}
