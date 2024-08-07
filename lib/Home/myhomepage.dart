import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Home/%E0%B9%89Homemain.dart';
import 'package:flutter_appshop1/Home/Homeuse.dart';

class Myhomepage_m extends StatefulWidget {
  const Myhomepage_m({super.key});

  @override
  State<Myhomepage_m> createState() => _Myhomepage_mState();
}

class _Myhomepage_mState extends State<Myhomepage_m> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); //ตัวชี้คำสั่ง
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text("ไม่ได้"),
              ),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              body: Container(
                key: formKey,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/number1.jpg'), // Replace this with your image asset
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                    ),
                    SizedBox(
                      child:
                          Text("ยินต้อนรับสู่", style: TextStyle(fontSize: 40)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      child:
                          Text("สวนคุณคำบุญ", style: TextStyle(fontSize: 18)),
                    ),
                    SizedBox(
                      height: 150,
                    ),
                    SizedBox(
                      width: 350,
                      height: 50,
                      //คำสั่งในกล่องข้อความ
                      child: ElevatedButton(
                        child:
                            Text("เจ้าของสวน", style: TextStyle(fontSize: 20)),
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.black87, width: 2),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return Home2();
                          }));
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 350,
                      height: 50,
                      //คำสั่งในกล่องข้อความ
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.black87, width: 2),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child:
                            Text("ผู้ใช้งาน", style: TextStyle(fontSize: 20)),
                        onPressed: () async {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return Home1();
                          }));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
