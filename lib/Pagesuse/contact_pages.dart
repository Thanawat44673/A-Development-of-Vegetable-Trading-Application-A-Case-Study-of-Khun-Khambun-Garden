import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Contact_p extends StatefulWidget {
  const Contact_p({super.key});

  @override
  State<Contact_p> createState() => _Contact_pState();
}

class _Contact_pState extends State<Contact_p> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "ช่องทางการติดต่อทางสวน",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white, // สีพื้นหลัง
                  border: Border.all(
                    color: Colors.black, // สีขอบ
                    width: 2.0, // ความหนาของเส้นขอบ
                  ),
                  borderRadius: BorderRadius.circular(8.0), // รูปร่างขอบเขต
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "หากคุณลูกค้ามีปัญหาเกี่ยวกับสินค้าต่างๆสามารถติดต่อสอบถามกับทางเราได้ทุกเมื่อ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 20),
                          child: Icon(
                            Icons.facebook,
                            size: 50,
                            color: Colors.blue,
                          ),
                        ),
                        StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Contace")
                                .doc("vsxLKKo7SlAlSeKhdpRP")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final userData = snapshot.data!.data()
                                    as Map<String, dynamic>;

                                return Text(
                                  ': ${userData['เฟสบุ๊ค']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                            }),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 20),
                          child: Icon(
                            Icons.email,
                            size: 50,
                            color: Colors.red,
                          ),
                        ),
                        StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Contace")
                                .doc("vsxLKKo7SlAlSeKhdpRP")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final userData = snapshot.data!.data()
                                    as Map<String, dynamic>;

                                return Text(
                                  ': ${userData['อีเมล']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                            }),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 20),
                          child: Icon(
                            Icons.call,
                            size: 50,
                            color: Colors.green,
                          ),
                        ),
                        StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Contace")
                                .doc("vsxLKKo7SlAlSeKhdpRP")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final userData = snapshot.data!.data()
                                    as Map<String, dynamic>;

                                return Text(
                                  ': โทร ${userData['เบอร์โทรศัพท์']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                            }),
                      ],
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
