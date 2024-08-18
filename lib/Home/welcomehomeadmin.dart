import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Home/myhomepage.dart';
import 'package:flutter_appshop1/Pagesuse_admin/edit_pagesadmin.dart';
import 'package:flutter_appshop1/Pagesuse_admin/editcontace_pageadmin.dart';
import 'package:flutter_appshop1/Pagesuse_admin/editmessage_pageadmin.dart';
import 'package:flutter_appshop1/Pagesuse_admin/oder_admin.dart';
import 'package:flutter_appshop1/Pagesuse_admin/profile_pagesadmin.dart';
import 'package:flutter_appshop1/Pagesuse_admin/statistics_admin.dart';

class Welcomehomeadmin extends StatefulWidget {
  const Welcomehomeadmin({super.key});

  @override
  State<Welcomehomeadmin> createState() => _welcomehomeadminState();
}

class _welcomehomeadminState extends State<Welcomehomeadmin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Myhomepage_m()),
    );
  }

  int visit = 0;
  List<TabItem> items = [
    TabItem(
      icon: Icons.circle_notifications,
      title: 'โปรโมชัน',
    ),
    TabItem(
      icon: Icons.call,
      title: 'ติดต่อ',
    ),
    TabItem(
      icon: Icons.spa_outlined,
      title: 'ข้อมูลผัก',
    ),
    TabItem(
      icon: Icons.assessment_outlined,
      title: 'สถิติรายได้',
    ),
    TabItem(
      icon: Icons.people,
      title: 'ข้อมูลสมาชิก',
    ),
    TabItem(
      icon: Icons.local_grocery_store_outlined,
      title: 'ออเดอร์',
    ),
  ];

  List<Widget> pages = [
    Editmessage_admin(),
    Editcontace_admin(),
    Editvegetable_admin(),
    StatisticsAdmin(),
    Profile_a(),
    OrderManagementScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
        title: Text("สวนคุณคำบุญ"),
        actions: [
          IconButton(
              onPressed: () async {
                //await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                await _signOut(context);
              },
              icon: Icon(Icons.power_settings_new))
        ],
      ),
      body: pages[visit],
      bottomNavigationBar: BottomBarInspiredOutside(
        items: items,
        color: Colors.black,
        backgroundColor: const Color.fromARGB(255, 184, 255, 187),
        colorSelected: Colors.white,
        itemStyle: ItemStyle.circle,
        borderRadius: BorderRadius.circular(0),
        elevation: 6,
        chipStyle: ChipStyle(
          background: const Color.fromARGB(255, 170, 251, 173),
          notchSmoothness: NotchSmoothness.verySmoothEdge,
        ),
        indexSelected: visit,
        onTap: (index) => setState(() {
          visit = index;
        }),
      ),
    );
  }
}
