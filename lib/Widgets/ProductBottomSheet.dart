import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductDetailsBottomSheet1 extends StatefulWidget {
  final DocumentSnapshot veggie;
  final User user;
  final VoidCallback onAddToCart;

  const ProductDetailsBottomSheet1({
    Key? key,
    required this.veggie,
    required this.user,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  _ProductDetailsBottomSheetState1 createState() =>
      _ProductDetailsBottomSheetState1();
}

class _ProductDetailsBottomSheetState1
    extends State<ProductDetailsBottomSheet1> {
  int selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final data = widget.veggie.data() as Map<String, dynamic>?;
    if (data == null) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('No product data available'),
        ),
      );
    }

    bool isDiscountPeriod = _isDiscountPeriod(data);
    bool isDiscountPeriod2 = _isDiscountPeriod2(data);
    double price = data['ราคาผัก'] ?? 0.0;
    double? discountPrice;
    if (isDiscountPeriod2 && data.containsKey('percentage_discount')) {
      discountPrice = price - (price * data['percentage_discount'] / 100);
    } else if (isDiscountPeriod && data.containsKey('discount_price')) {
      discountPrice = price - data['discount_price'];
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black87,
                      width: 2,
                    ),
                  ),
                  child: Image.network(
                    widget.veggie['รูปผัก'],
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    data['ชื่อผัก'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (discountPrice != null) ...[
                    Text(
                      '${price} บาท',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '$discountPrice บาท',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '$price บาท',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ],
                  Text(
                    '(500กรัม/แพ็ค)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 200),
                child: Text(
                  'จำนวน',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (selectedQuantity > 1) {
                    setState(() {
                      selectedQuantity--;
                    });
                  }
                },
              ),
              Text(
                selectedQuantity.toString(),
                style: TextStyle(fontSize: 20),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  if (selectedQuantity < widget.veggie['จำนวนผัก']) {
                    setState(() {
                      selectedQuantity++;
                    });
                  } else {
                    Fluttertoast.showToast(
                        msg: 'สินค้าถึงขีดจำกัดแล้ว',
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_LONG,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        timeInSecForIosWeb: 2,
                        fontSize: 18);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black87, width: 2),
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ได้เพิ่มสินค้าลงตะกร้าแล้ว')),
                );
                widget.onAddToCart();
                await _updateCart(
                    widget.veggie,
                    selectedQuantity,
                    (isDiscountPeriod && discountPrice != null) ||
                            (isDiscountPeriod2 && discountPrice != null)
                        ? discountPrice
                        : price);
              },
              child: Text('เพิ่มในตะกร้า', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCart(
      DocumentSnapshot veggie, int quantity, double price) async {
    final cartCollection = FirebaseFirestore.instance.collection('cart');
    final cartItem = await cartCollection
        .where('userId', isEqualTo: widget.user.uid)
        .where('veggieId', isEqualTo: veggie.id)
        .get();

    final veggieData = veggie.data() as Map<String, dynamic>;
    bool isDiscountPeriod = _isDiscountPeriod(veggieData);
    bool isDiscountPeriod1 = _isDiscountPeriod1(veggieData);
    bool isDiscountPeriod2 = _isDiscountPeriod2(veggieData);

    Map<String, dynamic> cartItemData = {
      'userId': widget.user.uid,
      'veggieId': veggie.id,
      'name': veggieData['ชื่อผัก'],
      'ราคาจริง': veggieData['ราคาผัก'],
      'price': price,
      'quantity': quantity,
    };

    if (isDiscountPeriod1) {
      cartItemData['1 แถม 1'] = veggieData['bogo'];
    } else if (isDiscountPeriod) {
      cartItemData['ลดราคาจำนวนเต็ม'] = veggieData['discount_price'];
    } else if (isDiscountPeriod2) {
      cartItemData['ลดราคาแบบ %'] = veggieData['percentage_discount'];
    }

    if (cartItem.docs.isEmpty) {
      await cartCollection.add(cartItemData);
    } else {
      final existingItem = cartItem.docs.first;
      final existingQuantity = existingItem['quantity'];
      final newQuantity = existingQuantity + quantity;

      if (newQuantity <= veggieData['จำนวนผัก']) {
        await existingItem.reference.update({
          'quantity': newQuantity,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('จำนวนสินค้าคงเหลือไม่พอ')),
        );
      }
    }
  }

  bool _isDiscountPeriod(Map<String, dynamic> data) {
    final DateTime now = DateTime.now();

    if (data.containsKey('discount_start') &&
        data.containsKey('discount_end')) {
      final startTimestamp = data['discount_start'];
      final endTimestamp = data['discount_end'];

      if (startTimestamp is Timestamp && endTimestamp is Timestamp) {
        final DateTime startDate = startTimestamp.toDate();
        final DateTime endDate = endTimestamp.toDate();

        if (now.isAfter(startDate) && now.isBefore(endDate)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isDiscountPeriod1(Map<String, dynamic> data) {
    final DateTime now = DateTime.now();

    if (data.containsKey('bogo_start') && data.containsKey('bogo_end')) {
      final startTimestamp = data['bogo_start'];
      final endTimestamp = data['bogo_end'];

      if (startTimestamp is Timestamp && endTimestamp is Timestamp) {
        final DateTime startDate = startTimestamp.toDate();
        final DateTime endDate = endTimestamp.toDate();

        if (now.isAfter(startDate) && now.isBefore(endDate)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isDiscountPeriod2(Map<String, dynamic> data) {
    final DateTime now = DateTime.now();

    if (data.containsKey('percentage_start') &&
        data.containsKey('percentage_end')) {
      final startTimestamp = data['percentage_start'];
      final endTimestamp = data['percentage_end'];

      if (startTimestamp is Timestamp && endTimestamp is Timestamp) {
        final DateTime startDate = startTimestamp.toDate();
        final DateTime endDate = endTimestamp.toDate();

        if (now.isAfter(startDate) && now.isBefore(endDate)) {
          return true;
        }
      }
    }

    return false;
  }
}
