import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appshop1/Home/Map_Screen.dart';
import 'package:flutter_appshop1/Home/myhomepage.dart';
import 'package:flutter_appshop1/Pagesuse/Profile_edit/Profile_edit_map.dart';
import 'package:flutter_appshop1/auth/text_box.dart';
import 'package:flutter_appshop1/model/profilemember.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class Profile_v extends StatefulWidget {
  const Profile_v({super.key});

  @override
  State<Profile_v> createState() => _Profile_vState();
}

class _Profile_vState extends State<Profile_v> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //เข้าถึงข้อมูลผู้ใช้งานเพื้อทำการแก้ไข
  final usersCollection = FirebaseFirestore.instance.collection("members");

  // ระบบล็อคเอ้า
  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Myhomepage_m()),
    );
  }

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
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  Future<void> editField1(String field) async {
    String newValue = "";
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile_edit_map(),
      ),
    );
    if (result != null) {
      setState(() {
        newValue = result;
      });
    }
    //คำสั่งอัพโหลดข้อมูลการแก้ไข
    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
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

  Future<void> _delete() async {
    await FirebaseAuth.instance.currentUser!.delete();
    await _signOut(context);
    FirebaseFirestore.instance
        .collection("members")
        .doc(currentUser.email)
        .delete();
  }

  // แบบเลือกในแกลลอรี่

  // แบบถ่ายเอง

  //อัพโหลดภาพโปรไฟล์
  String imageUrl = '';
  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final file = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        String fileName =
                            DateTime.now().microsecondsSinceEpoch.toString();
                        Reference ref = FirebaseStorage.instance.ref();
                        Reference referenceDireImages = ref.child('images');

                        Reference referenceImageaToUpload =
                            referenceDireImages.child(fileName);

                        try {
                          await referenceImageaToUpload
                              .putFile(File(file!.path));

                          imageUrl =
                              await referenceImageaToUpload.getDownloadURL();
                          await usersCollection.doc(currentUser.email).update({
                            'รูป': imageUrl,
                          });
                          Fluttertoast.showToast(
                              msg: "อัพโหลดรูปโปรไฟล์เรียบร้อยแล้ว",
                              gravity: ToastGravity.BOTTOM);
                        } catch (error) {}
                      },
                      child: SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                            ),
                            Text("แกลลอรี่"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final file = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        String fileName =
                            DateTime.now().microsecondsSinceEpoch.toString();
                        Reference ref = FirebaseStorage.instance.ref();
                        Reference referenceDireImages = ref.child('images');

                        Reference referenceImageaToUpload =
                            referenceDireImages.child(fileName);

                        try {
                          await referenceImageaToUpload
                              .putFile(File(file!.path));

                          imageUrl =
                              await referenceImageaToUpload.getDownloadURL();
                          await usersCollection.doc(currentUser.email).update({
                            'รูป': imageUrl,
                          });
                          Fluttertoast.showToast(
                              msg: "อัพโหลดรูปโปรไฟล์เรียบร้อยแล้ว",
                              gravity: ToastGravity.BOTTOM);
                        } catch (error) {}
                      },
                      child: SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera,
                              size: 70,
                            ),
                            Text("กล้อง"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("members")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Container(
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/number1.jpg'), // Replace this with your image asset
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView(
                children: [
                  Stack(children: [
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(userData['รูป']),
                      ),
                    ),
                    Positioned(
                      child: IconButton(
                        onPressed: () {
                          showImagePickerOption(context);
                        },
                        icon: const Icon(Icons.add_a_photo),
                      ),
                      bottom: -10,
                      left: 235,
                    )
                  ]),
                  const SizedBox(height: 10),
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
                        'ข้อมูลส่วนตัว',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  MyTextBox(
                    text: userData['ชื่อ'],
                    sectionName: 'ชื่อ',
                    onPressed: () => editField('ชื่อ'),
                  ),
                  MyTextBox(
                    text: userData['นามสกุล'],
                    sectionName: 'นามสกุล',
                    onPressed: () => editField('นามสกุล'),
                  ),
                  MyTextBox(
                    text: currentUser.email!,
                    sectionName: 'อีเมล',
                    onPressed: () => editField('อีเมล'),
                  ),
                  MyTextBox(
                    text: userData['รหัสผ่าน'],
                    sectionName: 'รหัสผ่าน',
                    onPressed: () => editField('รหัสผ่าน'),
                  ),
                  MyTextBox(
                    text: userData['เบอร์โทรศัพท์'],
                    sectionName: 'เบอร์โทรศัพท์',
                    onPressed: () => editField('เบอร์โทรศัพท์'),
                  ),
                  MyTextBox1(
                    text: userData['ที่อยู๋'],
                    sectionName: 'ที่อยู่',
                    onPressed: () => editField1('ที่อยู๋'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    //คำสั่งในกล่องข้อความ
                    child: Padding(
                      padding: EdgeInsets.only(left: 50, right: 50),
                      child: ElevatedButton(
                        child: Text("ออกจากระบบ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.black87, width: 2),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('ยืนยันการออกจากระบบ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                content:
                                    Text('คุณต้องการที่จะออกจากระบบหรือไม่?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      // ปิดกล่องโต้ตอบ
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('ยกเลิก',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      //await GoogleSignIn().signOut();
                                      await _signOut(context);
                                    },
                                    child: Text('ยืนยัน',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  /*Padding(
                    padding: EdgeInsets.only(left: 200),
                    child: TextButton(
                      child: Text(
                        'ลบบัญชี',
                        selectionColor: Colors.red,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('ยืนยันการลบบัญชี',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                              content: Text('คุณต้องการที่จะลบบัญชีหรือไม่?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    // ปิดกล่องโต้ตอบ
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('ยกเลิก',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    _delete();
                                  },
                                  child: Text('ยืนยัน',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),*/
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
