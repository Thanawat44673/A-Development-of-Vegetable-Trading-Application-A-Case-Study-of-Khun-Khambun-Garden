import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Home/myhomepage.dart';
import 'package:flutter_appshop1/Pagesuse/ResetPassword/Re_pw_pages.dart';
import 'package:flutter_appshop1/auth/Helper.dart';
import 'package:form_field_validator/form_field_validator.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _adminlogin();
}

class _adminlogin extends State<Home2> {
  AuthService authService = AuthService();

  String _password = '';
  bool _passwordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/number1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
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
                    MaterialPageRoute(builder: (context) => Myhomepage_m()),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 125,
            ),
            Text(
              "เข้าสู่ระบบ",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 45,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 350,
              child: TextFormField(
                  controller: authService.adminEmail,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: 'อีเมลเจ้าของสวน'),
                  validator: MultiValidator([
                    RequiredValidator(errorText: "กรุณากรอก อีเมลเจ้าของสวน"),
                    EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง")
                  ])),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 350,
              child: TextFormField(
                obscureText: !_passwordVisible,
                controller: authService.adminPassword,
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
                    labelText: 'รหัสผ่านเจ้าของสวน'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอก รหัสผ่าน';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black87, width: 2),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  if (authService.adminEmail != "" &&
                      authService.adminPassword != "") {
                    authService.adminLogin(context);
                  }
                },
                child: Text("เข้าสู่ระบบ"),
              ),
            ),
            TextButton(
              child: Text('รีเซ็ตรหัสผ่าน', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ForgotPasswordPage();
                }));
              },
            ),
          ],
        ),
      ),
    );
  }
}
