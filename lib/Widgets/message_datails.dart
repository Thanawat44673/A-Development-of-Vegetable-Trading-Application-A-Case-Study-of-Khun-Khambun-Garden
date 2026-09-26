import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for initializing locale data

class Message_datails extends StatelessWidget {
  const Message_datails({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

class Message_datailsScreen extends StatelessWidget {
  final DocumentSnapshot productDocument;

  const Message_datailsScreen({super.key, required this.productDocument});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = productDocument.data() as Map<String, dynamic>;

    // Initialize the locale data for Thai
    initializeDateFormatting('th', null);

    // Function to format timestamp in Thai with date and time
    String formatTimestamp(Timestamp timestamp) {
      return DateFormat('d MMMM yyyy, HH:mm', 'th')
          .format(timestamp.toDate().add(const Duration(days: 198326)));
    }

    // Check if the fields exist and format them
    String? startTime = data.containsKey('เวลาเริ่มต้น')
        ? formatTimestamp(data['เวลาเริ่มต้น'])
        : null;
    String? endTime = data.containsKey('เวลาสิ้นสุด')
        ? formatTimestamp(data['เวลาสิ้นสุด'])
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['หัวเรื่อง']),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgroud2.jpg'), // Replace this with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
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
                    const Padding(
                      padding: EdgeInsets.only(top: 5, left: 10, bottom: 15),
                      child: Text(
                        "รายละเอียดโปรโมชั่น",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        data['ข้อมูลโปรโมชั่น'].toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 450,
                    ),
                    if (startTime != null && endTime != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Text(
                          "เริ่มต้น: $startTime",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Text(
                          "ใช้ได้ถึง: $endTime",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ],
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
