import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart' show MaterialColor;

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

const Map<TabItem, MaterialColor> activeTabColor = {
  TabItem.home: Palette.aquamarine,
  TabItem.chats: Palette.ultramarine,
  TabItem.search: Palette.violet,
  TabItem.settings: Palette.gold
};
