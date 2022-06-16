import 'package:ZeeU/pages/chat_page.dart';
import 'package:ZeeU/pages/home_page.dart';
import 'package:ZeeU/pages/search_page.dart';
import 'package:ZeeU/pages/settings_page.dart';
import 'package:ZeeU/widgets/bottom_navigation.dart';
import 'package:ZeeU/utils/tab_item.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  final GlobalKey<NavigatorState> appNavigatorKey;
  const App({Key? key, required this.appNavigatorKey}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  final Map<TabItem,GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.home: GlobalKey(),
    TabItem.chats: GlobalKey(),
    TabItem.search: GlobalKey(),
    TabItem.settings: GlobalKey()
  };
  TabItem _currentTab = TabItem.home;

  final routeBuilders = {
              TabRoutes.home: (context) => const HomePage(),
              TabRoutes.chats: (context) => const ChatPage(),
              TabRoutes.search: (context) => const SearchPage(),
              TabRoutes.settings: (context) => const SettingsPage()
            };

  void _selectTab(TabItem tabItem) {
    setState(() => _currentTab = tabItem);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(tabBackgroundImg[_currentTab]!),
              fit: BoxFit.cover
            )
          ),
          child: Stack(
            children: [
              _buildOffstageNavigator(TabItem.home),
              _buildOffstageNavigator(TabItem.chats),
              _buildOffstageNavigator(TabItem.search),
              _buildOffstageNavigator(TabItem.settings)
            ]
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          currentTab: _currentTab,
          onSelectTab: _selectTab,
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    return Offstage(
      offstage: _currentTab != tabItem,
      child: Navigator(
        key: _navigatorKeys[tabItem],
        initialRoute: tabRoutes[tabItem],
        onGenerateRoute: (routeSettings) {
          if (routeSettings.name == '/logout') {
            widget.appNavigatorKey.currentState?.pushReplacementNamed('/login');
            return MaterialPageRoute(builder: (_) => const SizedBox());
          }
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name]!(context),
          );
        },
      ),
    );
  }
}
