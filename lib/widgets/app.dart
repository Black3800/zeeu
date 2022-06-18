import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/pages/chat_page.dart';
import 'package:ZeeU/pages/home_page.dart';
import 'package:ZeeU/pages/message_page.dart';
import 'package:ZeeU/pages/search_page.dart';
import 'package:ZeeU/pages/settings_page.dart';
import 'package:ZeeU/widgets/bottom_navigation.dart';
import 'package:ZeeU/utils/tab_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

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
  final tabStacks = {
    TabItem.home: [TabRoutes.home],
    TabItem.chats: [TabRoutes.chats],
    TabItem.search: [TabRoutes.search],
    TabItem.settings: [TabRoutes.settings]
  };
  TabItem _currentTab = TabItem.home;
  String _currentImg = tabBackgroundImg[TabRoutes.home]!;
  late Map routeBuilders;

  void _selectTab(TabItem tabItem) {
    setState(() => _currentTab = tabItem);
    _matchBackgroundWithRoute();
  }

  void _matchBackgroundWithRoute() {
    _changeBackground(tabBackgroundImg[tabStacks[_currentTab]!.join()]!);
  }

  void _changeBackground(String imgPath) {
    setState(() => _currentImg = imgPath);
  }

  void _handleRouteChange(String action, String routeName) {
    if (action == 'push') {
      tabStacks[_currentTab]!.add(routeName);
    } else if (action == 'pop') {
      tabStacks[_currentTab]!.removeLast();
    }
    print(tabStacks[_currentTab]!.join());
    _matchBackgroundWithRoute();
  }

  Future<void> _fetchCurrentUser() async {
    final credential = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('${credential?.uid}').get();
    final user = AppUser.fromJson(doc.data() ?? {});
    user.uid = credential?.uid;
    user.email = credential?.email;
    Provider.of<UserState>(context, listen: false).updateUser(user);
  }

  @override
  void initState() {
    if (Provider.of<UserState>(context, listen: false).uid == null) {
      _fetchCurrentUser();
    }
    routeBuilders = {
      TabRoutes.home: (_) => HomePage(changeTab: _selectTab),
      TabRoutes.chats: (_) => ChatPage(notifyRouteChange: _handleRouteChange),
      TabRoutes.search: (_) => const SearchPage(),
      TabRoutes.settings: (_) => const SettingsPage(),
      TabRoutes.messages: (chat) => MessagePage(chat: chat, notifyRouteChange: _handleRouteChange)
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_currentImg),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter
            )
          ),
          child: Stack(children: [
            _buildOffstageNavigator(TabItem.home),
            _buildOffstageNavigator(TabItem.chats),
            _buildOffstageNavigator(TabItem.search),
            _buildOffstageNavigator(TabItem.settings)
          ]),
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
          final routeName = routeSettings.name!;
          if (routeName == '/logout') {
            widget.appNavigatorKey.currentState?.pushReplacementNamed('/login');
            return MaterialPageRoute(builder: (_) => const SizedBox());
          } else if (routeName == '/messages') {
            return MaterialPageRoute(builder: (_) => routeBuilders['/messages'](routeSettings.arguments));
          }
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeName]!(context),
          );
        },
      ),
    );
  }
}
