import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appshop1/Widgets/message_datails.dart';
import 'package:intl/intl.dart';

class Message_p extends StatefulWidget {
  const Message_p({super.key});

  @override
  State<Message_p> createState() => _Message_pState();
}

class _Message_pState extends State<Message_p> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final CollectionReference _Promotion =
      FirebaseFirestore.instance.collection('message');

  Future<void> _delete(String ProductID) async {
    FirebaseFirestore.instance.collection("message").doc(ProductID).delete();
  }

  void _openMessage_datailsPage(
      BuildContext context, DocumentSnapshot productDocument) {
    // สร้างหน้าต่างใหม่เพื่อแสดงรายละเอียดของสินค้า
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Message_datailsScreen(productDocument: productDocument),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/number1.jpg'), // Replace this with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, left: 10, bottom: 15),
              child: Text(
                "การแจ้งเตือน",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Container(
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white, // สีพื้นหลัง
                  border: Border.all(
                    color: Colors.black, // สีขอบ
                    width: 2.0, // ความหนาของเส้นขอบ
                  ),
                  borderRadius: BorderRadius.circular(8.0), // รูปร่างขอบเขต
                ),
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 5, left: 10, bottom: 15),
                      child: Text(
                        "รายละเอียด                     วันที่",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: _Promotion.snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        if (streamSnapshot.hasData) {
                          return ListView.builder(
                              shrinkWrap: true,
                              key: formKey,
                              itemCount: streamSnapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot document =
                                    streamSnapshot.data!.docs[index];
                                final DocumentSnapshot documentSnapshot =
                                    streamSnapshot.data!.docs[index];
                                return GestureDetector(
                                  onTap: () {
                                    _openMessage_datailsPage(context, document);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // จัดแถวตรงกลาง
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            documentSnapshot['หัวเรื่อง']
                                                .toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 35,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(),
                                          child: Center(
                                            child: Text(
                                              DateFormat(
                                                      '                 dd/MM/yyyy')
                                                  .format(documentSnapshot[
                                                          'เวลาสร้าง']
                                                      .toDate()
                                                      .add(Duration(
                                                          days: 198326))),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
