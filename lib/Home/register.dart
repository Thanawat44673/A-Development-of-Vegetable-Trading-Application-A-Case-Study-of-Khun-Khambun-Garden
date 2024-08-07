import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Home/Homeuse.dart';
import 'package:flutter_appshop1/Home/Map_Screen.dart';
import 'package:flutter_appshop1/model/profilemember.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  String _address = "";
  final TextEditingController _Name = TextEditingController();
  final TextEditingController _Lastname = TextEditingController();
  final TextEditingController _Email = TextEditingController();
  final TextEditingController _Password = TextEditingController();
  final TextEditingController _Number = TextEditingController();
  final TextEditingController _Address = TextEditingController();
  final TextEditingController _Image = TextEditingController();

  void signUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  Profile profile = Profile(
      Name: '',
      Lastname: '',
      Email: '',
      Password: '',
      Trypassword: '',
      Number: '',
      Address: '',
      Image: '');

  String _password = '';
  String _password2 = '';
  bool _passwordVisible = false;
  bool _isPasswordValid = true;
  bool _passwordVisible2 = false;
  bool _isPasswordValid2 = true;

  @override
  void initState() {
    super.initState();
    _validatePassword('');
    _validatePassword2('');
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _password = value;
      _isPasswordValid = value.length >= 6;
    });
  }

  void _togglePasswordVisibility2() {
    setState(() {
      _passwordVisible2 = !_passwordVisible2;
    });
  }

  void _validatePassword2(String value) {
    setState(() {
      _password2 = value;
      _isPasswordValid2 = value.length >= 6;
    });
  }

  bool isValidPhoneNumber(String input) {
    final RegExp phoneRegex = RegExp(r'^0\d{9,10}$');
    return phoneRegex.hasMatch(input);
  }

  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 216, 255, 171),
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
              appBar: AppBar(
                title: Text('สมาชิกใหม่'),
                backgroundColor: const Color.fromARGB(255, 216, 255, 171),
              ),
              body: Form(
                key: formKey,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/number1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: ListView(
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: TextFormField(
                            controller: _Name,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: 'ชื่อ'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก ชื่อ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: TextFormField(
                            controller: _Lastname,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: 'นามสกุล'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก นามสกุล';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
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
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: TextFormField(
                            controller: _Password,
                            onChanged: _validatePassword,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: 'รหัสผ่าน',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                              errorText: _isPasswordValid
                                  ? null
                                  : 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก รหัสผ่าน';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: TextFormField(
                            onSaved: (String? TryPassword) {
                              profile.Trypassword = TryPassword!;
                            },
                            onChanged: _validatePassword2,
                            obscureText: !_passwordVisible2,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: 'กรอกรหัสผ่านอีกครั้ง',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible2
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: _togglePasswordVisibility2,
                              ),
                              errorText: _isPasswordValid2
                                  ? null
                                  : 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก รหัสผ่านอีกครั้ง';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: TextFormField(
                            controller: _Number,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: 'เบอร์โทรศัพท์',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก หมายเลขโทรศัพท์';
                              }
                              if (!isValidPhoneNumber(value)) {
                                return 'กรุณากรอกหมายเลขโทรศัพท์ที่ถูกต้อง';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: TextFormField(
                            controller: _Address,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: 'ที่อยู่',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก ที่อยู่';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(color: Colors.black87, width: 2),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapScreen()),
                              );
                              if (result != null) {
                                setState(() {
                                  //_address = result;
                                  _selectedLocation = result;
                                  _mapController?.animateCamera(
                                      CameraUpdate.newLatLng(
                                          _selectedLocation!));
                                });
                              }
                            },
                            child: Text('เลือกพิกัดของท่าน',
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black87,
                                width: 2,
                              ),
                            ),
                            child: GoogleMap(
                              onMapCreated: (controller) {
                                _mapController = controller;
                                if (_selectedLocation != null) {
                                  _mapController!.moveCamera(
                                    CameraUpdate.newLatLng(_selectedLocation!),
                                  );
                                }
                              },
                              initialCameraPosition: _selectedLocation != null
                                  ? CameraPosition(
                                      target: _selectedLocation!,
                                      zoom: 17,
                                    )
                                  : CameraPosition(
                                      target: LatLng(0,
                                          0), // Initial position (center of the world)
                                      zoom: 17,
                                    ),
                              markers: _selectedLocation != null
                                  ? {
                                      Marker(
                                        markerId: MarkerId(
                                            _selectedLocation.toString()),
                                        position: _selectedLocation!,
                                        infoWindow: InfoWindow(
                                          title: 'Selected Location',
                                        ),
                                      ),
                                    }
                                  : {},
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(color: Colors.black87, width: 2),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                if (_Password.text != profile.Trypassword) {
                                  displayMessage("รหัสผ่านไม่ตรงกัน");
                                  return;
                                }
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                              email: _Email.text,
                                              password: _Password.text);

                                  FirebaseFirestore.instance
                                      .collection("members")
                                      .doc(userCredential.user!.email)
                                      .set({
                                    'ชื่อ': _Name.text,
                                    'นามสกุล': _Lastname.text,
                                    'อีเมล': _Email.text,
                                    'รหัสผ่าน': _Password.text,
                                    'เบอร์โทรศัพท์': _Number.text,
                                    'พิกัด': _selectedLocation != null
                                        ? "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}"
                                        : "",
                                    'ที่อยู๋': _Address.text,
                                    'รูป': _Image.text,
                                  });

                                  formKey.currentState!.reset();
                                  Fluttertoast.showToast(
                                      msg: "สมัครสมาชิกเรียบร้อยแล้ว",
                                      gravity: ToastGravity.BOTTOM);
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return Home1();
                                  }));
                                } on FirebaseAuthException catch (e) {
                                  String? message;
                                  if (e.code == 'email-already-in-use') {
                                    message =
                                        "มีอีเมลนี้ในระบบแล้ว กรุณากรอกอีเมลอื่น";
                                  } else if (e.code == 'weak-password') {
                                    message =
                                        "กรุณากรอกรหัสผ่านให้ถึง 6 ตัวด้วยครับ";
                                  } else {
                                    message = e.message;
                                  }
                                  Fluttertoast.showToast(
                                      msg: message!,
                                      gravity: ToastGravity.BOTTOM);
                                }
                                _Name.text = '';
                                _Lastname.text = '';
                                _Email.text = '';
                                _Password.text = '';
                                _Number.text = '';
                                _Address.text = '';
                                _Image.text = '';
                              }
                            },
                            child: Text('สมัครสมาชิก',
                                style: TextStyle(fontSize: 20)),
                          ),
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
