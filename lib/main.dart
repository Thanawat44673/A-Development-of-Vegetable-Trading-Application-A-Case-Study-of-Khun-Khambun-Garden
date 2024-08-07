import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_appshop1/Home/myhomepage.dart';
import 'package:flutter_appshop1/Home/welcomehome.dart';
import 'package:flutter_appshop1/auth/firebase_api.dart';
import 'package:flutter_appshop1/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('th', 'TH'), // กำหนด locale เป็นภาษาไทย
      ],
      debugShowCheckedModeBanner: false, //ลบ การแสดง debug ออกหน้าจอ
      title: 'Myproject', //ชื่อเว็บ
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return Myhomepage_m();
            } else {
              return Welcomehome();
            }
          }
          return Center(child: CircularProgressIndicator());
        }, //หน้าแรกของการเข้าแอพ
      ),
    );
  }
}
