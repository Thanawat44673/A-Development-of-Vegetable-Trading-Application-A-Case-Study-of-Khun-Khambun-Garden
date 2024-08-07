import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _Email = TextEditingController();

  @override
  void dispose() {
    _Email.dispose();
    super.dispose();
  }

  Future passwordRest() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _Email.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text('ระบบได้ทำการส่งข้อมูลการรีเซ็ตรหัสผ่านของคุณแล้ว',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //ชื่อมุมขวาบน
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/number1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text('กรุณากรอกอีเมลของคุณ เพื่อทำการรีเซ็ตรหัสผ่านของคุณ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    RequiredValidator(errorText: "กรุณากรอก อีเมลผู้ใช้งาน"),
                    EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง")
                  ])),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 350,
              height: 50,
              //คำสั่งในกล่องข้อความ
              child: ElevatedButton(
                child: Text("รีเซ็ตรหัสผ่าน", style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black87, width: 2),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                onPressed: passwordRest,
              ),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
