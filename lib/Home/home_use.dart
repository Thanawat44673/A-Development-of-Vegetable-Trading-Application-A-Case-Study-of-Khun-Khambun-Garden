// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Home/register.dart';
import 'package:flutter_appshop1/Home/welcomehome.dart';
import 'package:flutter_appshop1/Home/welcomehomeadmin.dart';
import 'package:flutter_appshop1/Pagesuse/ResetPassword/Re_pw_pages.dart';
import 'package:flutter_appshop1/model/profilemember.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

class Home1 extends StatefulWidget {
  const Home1({super.key});

  @override
  State<Home1> createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); //ตัวชี้คำสั่ง
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

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

  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  bool _passwordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("ไม่ได้"),
              ),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              //ส่งค่ากลับไปยังหน้า Scaffold
              body: Form(
                // รูปร่างทั้งหมด
                key: formKey, // คำสั่งFormKey
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/number12.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      //องค์ประกอบ
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        const SizedBox(
                          height: 125,
                        ),
                        const SizedBox(
                          child: Text("เข้าสู่ระบบ",
                              style: TextStyle(
                                  fontSize: 45, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                              controller: emailcontroller,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  labelText: 'อีเมล'),
                              validator: MultiValidator([
                                RequiredValidator(
                                    errorText: "กรุณากรอก อีเมลผู้ใช้งาน"),
                                EmailValidator(
                                    errorText: "รูปแบบอีเมลไม่ถูกต้อง")
                              ]).call),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            controller: passwordcontroller,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: 'รหัสผ่าน'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก รหัสผ่าน';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: 250,
                          height: 50,
                          //คำสั่งในกล่องข้อความ
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.black87, width: 2),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            icon: const Icon(Icons.login),
                            label: const Text("เข้าสู่ระบบ",
                                style: TextStyle(fontSize: 20)),
                            onPressed: () async {
                              final String email = emailcontroller.text;
                              final String password = passwordcontroller.text;

                              if (formKey.currentState!.validate()) {
                                formKey.currentState!
                                    .save(); // Save the user's information
                                try {
                                  // Retrieve the admin login credentials from Firestore
                                  DocumentSnapshot adminSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection(
                                              'admin') // The 'admin' collection
                                          .doc('adminLogin') // The document ID
                                          .get();

                                  // Get the email and password from the document
                                  String adminEmail =
                                      adminSnapshot['adminEmail'];
                                  String adminPassword =
                                      adminSnapshot['adminPassword'];

                                  // Check if the input credentials match the admin credentials
                                  if (email == adminEmail &&
                                      password == adminPassword) {
                                    if (mounted) {
                                      // Ensure the widget is still mounted before pushing the new route
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Welcomehomeadmin(), // Replace with your admin home page
                                        ),
                                      );
                                    }
                                    Fluttertoast.showToast(
                                      msg: "เข้าสู่ระบบสำเร็จแล้ว",
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  } else {
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                            email: email, password: password);
                                    if (mounted) {
                                      // Ensure the widget is still mounted before pushing the new route
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Welcomehome(), // User home page
                                        ),
                                      );
                                    }
                                    Fluttertoast.showToast(
                                      msg: "เข้าสู่ระบบสำเร็จแล้ว",
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (kDebugMode) {
                                    print(e.code);
                                  }
                                  String? message;
                                  if (e.code == 'ไม่พบสมาชิกผู้ใช้งาน') {
                                    message =
                                        "ไม่พบสมาชิกผู้ใช้งาน กรุณาลองอีกครั้ง";
                                  } else {
                                    message = e.message;
                                  }
                                  Fluttertoast.showToast(
                                    msg: message!,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                }
                                emailcontroller.text = '';
                                passwordcontroller.text = '';
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextButton(
                          child: const Text('สมัครสมาชิก',
                              style: TextStyle(fontSize: 18)),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const Register();
                            }));
                          },
                        ),
                        TextButton(
                          child: const Text('รีเซ็ตรหัสผ่าน',
                              style: TextStyle(fontSize: 18)),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const ForgotPasswordPage();
                            }));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
