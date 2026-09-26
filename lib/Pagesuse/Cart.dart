import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_appshop1/Pagesuse/Details_of_ordering_products.dart';

class CartScreen extends StatefulWidget {
  final User user;

  const CartScreen({super.key, required this.user});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตะกร้าสินค้า'),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgroud2.jpg'), // Replace this with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('cart')
              .where('userId', isEqualTo: widget.user.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final cartItems = snapshot.data!.docs;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: cartItems.map((doc) {
                      return ListTile(
                        title: Text(doc['name']),
                        subtitle: Text('ราคา: ${doc['price']} บาท'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                decrementQuantity(doc);
                              },
                            ),
                            Text(doc['quantity'].toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                incrementQuantity(doc);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteItem(doc);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 75,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            0), // ปรับเป็นค่าที่คุณต้องการ
                      ),
                      side: const BorderSide(color: Colors.red, width: 2),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderConfirmationScreen(user: widget.user),
                        ),
                      );
                    },
                    child: Text("สั่งซื้อสินค้า",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void incrementQuantity(DocumentSnapshot doc) async {
    DocumentSnapshot veggieDoc = await FirebaseFirestore.instance
        .collection('Vegetable')
        .doc(doc['veggieId'])
        .get();

    int stock = veggieDoc['จำนวนสินค้า'];
    int newQuantity = doc['quantity'] + 1;

    if (newQuantity <= stock) {
      doc.reference.update({'quantity': newQuantity});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเพิ่มมากกว่าสต็อกที่มีอยู่')),
      );
    }
  }

  void decrementQuantity(DocumentSnapshot doc) {
    int newQuantity = doc['quantity'] - 1;
    if (newQuantity > 0) {
      doc.reference.update({'quantity': newQuantity});
    } else {
      deleteItem(doc);
    }
  }

  void deleteItem(DocumentSnapshot doc) {
    doc.reference.delete();
  }
}
