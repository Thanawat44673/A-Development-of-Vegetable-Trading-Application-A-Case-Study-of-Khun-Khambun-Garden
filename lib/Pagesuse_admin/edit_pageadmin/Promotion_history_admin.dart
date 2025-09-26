import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Promotion_history_admin extends StatefulWidget {
  @override
  _Promotion_history_adminState createState() =>
      _Promotion_history_adminState();
}

class _Promotion_history_adminState extends State<Promotion_history_admin> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _Title = TextEditingController();
  final TextEditingController _Body = TextEditingController();
  final TextEditingController _StartDate = TextEditingController();
  final TextEditingController _EndDate = TextEditingController();

  final usersCollection = FirebaseFirestore.instance.collection('message');
  final CollectionReference anotherCollection =
      FirebaseFirestore.instance.collection('Vegetable');

  final CollectionReference _Promotion =
      FirebaseFirestore.instance.collection('message');

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _Title.text = documentSnapshot['หัวเรื่อง'];
      _Body.text = documentSnapshot['ข้อมูลโปรโมชั่น'];
      _StartDate.text = DateFormat('dd MMM yyyy, HH:mm', 'th').format(
          documentSnapshot['เวลาเริ่มต้น']
              .toDate()
              .add(Duration(days: 198326)));
      _EndDate.text = DateFormat('dd MMM yyyy, HH:mm', 'th').format(
          documentSnapshot['เวลาสิ้นสุด'].toDate().add(Duration(days: 198326)));
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              right: 20,
              left: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "แก้ไขข้อมูลโปรโมชั่น",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                controller: _Title,
                decoration:
                    const InputDecoration(labelText: 'หัวเรื่อง', hintText: ''),
              ),
              TextField(
                controller: _Body,
                decoration: const InputDecoration(
                    labelText: 'ข้อมูลโปรโมชั่น', hintText: ''),
              ),
              TextField(
                controller: _StartDate,
                decoration: const InputDecoration(
                    labelText: 'วันที่เริ่มต้น', hintText: ''),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    locale: Locale('th', 'TH'), // Thai locale
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      final DateTime combined = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() {
                        _StartDate.text = DateFormat('dd MMM yyyy, HH:mm', 'th')
                            .format(combined);
                      });
                    }
                  }
                },
              ),
              TextField(
                controller: _EndDate,
                decoration: const InputDecoration(
                    labelText: 'วันที่สิ้นสุด', hintText: ''),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    locale: Locale('th', 'TH'), // Thai locale
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      final DateTime combined = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() {
                        _EndDate.text = DateFormat('dd MMM yyyy, HH:mm', 'th')
                            .format(combined);
                      });
                    }
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final String title = _Title.text;
                      final String body = _Body.text;
                      final Timestamp startTime = Timestamp.fromDate(
                          DateFormat('dd MMM yyyy, HH:mm', 'th')
                              .parse(_StartDate.text));
                      final Timestamp endTime = Timestamp.fromDate(
                          DateFormat('dd MMM yyyy, HH:mm', 'th')
                              .parse(_EndDate.text));

                      if (title.isNotEmpty && body.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('message')
                            .doc(documentSnapshot?.id)
                            .update({
                          'หัวเรื่อง': title,
                          'ข้อมูลโปรโมชั่น': body,
                          'เวลาเริ่มต้น': startTime,
                          'เวลาสิ้นสุด': endTime,
                        });
                        _Title.text = '';
                        _Body.text = '';
                        _StartDate.text = '';
                        _EndDate.text = '';

                        if (documentSnapshot?['bogo'] != null) {
                          await FirebaseFirestore.instance
                              .collection('Vegetable')
                              .doc(documentSnapshot?['ผักโปรโมชั่น'])
                              .update({
                            'bogo_start': startTime,
                            'bogo_end': endTime,
                          });
                        } else if (documentSnapshot?['discount_price'] !=
                            null) {
                          await FirebaseFirestore.instance
                              .collection('Vegetable')
                              .doc(documentSnapshot?['ผักโปรโมชั่น'])
                              .update({
                            'discount_start': startTime,
                            'discount_end': endTime,
                          });
                        } else if (documentSnapshot?['percentage_discount'] !=
                            null) {
                          await FirebaseFirestore.instance
                              .collection('Vegetable')
                              .doc(documentSnapshot?['ผักโปรโมชั่น'])
                              .update({
                            'percentage_start': startTime,
                            'percentage_end': endTime,
                          });
                        } else {
                          print('error');
                        }

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('แก้ไข'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('ยกเลิก'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(String ProductID,
      [DocumentSnapshot? documentSnapshot]) async {
    FirebaseFirestore.instance.collection("message").doc(ProductID).delete();

    if (documentSnapshot?['bogo'] != null) {
      FirebaseFirestore.instance
          .collection("Vegetable")
          .doc(documentSnapshot?['ผักโปรโมชั่น'])
          .update({
        'bogo': FieldValue.delete(),
        'bogo_start': FieldValue.delete(),
        'bogo_end': FieldValue.delete(),
      });
    } else if (documentSnapshot?['discount_price'] != null) {
      FirebaseFirestore.instance
          .collection("Vegetable")
          .doc(documentSnapshot?['ผักโปรโมชั่น'])
          .update({
        'discount_price': FieldValue.delete(),
        'discount_start': FieldValue.delete(),
        'discount_end': FieldValue.delete(),
      });
    } else if (documentSnapshot?['percentage_discount'] != null) {
      FirebaseFirestore.instance
          .collection("Vegetable")
          .doc(documentSnapshot?['ผักโปรโมชั่น'])
          .update({
        'percentage_discount': FieldValue.delete(),
        'percentage_start': FieldValue.delete(),
        'percentage_end': FieldValue.delete(),
      });
    } else {
      print('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //ชื่อมุมขวาบน
        title: Text('แก้ไขข้อมูลโปรโมชั่น'),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgroud2.jpg'), // Replace this with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder(
          stream: _Promotion.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                  //shrinkWrap: true,
                  key: formKey,
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    return Card(
                      color: Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          documentSnapshot['หัวเรื่อง'].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Text(
                          documentSnapshot['ข้อมูลโปรโมชั่น'].toString(),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => _update(documentSnapshot),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () => _delete(
                                    documentSnapshot.id, documentSnapshot),
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
