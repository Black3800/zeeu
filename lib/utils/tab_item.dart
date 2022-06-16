import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart' show MaterialColor, Icons;

enum TabItem { home, chats, search, settings }

class TabRoutes {
  static const String home = '/';
  static const String chats = '/chats';
  static const String search = '/search';
  static const String settings = '/settings';
}

const Map<TabItem, String> tabName = {
  TabItem.home: 'Home',
  TabItem.chats: 'Chats',
  TabItem.search: 'Search',
  TabItem.settings: 'Settings'
};

const tabRoutes = {
  TabItem.home: TabRoutes.home,
  TabItem.chats: TabRoutes.chats,
  TabItem.search: TabRoutes.search,
  TabItem.settings: TabRoutes.settings
};

const tabIcons = {
  TabItem.home: Icons.home_outlined,
  TabItem.chats: Icons.chat_bubble_outline,
  TabItem.search: Icons.search_outlined,
  TabItem.settings: Icons.settings_outlined
};

const tabBackgroundImg = {
  TabItem.home: 'assets/Light-bg.png',
  TabItem.chats: 'assets/Light-bg.png',
  TabItem.search: 'assets/Light-bg.png',
  TabItem.settings: 'assets/Light-bg.png'
};

const Map<TabItem, MaterialColor> activeTabColor = {
  TabItem.home: Palette.aquamarine,
  TabItem.chats: Palette.ultramarine,
  TabItem.search: Palette.violet,
  TabItem.settings: Palette.gold
};
