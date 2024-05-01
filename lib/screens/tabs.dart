import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:school_ride_sharing/screens/carpool_manage/carpool_manage.dart';
import 'package:school_ride_sharing/screens/carpool_list.dart';
import 'package:school_ride_sharing/screens/completed_carpool.dart';
import 'package:school_ride_sharing/screens/profile.dart';
import 'package:school_ride_sharing/screens/search_destination_page.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int selectedPageIndex = 0;

  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    print("fcm token $token");
  }

  @override
  void initState() {
    super.initState();
    setupPushNotification();
  }

  void selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // default home screen
    Widget activeScreen = const HomeScreen(
      isMyCarpoolPage: false,
    );
    String activeTitle = 'Home';

    AppBar carpoolRequestAppbar = AppBar(
      title: Text(activeTitle),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: [
        IconButton(
            onPressed: () {
              // openDialog();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchDestinationPage(),
                ),
              );
            },
            icon: const Icon(Icons.add)),
      ],
    );

    if (selectedPageIndex == 1) {
      activeScreen = const CarpoolManageScreen();
      setState(() {
        activeTitle = 'Manage';
      });
    } else if (selectedPageIndex == 2) {
      activeScreen = const CompletedCarpool();
      setState(() {
        activeTitle = 'Completed Carpool';
      });
    } else if (selectedPageIndex == 3) {
      activeScreen = const ProfileScreen();
      setState(() {
        activeTitle = 'Profile';
      });
    }

    return Scaffold(
      appBar: selectedPageIndex == 0
          ? carpoolRequestAppbar
          : AppBar(
              title: Text(activeTitle),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
      body: activeScreen,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        onTap: selectPage,
        currentIndex: selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.car), label: 'Carpool'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled), label: 'Profile'),
        ],
      ),
    );
  }
}
