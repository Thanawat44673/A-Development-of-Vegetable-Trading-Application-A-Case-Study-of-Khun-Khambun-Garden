import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_appshop1/Pagesuse_admin/OrderDetailScreen.dart';

class OrderManagementScreen extends StatefulWidget {
  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/number1.jpg'), // Replace this with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final orders = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final doc = orders[index];
                return Card(
                  color: Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(doc['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('จำนวน: ${doc['quantity']} กก.'),
                        Text('ราคารวม: ${doc['price'] * doc['quantity']} บาท'),
                        Text('สถานะ: ${doc['status']}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailScreen(orderId: doc.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(DocumentSnapshot doc) {
    String status = doc['status'];

    if (status == 'รอการอนุมัติ') {
      return ElevatedButton(
        onPressed: () {
          _updateOrderStatus(doc.id, 'อนุมัติแล้ว');
        },
        child: Text('อนุมัติ'),
      );
    } else if (status == 'อนุมัติแล้ว') {
      return ElevatedButton(
        onPressed: () {
          _updateOrderStatus(doc.id, 'คำสั่งซื้อสำเร็จ');
        },
        child: Text('ยืนยันการส่ง'),
      );
    } else {
      return Container(); // ไม่ต้องการ action สำหรับคำสั่งซื้อที่เสร็จสิ้นแล้ว
    }
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      '${newStatus}At': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order status updated to $newStatus')),
    );
  }
}
