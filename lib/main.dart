import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_appshop1/Home/home_use.dart';
import 'package:flutter_appshop1/Home/welcomehome.dart';
import 'package:flutter_appshop1/Home/welcomehomeadmin.dart';
import 'package:flutter_appshop1/auth/firebase_api.dart';
import 'package:flutter_appshop1/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseApi().initNotifications();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else {
          return MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('th', 'TH'),
              const Locale('en', 'US'),
            ],
            debugShowCheckedModeBanner: false,
            title: 'Myproject',
            theme: ThemeData(
              primarySwatch: Colors.green,
              fontFamily: 'Sarabun',
            ),
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error.toString()}'));
                }

                if (snapshot.connectionState == ConnectionState.active) {
                  User? user = snapshot.data;
                  if (user == null) {
                    return Home1();
                  } else {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('admin')
                          .doc('adminLogin')
                          .get(),
                      builder: (context, adminSnapshot) {
                        if (adminSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (adminSnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${adminSnapshot.error}'));
                        }

                        if (!adminSnapshot.hasData ||
                            adminSnapshot.data?.data() == null) {
                          return Center(child: Text('Admin data not found'));
                        }

                        var adminData =
                            adminSnapshot.data?.data() as Map<String, dynamic>?;

                        if (adminData == null) {
                          return Center(child: Text('Admin data is null'));
                        }

                        print('User email: ${user.email}');
                        print('Admin email: ${adminData['adminEmail']}');

                        if (user.email == adminData['adminEmail']) {
                          return Welcomehomeadmin(); // Redirect to Admin Home
                        }

                        return Welcomehome(); // Regular user home screen
                      },
                    );
                  }
                }

                return Center(child: CircularProgressIndicator());
              },
            ),
          );
        }
      },
    );
  }
}
