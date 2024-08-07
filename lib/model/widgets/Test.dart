import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Widgets/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
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
  AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
      playSound: true);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('A bg message just showed up :  ${message.messageId}');
  }

  late TextEditingController _textTitle;
  late TextEditingController _textBody;

  @override
  void dispose() {
    _textTitle.dispose();
    _textBody.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final TextEditingController _priceController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _selectedProduct;
  String? _selectedPromotionType;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
    initializeDateFormatting('th', null);

    _textTitle = TextEditingController();
    _textBody = TextEditingController();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification!.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  color: Colors.blue,
                  playSound: true,
                  icon: '@mipmap/ic_launcher'),
            ));
      }
    });
  }

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
            image: AssetImage('assets/number1.jpg'),
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
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 350,
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
                                labelText: 'หัวเรื่อง'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอก หัวเรื่อง';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 350,
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
                        const SizedBox(height: 10),
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
                              width: 350,
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
                        const SizedBox(height: 10),
                        Container(
                          width: 350,
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
                                child: Text('ลดราคา'),
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _startDateTime == null
                                    ? 'เลือกวันและเวลาเริ่มต้น'
                                    : 'เริ่ม: ${DateFormat('dd MMMM yyyy HH:mm:ss', 'th').format(_startDateTime!)}',
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _endDateTime == null
                                    ? 'เลือกวันและเวลาสิ้นสุด'
                                    : 'สิ้นสุด: ${DateFormat('dd MMMM yyyy HH:mm:ss', 'th').format(_endDateTime!)}',
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
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              pushNotificationsAllUsers(
                                title: _textTitle.text,
                                body: _textBody.text,
                              );
                              final String title = _textTitle.text;
                              final String body = _textBody.text;
                              if (body.isNotEmpty) {
                                try {
                                  FirebaseFirestore.instance
                                      .collection("message")
                                      .doc()
                                      .set({
                                    'หัวเรื่อง': title,
                                    'ข้อมูลโปรโมชั่น': body,
                                    'เวลาสร้าง': FieldValue.serverTimestamp(),
                                  });
                                } on FirebaseAuthException catch (e) {
                                  print(e.code);
                                }
                                _textTitle.text = '';
                                _textBody.text = '';
                              }
                              if (_selectedProduct != null &&
                                  _startDateTime != null &&
                                  _endDateTime != null) {
                                if (_selectedPromotionType == 'discount' &&
                                    _priceController.text.isNotEmpty) {
                                  FirebaseFirestore.instance
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
                                  FirebaseFirestore.instance
                                      .collection('Vegetable')
                                      .doc(_selectedProduct)
                                      .update({
                                    'bogo': true,
                                    'bogo_start': Timestamp.fromDate(
                                        _startDateTime!.toUtc()),
                                    'bogo_end': Timestamp.fromDate(
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
                                color: Colors.black,
                                width: 2.0,
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
                              ),
                            ),
                          ),
                        ),
                        /*TextButton(
                          child: Text('แก้ไขข้อมูลโปรโมชั่น',
                              style: TextStyle(fontSize: 18)),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Promotion_history_admin();
                            }));
                          },
                        ),*/
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

  Future<bool> pushNotificationsAllUsers({
    required String title,
    required String body,
  }) async {
    FirebaseMessaging.instance.subscribeToTopic("myTopic1");

    String dataNotifications = '{ '
        ' "to" : "/topics/myTopic1" , '
        ' "notification" : {'
        ' "title":"$title" , '
        ' "body":"$body" '
        ' } '
        ' } ';

    var response = await http.post(
      Uri.parse(Constants.BASE_URL),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key= ${Constants.KEY_SERVER}',
      },
      body: dataNotifications,
    );
    print(response.body.toString());
    return true;
  }
}
