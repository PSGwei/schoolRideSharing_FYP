import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/screens/carpool_manage/carpool_manage.dart';
import 'package:school_ride_sharing/screens/carpool_list.dart';
import 'package:school_ride_sharing/screens/friend_list.dart';
import 'package:school_ride_sharing/screens/profile.dart';
import 'package:school_ride_sharing/screens/search_destination_page.dart';
import 'package:school_ride_sharing/widgets/request_offer_dialog.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int selectedPageIndex = 0;

  void selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  // Future openDialog() => showDialog(
  //       context: context,
  //       builder: (context) => Dialog(
  //         child: Stack(
  //           children: [
  //             const Padding(
  //               padding: EdgeInsets.all(20.0),
  //               child: RequestOrOfferDialog(),
  //             ),
  //             Positioned(
  //               right: 0,
  //               top: 0,
  //               child: IconButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 icon: const Icon(Icons.close),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );

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
        // IconButton(
        //     onPressed: () {
        //       Navigator.of(context).push(MaterialPageRoute(
        //           builder: (context) => const SearchDestinationPage()));
        //     },
        //     icon: const Icon(Icons.compare_arrows_sharp)),
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
      activeScreen = const FriendListScreen();
    } else if (selectedPageIndex == 3) {
      activeScreen = const ProfileScreen();
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
