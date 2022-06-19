import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart' show MaterialColor, Icons;

enum TabItem { home, chats, search, settings }

class TabRoutes {
  static const String home = '/';
  static const String chats = '/chats';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String messages = '/messages';
  static const String doctors = '/doctors';
  static const String profile = '/profile';
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
  TabRoutes.home                  : 'assets/Light-bg.png',
  TabRoutes.chats                 : 'assets/Light-bg.png',
  '${TabRoutes.chats}/messages'   : 'assets/Light-bg.png',
  TabRoutes.search                : 'assets/Light-bg.png',
  '${TabRoutes.search}/doctors'   : 'assets/Light-bg.png',
  TabRoutes.settings              : 'assets/Light-bg.png',
  '${TabRoutes.settings}/profile' : 'assets/Light-bg.png'
};

const Map<TabItem, MaterialColor> activeTabColor = {
  TabItem.home: Palette.aquamarine,
  TabItem.chats: Palette.ultramarine,
  TabItem.search: Palette.violet,
  TabItem.settings: Palette.gold
};
