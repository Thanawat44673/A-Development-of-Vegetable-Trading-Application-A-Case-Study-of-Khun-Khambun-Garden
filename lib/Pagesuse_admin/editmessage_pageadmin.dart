import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Pagesuse_admin/edit_pageadmin/Promotion_history_admin.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Editmessage_admin extends StatefulWidget {
  const Editmessage_admin({Key? key}) : super(key: key);

  @override
  State<Editmessage_admin> createState() => _Editmessage_adminState();
}

class _Editmessage_adminState extends State<Editmessage_admin> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textTitle = TextEditingController();
  final TextEditingController _textBody = TextEditingController();
  int _notificationId = 0; // ตัวแปรสำหรับใช้เพิ่ม id ของแต่ละการแจ้งเตือน

  void _initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Subscribe to FCM token changes
    String? token = await messaging.getToken();
    print("FCM Token for this emulator: $token");

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(
            message.notification?.title, message.notification?.body);
      }
    });
  }

  void _initializeLocalNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          print('notification payload: ${notificationResponse.payload}');
        }
      },
    );
  }

  Future<void> _showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      _notificationId++, // ใช้ id ที่เพิ่มขึ้นทุกครั้งในการแสดงการแจ้งเตือนใหม่
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณาตั้งค่า Firebase Cloud Function สำหรับส่งการแจ้งเตือน',
          ),
        ),
      );
    }
  }

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _selectedProduct;
  String? _selectedPromotionType;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
    _initializeLocalNotifications();
    //ตัวตั้งเวลาประเทศไทย
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
    initializeDateFormatting('th', null);
  }

  //ฟังก์ชั่นเลือกช่วงเวลา
  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    return picked!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgroud2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 100, left: 25, right: 25),
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextFormField(
                            controller: _textTitle,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 3),
                                ),
                                labelText: 'หัวเรื่องโปรโมชัน'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก หัวเรื่องโปรโมชัน';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextFormField(
                            controller: _textBody,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 3),
                                ),
                                labelText: 'ข้อมูลโปรโมชั่น'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก ข้อมูลโปรโมชั่น';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Vegetable')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            var products = snapshot.data!.docs;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedProduct,
                                hint: Text('เลือกสินค้าผัก'),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 3.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 3.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                items: products.map((product) {
                                  return DropdownMenuItem<String>(
                                    value: product.id,
                                    child: Text(product['ชื่อผัก']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProduct = value!;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณาเลือกสินค้าผัก';
                                  }
                                  return null;
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedPromotionType,
                            hint: Text('เลือกประเภทโปรโมชั่น'),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 3.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 3.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: 'discount',
                                child: Text('ลดราคาแบบจำนวนเต็ม'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'percentage',
                                child: Text('ลดราคาแบบ %'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'bogo',
                                child: Text('ซื้อ 1 แถม 1'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPromotionType = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณาเลือกโปรโมชั่น';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_selectedPromotionType == 'discount') ...[
                          const SizedBox(height: 10),
                          Container(
                            width: 350,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 3),
                                ),
                                labelText: 'ลดราคาโปรโมชั่นที่จะลด',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอก ราคาที่ต้องการลด';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                        if (_selectedPromotionType == 'percentage') ...[
                          const SizedBox(height: 10),
                          Container(
                            width: 350,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextFormField(
                              controller: _percentageController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 3),
                                ),
                                labelText: 'เปอร์เซ็นต์ที่จะลด',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอก เปอร์เซ็นต์ที่จะลด';
                                }
                                if (double.tryParse(value) == null ||
                                    double.parse(value) < 0 ||
                                    double.parse(value) > 100) {
                                  return 'กรุณากรอกเปอร์เซ็นต์ที่ถูกต้อง';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _startDateTime == null
                                    ? 'เลือกวันและเวลาเริ่มต้น'
                                    : 'เริ่ม: ${DateFormat('dd MMMM yyyy HH:mm', 'th').format(_startDateTime!.add(Duration(days: 198326)))}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  locale: const Locale('th', 'TH'),
                                );
                                if (pickedDate != null) {
                                  TimeOfDay pickedTime =
                                      await _selectTime(context);
                                  if (pickedTime != null) {
                                    setState(() {
                                      // Display in Thai Buddhist year
                                      _startDateTime = tz.TZDateTime(
                                        tz.getLocation('Asia/Bangkok'),
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _endDateTime == null
                                    ? 'เลือกวันและเวลาสิ้นสุด'
                                    : 'สิ้นสุด: ${DateFormat('dd MMMM yyyy HH:mm', 'th').format(_endDateTime!.add(Duration(days: 198326)))}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  locale: const Locale('th', 'TH'),
                                );
                                if (pickedDate != null) {
                                  TimeOfDay pickedTime =
                                      await _selectTime(context);
                                  if (pickedTime != null) {
                                    setState(() {
                                      // Display in Thai Buddhist year
                                      _endDateTime = tz.TZDateTime(
                                        tz.getLocation('Asia/Bangkok'),
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              // ดึงข้อมูลโปรโมชั่นที่มีอยู่จาก Firestore
                              final QuerySnapshot querySnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('message')
                                      .where('ผักโปรโมชั่น',
                                          isEqualTo: _selectedProduct)
                                      .get();

                              bool hasOverlappingPromotion = false;
                              for (var doc in querySnapshot.docs) {
                                final startTimestamp =
                                    doc.get('เวลาเริ่มต้น') as Timestamp;
                                final endTimestamp =
                                    doc.get('เวลาสิ้นสุด') as Timestamp;

                                final startTime = startTimestamp.toDate();
                                final endTime = endTimestamp.toDate();

                                if (_startDateTime!.isBefore(endTime) &&
                                    _endDateTime!.isAfter(startTime)) {
                                  hasOverlappingPromotion = true;
                                  break;
                                }
                              }

                              if (hasOverlappingPromotion) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'มีโปรโมชั่นอื่นในช่วงเวลานี้อยู่แล้ว')),
                                );
                                return;
                              }

                              _submitForm();
                              final String title = _textTitle.text;
                              final String body = _textBody.text;

                              // ดึงข้อมูลชื่อผักจาก Firestore
                              final DocumentSnapshot docSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('Vegetable')
                                      .doc(_selectedProduct)
                                      .get();
                              final vegetableName = docSnapshot.exists
                                  ? docSnapshot.get('ชื่อผัก')
                                  : null;

                              if (body.isNotEmpty &&
                                  _selectedPromotionType == 'discount' &&
                                  _priceController.text.isNotEmpty) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection("message")
                                      .doc()
                                      .set({
                                    'หัวเรื่อง': title,
                                    'ข้อมูลโปรโมชั่น': body,
                                    'ผักโปรโมชั่น': _selectedProduct,
                                    'เวลาสร้าง': FieldValue.serverTimestamp(),
                                    'เวลาเริ่มต้น': Timestamp.fromDate(
                                        _startDateTime!.toUtc()),
                                    'เวลาสิ้นสุด': Timestamp.fromDate(
                                        _endDateTime!.toUtc()),
                                    'discount_price':
                                        double.parse(_priceController.text),
                                    'percentage_discount': null,
                                    'bogo': null,
                                    'ชื่อผัก': vegetableName,
                                  });
                                } on FirebaseAuthException catch (e) {
                                  print(e.code);
                                  // คำสั่งแสดงข้อความเวลาเขียนผิดรูปแบบ
                                }
                                _textTitle.text = '';
                                _textBody.text = '';
                              } else if (_selectedPromotionType == 'bogo') {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection("message")
                                      .doc()
                                      .set({
                                    'หัวเรื่อง': title,
                                    'ข้อมูลโปรโมชั่น': body,
                                    'ผักโปรโมชั่น': _selectedProduct,
                                    'เวลาสร้าง': FieldValue.serverTimestamp(),
                                    'เวลาเริ่มต้น': Timestamp.fromDate(
                                        _startDateTime!.toUtc()),
                                    'เวลาสิ้นสุด': Timestamp.fromDate(
                                        _endDateTime!.toUtc()),
                                    'bogo': true,
                                    'percentage_discount': null,
                                    'discount_price': null,
                                    'ชื่อผัก': vegetableName,
                                  });
                                } on FirebaseAuthException catch (e) {
                                  print(e.code);
                                  // คำสั่งแสดงข้อความเวลาเขียนผิดรูปแบบ
                                }
                                _textTitle.text = '';
                                _textBody.text = '';
                              } else if (_selectedPromotionType ==
                                      'percentage' &&
                                  _percentageController.text.isNotEmpty) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection("message")
                                      .doc()
                                      .set({
                                    'หัวเรื่อง': title,
                                    'ข้อมูลโปรโมชั่น': body,
                                    'ผักโปรโมชั่น': _selectedProduct,
                                    'เวลาสร้าง': FieldValue.serverTimestamp(),
                                    'เวลาเริ่มต้น': Timestamp.fromDate(
                                        _startDateTime!.toUtc()),
                                    'เวลาสิ้นสุด': Timestamp.fromDate(
                                        _endDateTime!.toUtc()),
                                    'percentage_discount': double.parse(
                                        _percentageController.text),
                                    'bogo': null,
                                    'discount_price': null,
                                    'ชื่อผัก': vegetableName,
                                  });
                                } on FirebaseAuthException catch (e) {
                                  print(e.code);
                                  // คำสั่งแสดงข้อความเวลาเขียนผิดรูปแบบ
                                }
                                _textTitle.text = '';
                                _textBody.text = '';
                              }

                              // สำหรับเอาโปรโมชั่นเข้าสินค้านั้นๆ
                              if (_selectedProduct != null &&
                                  _startDateTime != null &&
                                  _endDateTime != null) {
                                if (_selectedPromotionType == 'discount' &&
                                    _priceController.text.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('Vegetable')
                                      .doc(_selectedProduct)
                                      .update({
                                    'discount_price':
                                        double.parse(_priceController.text),
                                    'discount_start': Timestamp.fromDate(
                                        _startDateTime!.toUtc()),
                                    'discount_end': Timestamp.fromDate(
                                        _endDateTime!.toUtc()),
                                  });
                                } else if (_selectedPromotionType == 'bogo') {
                                  await FirebaseFirestore.instance
                                      .collection('Vegetable')
                                      .doc(_selectedProduct)
                                      .update({
                                    'bogo': true,
                                    'bogo_start': Timestamp.fromDate(
                                        _startDateTime!.toUtc()),
                                    'bogo_end': Timestamp.fromDate(
                                        _endDateTime!.toUtc()),
                                  });
                                } else if (_selectedPromotionType ==
                                        'percentage' &&
                                    _percentageController.text.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('Vegetable')
                                      .doc(_selectedProduct)
                                      .update({
                                    'percentage_discount': double.parse(
                                        _percentageController.text),
                                    'percentage_start': Timestamp.fromDate(
                                        _startDateTime!.toUtc()),
                                    'percentage_end': Timestamp.fromDate(
                                        _endDateTime!.toUtc()),
                                  });
                                }
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('เพิ่มโปรโมชั่นสำเร็จ')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            height: 40,
                            width: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // สีกรอบเส้นที่คุณต้องการ
                                width: 2.0, // ความหนาของเส้น
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.5),
                                )
                              ],
                            ),
                            child: Center(
                                child: Text(
                              "ยืนยันการแจ้งเตือน",
                              style: TextStyle(fontSize: 18),
                            )),
                          ),
                        ),
                        TextButton(
                          child: Text('แก้ไขข้อมูลโปรโมชั่น',
                              style: TextStyle(fontSize: 18)),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Promotion_history_admin();
                            }));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
