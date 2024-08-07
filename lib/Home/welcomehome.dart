import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Pagesuse/Home_pages.dart';
import 'package:flutter_appshop1/Pagesuse/Message_pages.dart';
import 'package:flutter_appshop1/Pagesuse/contact_pages.dart';
import 'package:flutter_appshop1/Pagesuse/list_pages.dart';
import 'package:flutter_appshop1/Pagesuse/profile_pages.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Welcomehome extends StatefulWidget {
  const Welcomehome({super.key});

  @override
  State<Welcomehome> createState() => _mainwelcomeState();
}

class _mainwelcomeState extends State<Welcomehome> {
  int currentIndex = 0;

  void goToPage(index) {
    setState(() {
      currentIndex = index;
    });
  }

  List pages = [
    Home_v(),
    UserOrdersScreen(),
    Contact_p(),
    Message_p(),
    Profile_v(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: GNav(
        tabBackgroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
        gap: 8,
        padding: EdgeInsets.all(17),
        onTabChange: (index) => goToPage(index),
        tabs: [
          GButton(
            icon: Icons.home,
            text: 'หน้าหลัก',
          ),
          GButton(
            icon: Icons.content_paste,
            text: 'รายการ',
          ),
          GButton(
            icon: Icons.call,
            text: 'ติดต่อ',
          ),
          GButton(
            icon: Icons.notifications,
            text: 'แจ้งเตือน',
          ),
          GButton(
            icon: Icons.person,
            text: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
