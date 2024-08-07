import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Home/welcomehomeadmin.dart';

// ตัวนี้เป็นคำสั่งช่วยล็อคอินของเจ้าของสวนไม่ให้อีเมลที่สมัครของลูกค้าเข้าได้
class AuthService {
  final auth = FirebaseAuth.instance;
  TextEditingController adminEmail = TextEditingController();
  TextEditingController adminPassword = TextEditingController();
  TextEditingController name = TextEditingController();
  final firestore = FirebaseFirestore.instance;

  void adminLogin(context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
    await FirebaseFirestore.instance
        .collection("admin")
        .doc("adminLogin")
        .snapshots()
        .forEach((element) {
      if (element.data()?['adminEmail'] == adminEmail.text &&
          element.data()?['adminPassword'] == adminPassword.text) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Welcomehomeadmin()),
            (route) => false);
      }
    }).catchError((e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(e.toString()),
            );
          });
    });
  }
}
