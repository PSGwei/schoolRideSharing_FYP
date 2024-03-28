import 'package:flutter/material.dart';
import 'package:school_ride_sharing/screens/carpool_manage/my_request.dart';
import 'package:school_ride_sharing/screens/homescreen.dart';

class CarpoolManageScreen extends StatefulWidget {
  const CarpoolManageScreen({super.key});

  @override
  State<CarpoolManageScreen> createState() => _CarpoolManageScreenState();
}

class _CarpoolManageScreenState extends State<CarpoolManageScreen> {
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  text: 'My carpool',
                ),
                Tab(
                  text: 'Request',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  HomeScreen(isMyCarpoolPage: true),
                  MyRequest(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
