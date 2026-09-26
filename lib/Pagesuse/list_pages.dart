import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const Padding(
              padding: EdgeInsets.only(
                top: 50,
                right: 230,
              ),
              child: Text(
                "รายการสินค้า",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('userId', isEqualTo: currentUser.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final orders = snapshot.data!.docs;

                  return ListView(
                    children: orders.map((doc) {
                      return Card(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(doc['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('จำนวน: ${doc['quantity']} แพ็ค'),
                              Text(
                                  'ราคารวม: ${doc['price'] * doc['quantity']} บาท'),
                              Text('สถานะ: ${doc['status']}'),
                            ],
                          ),
                          trailing: doc['status'] == 'รอการอนุมัติ'
                              ? ElevatedButton(
                                  onPressed: () {
                                    _cancelOrder(doc.id, doc['veggieId'],
                                        doc['quantity']);
                                  },
                                  child: const Text('ยกเลิก'),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cancelOrder(String orderId, String productId, int quantity) async {
    DocumentReference productRef =
        FirebaseFirestore.instance.collection('Vegetable').doc(productId);
    DocumentReference orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orderId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot productSnapshot = await transaction.get(productRef);

      if (!productSnapshot.exists) {
        throw Exception("ไม่พบสินค้า");
      }

      Map<String, dynamic> data =
          productSnapshot.data() as Map<String, dynamic>;
      bool isBogo = data['bogo'] ?? false;
      Timestamp? promotionEnd =
          data['bogo_end'] as Timestamp?; // Handle null safety here
      bool isPromotionValid = isBogo &&
          promotionEnd != null &&
          promotionEnd.toDate().isAfter(DateTime.now());

      int quantityToRestore = isPromotionValid ? quantity : quantity;
      int newStock = productSnapshot['จำนวนผัก'] + quantityToRestore;

      transaction.update(productRef, {'จำนวนผัก': newStock});
      transaction.delete(orderRef);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('คำสั่งซื้อถูกยกเลิกแล้ว')),
    );
  }
}
