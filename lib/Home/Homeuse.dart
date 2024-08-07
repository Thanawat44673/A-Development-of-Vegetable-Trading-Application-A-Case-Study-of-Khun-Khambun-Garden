import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Home/myhomepage.dart';
import 'package:flutter_appshop1/Home/register.dart';
import 'package:flutter_appshop1/Home/welcomehome.dart';
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    //await googleSignIn.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home1()),
    );
  }

  /*Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Welcomehome()),
        );
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }*/

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

  final TextEditingController _Email = TextEditingController();
  final TextEditingController _Password = TextEditingController();

  String _password = '';
  bool _passwordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext) {
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
              resizeToAvoidBottomInset: false,
              //ส่งค่ากลับไปยังหน้า Scaffold
              body: Form(
                // รูปร่างทั้งหมด
                key: formKey, // คำสั่งFormKey
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/number1.jpg'),
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
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 350, 0),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Myhomepage_m()),
                              );
                            },
                          ),
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
                              controller: _Email,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  labelText: 'อีเมลผู้ใช้งาน'),
                              validator: MultiValidator([
                                RequiredValidator(
                                    errorText: "กรุณากรอก อีเมลผู้ใช้งาน"),
                                EmailValidator(
                                    errorText: "รูปแบบอีเมลไม่ถูกต้อง")
                              ])),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            controller: _Password,
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
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
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
                              side: BorderSide(color: Colors.black87, width: 2),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            icon: Icon(Icons.login),
                            label: Text("เข้าสู่ระบบ",
                                style: TextStyle(fontSize: 20)),
                            onPressed: () async {
                              //คำสั่งสามารถกดได้
                              final String email = _Email.text;
                              final String password = _Password.text;
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!
                                    .save(); // เซฟข้อมูลผู้ใช้งาน
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .signInWithEmailAndPassword(
                                              email: email, password: password);
                                  formKey.currentState!.reset();
                                  Fluttertoast.showToast(
                                      msg: "เข้าสู่ระบบแล้ว",
                                      gravity: ToastGravity.BOTTOM);
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => Welcomehome(),
                                    ),
                                  ); //เข้าสู่หน้าหลักแอพ
                                } on FirebaseAuthException catch (e) {
                                  print(e.code);
                                  String? message;
                                  if (e.code == 'invalid-credential') {
                                    message =
                                        "ไม่พบสมาชิกผู้ใช้งาน กรุณาลองอีกครั้ง";
                                  } else {
                                    message = e.message;
                                  }
                                  Fluttertoast.showToast(
                                      msg: message!,
                                      gravity: ToastGravity.BOTTOM);
                                  //คำสั่งแสดงข้อความเวลาเขียนผิดรูปแบบ
                                }
                                _Email.text = '';
                                _Password.text = '';
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
                        SizedBox(
                          height: 5,
                        ),
                        TextButton(
                          child: Text('สมัครสมาชิก',
                              style: TextStyle(fontSize: 18)),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const Register();
                            }));
                          },
                        ),
                        TextButton(
                          child: Text('รีเซ็ตรหัสผ่าน',
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
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
