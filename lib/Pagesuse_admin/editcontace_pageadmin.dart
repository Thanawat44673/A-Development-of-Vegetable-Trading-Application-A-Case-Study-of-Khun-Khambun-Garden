import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/auth/text_box.dart';
import 'package:flutter_appshop1/model/profilemember.dart';

class Editcontace_admin extends StatefulWidget {
  const Editcontace_admin({super.key});

  @override
  State<Editcontace_admin> createState() => _Editcontace_adminState();
}

class _Editcontace_adminState extends State<Editcontace_admin> {
  //final currentUser = FirebaseAuth.instance.currentUser!;
  //เข้าถึงข้อมูลผู้ใช้งานเพื้อทำการแก้ไข
  final usersCollection = FirebaseFirestore.instance.collection("Contace");

  String imageUrl = '';

  // ระบบล็อคเอ้า

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("แก้ไข" + field),
        content: TextField(
          autocorrect: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "กรอก $fieldใหม่",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: Text(
              'บันทึก',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
    //คำสั่งอัพโหลดข้อมูลการแก้ไข
    if (newValue.trim().length > 0) {
      await usersCollection
          .doc("vsxLKKo7SlAlSeKhdpRP")
          .update({field: newValue});
    }
  }

  Profile profile = Profile(
      //กดหนดเก็บค่า
      Name: '',
      Lastname: '',
      Email: '',
      Password: '',
      Trypassword: '',
      Number: '',
      Address: '',
      Image: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Contace")
            .doc("vsxLKKo7SlAlSeKhdpRP")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Container(
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/backgroud2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(35),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black, // เปลี่ยนสีของเส้นกรอบเป็นสีแดง
                          width: 2.0, // กำหนดความหนาของเส้นกรอบ
                        ),
                        color: Colors.white,
                      ),
                      child: const Text(
                        'ข้อมูลช่องทางการติดต่อ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  MyTextBox(
                    text: userData['เฟสบุ๊ค'],
                    sectionName: 'เฟสบุ๊ค',
                    onPressed: () => editField('เฟสบุ๊ค'),
                  ),
                  MyTextBox(
                    text: userData['อีเมล'],
                    sectionName: 'อีเมล',
                    onPressed: () => editField('อีเมล'),
                  ),
                  MyTextBox(
                    text: userData['เบอร์โทรศัพท์'],
                    sectionName: 'เบอร์โทรศัพท์',
                    onPressed: () => editField('เบอร์โทรศัพท์'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
