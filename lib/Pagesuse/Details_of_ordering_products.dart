import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_appshop1/Home/welcomehome.dart';
import 'package:flutter_appshop1/auth/text_box.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final User user;

  OrderConfirmationScreen({required this.user});

  @override
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("members");

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("แก้ไข" + field),
        content: TextField(
          autocorrect: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "กรอก $fieldใหม่",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: Text(
              'บันทึก',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
    //คำสั่งอัพโหลดข้อมูลการแก้ไข
    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  void _calculateTotal() async {
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: widget.user.uid)
        .get();

    setState(() {
      totalAmount = cartSnapshot.docs.fold(0.0, (sum, item) {
        return sum + (item['price'] * item['quantity']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดยืนยันคำสั่งซื้อ'),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
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
            SizedBox(
              height: 20,
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("members")
                  .doc(currentUser.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  return MyTextBox1(
                    text: userData['ที่อยู๋'],
                    sectionName: 'ที่อยู่',
                    onPressed: () => editField('ที่อยู๋'),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Container(
                height: 300,
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
                      padding: const EdgeInsets.only(right: 215),
                      child: Text(
                        "รายการทั้งหมด",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('cart')
                            .where('userId', isEqualTo: widget.user.uid)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final cartItems = snapshot.data!.docs;

                          return Column(
                            children: [
                              Expanded(
                                child: ListView(
                                  children: cartItems.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final isOnePlusOne =
                                        data['1 แถม 1'] as bool?;
                                    final quantity = data['quantity'] as int?;
                                    double itemTotal1 = doc['price'] * quantity;

                                    String subtitleText =
                                        'ราคา: ${doc['price']} x $quantity \n${itemTotal1.toStringAsFixed(2)} บาท';
                                    if (isOnePlusOne == true) {
                                      subtitleText +=
                                          '\n${doc['name']} ได้รับเพิ่ม ${quantity} แพ็ค';
                                    }

                                    return ListTile(
                                      title: Text(doc['name'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(subtitleText),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              _decrementQuantity(doc);
                                            },
                                          ),
                                          Text(quantity.toString()),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              _incrementQuantity(doc);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              _deleteItem(doc);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Container(
                height: 300,
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
                      padding: const EdgeInsets.only(right: 190),
                      child: Text(
                        "ข้อมูลการชำระเงิน",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          '    สินค้าที่ได้รับเพิ่ม',
                          style: TextStyle(fontSize: 16),
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('cart')
                              .where('userId', isEqualTo: widget.user.uid)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            final cartItems = snapshot.data!.docs;

                            int totaldiscout = cartItems.fold(0, (sum, doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final isOnePlusOne = data['1 แถม 1'] as bool?;
                              final quantity = data['quantity'] as int?;

                              if (isOnePlusOne == true && quantity != null) {
                                return sum + quantity;
                              } else {
                                return sum;
                              }
                            });

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 135),
                                        child: Text(
                                          ' ${totaldiscout} แพ็ค',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          '    ยอดคำสั่งซื้อปกติ ',
                          style: TextStyle(fontSize: 16),
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('cart')
                              .where('userId', isEqualTo: widget.user.uid)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final cartItems = snapshot.data!.docs;

                            double totalAmount = cartItems.fold(0, (sum, doc) {
                              return sum + (doc['ราคาจริง'] * doc['quantity']);
                            });

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 122,
                                        ),
                                        child: Text(
                                          '${totalAmount.toStringAsFixed(1)} บาท',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          '    ส่วนลดที่ได้รับ',
                          style: TextStyle(fontSize: 16),
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('cart')
                              .where('userId', isEqualTo: widget.user.uid)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            final cartItems1 = snapshot.data!.docs;

                            double totaldiscout =
                                cartItems1.fold(0, (sum, doc) {
                              return sum +
                                  ((doc['ราคาจริง'] - doc['price']) *
                                      doc['quantity']);
                            });

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 143),
                                        child: Text(
                                          ' ${totaldiscout.toStringAsFixed(1)} บาท',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    Row(
                      children: [
                        Text(
                          '   ยอดชำระเงินทั้งหมด',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('cart')
                              .where('userId', isEqualTo: widget.user.uid)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final cartItems = snapshot.data!.docs;

                            double totalAmount = cartItems.fold(0, (sum, doc) {
                              return sum + (doc['price'] * doc['quantity']);
                            });

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 55,
                                        ),
                                        child: Text(
                                          '${totalAmount.toStringAsFixed(1)} บาท',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 165,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('cart')
                  .where('userId', isEqualTo: widget.user.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final cartItems = snapshot.data!.docs;

                return SizedBox(
                  width: double.infinity,
                  height: 75,
                  child: ElevatedButton(
                    child: Text("สั่งซื้อสินค้า",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            0), // ปรับเป็นค่าที่คุณต้องการ
                      ),
                      side: BorderSide(color: Colors.red, width: 2),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _purchaseItems(cartItems);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _incrementQuantity(DocumentSnapshot doc) async {
    DocumentSnapshot veggieDoc = await FirebaseFirestore.instance
        .collection('Vegetable')
        .doc(doc['veggieId'])
        .get();

    int stock = veggieDoc['จำนวนผัก'];
    int newQuantity = doc['quantity'] + 1;

    if (newQuantity <= stock) {
      await doc.reference.update({'quantity': newQuantity});
      _calculateTotal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเพิ่มจำนวนสินค้าได้มากกว่านี้')),
      );
    }
  }

  void _decrementQuantity(DocumentSnapshot doc) async {
    int newQuantity = doc['quantity'] - 1;
    if (newQuantity > 0) {
      await doc.reference.update({'quantity': newQuantity});
    } else {
      await doc.reference.delete();
    }
    _calculateTotal();
  }

  void _deleteItem(DocumentSnapshot doc) async {
    await doc.reference.delete();
    _calculateTotal();
  }

  void _purchaseItems(List<DocumentSnapshot> cartItems) async {
    // ดึงข้อมูลที่อยู่ผู้ใช้
    DocumentSnapshot userDoc =
        await usersCollection.doc(currentUser.email).get();
    String userAddress = userDoc['ที่อยู๋'];
    String username = userDoc['ชื่อ'];
    String userlastname = userDoc['นามสกุล'];
    String usernumber = userDoc['เบอร์โทรศัพท์'];
    String loc = userDoc['พิกัด'];

    final batch = FirebaseFirestore.instance.batch();
    for (var item in cartItems) {
      // Check if the item has a BOGO promotion and if it's still valid
      DocumentSnapshot veggieDoc = await FirebaseFirestore.instance
          .collection('Vegetable')
          .doc(item['veggieId'])
          .get();
      Map<String, dynamic> data = veggieDoc.data() as Map<String, dynamic>;
      bool isBogo = data['bogo'] ?? false;
      Timestamp? promotionEnd = data['bogo_end'];
      bool isPromotionValid = isBogo &&
          promotionEnd != null &&
          promotionEnd.toDate().isAfter(DateTime.now());

      int quantityToOrder = item['quantity'];
      if (isPromotionValid) {
        quantityToOrder *= 2;
      }

      batch.set(FirebaseFirestore.instance.collection('orders').doc(), {
        'userId': widget.user.uid,
        'veggieId': item['veggieId'],
        'name': item['name'],
        'price': item['price'],
        'quantity': quantityToOrder,
        'status': 'รอการอนุมัติ',
        'ที่อยู่': userAddress,
        'ชื่อลูกค้า': username,
        'นามสกุลลูกค้า': userlastname,
        'เบอร์โทรศัพท์': usernumber,
        'พิกัด': loc,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final veggieDocRef = FirebaseFirestore.instance
          .collection('Vegetable')
          .doc(item['veggieId']);
      batch.update(
          veggieDocRef, {'จำนวนผัก': FieldValue.increment(-quantityToOrder)});
    }

    await batch.commit();

    _clearCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('สั่งซื้อเรียบร้อยแล้ว')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Welcomehome(),
      ),
    );
  }

  void _clearCart() async {
    final cartCollection = FirebaseFirestore.instance.collection('cart');
    final snapshot =
        await cartCollection.where('userId', isEqualTo: widget.user.uid).get();
    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
