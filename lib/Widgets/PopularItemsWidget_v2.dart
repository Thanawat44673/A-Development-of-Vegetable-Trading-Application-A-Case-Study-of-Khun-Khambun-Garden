import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Pagesuse/datails/details3.dart';
import 'package:flutter_appshop1/Pagesuse/datails/details4.dart';

/*หน้าสินค้าแนะนำ*/
class PopularItemsWidget_v2 extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser!;

  double? _getPercentageDiscount1(Map<String, dynamic> data) {
    if (data.containsKey('percentage_discount')) {
      return data['percentage_discount'];
    }
    return null;
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

  double? _getDiscountPrice(Map<String, dynamic> data) {
    if (data.containsKey('discount_price')) {
      return data['discount_price'];
    }
    return null;
  }

  bool? _getBogo2(Map<String, dynamic> data) {
    if (data.containsKey('bogo')) {
      return data['bogo'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(),
        child: Row(
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Vegetable")
                    .doc("VV4Vjx9iz3qYtTgK7Jpp")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    bool isDiscountPeriod = _isDiscountPeriod(userData);
                    bool isDiscountPeriod1 = _isDiscountPeriod1(userData);
                    bool isDiscountPeriod2 = _isDiscountPeriod2(userData);
                    double? discountPrice = _getDiscountPrice(userData);
                    double? percentageDiscount =
                        _getPercentageDiscount1(userData);
                    bool? bogo = _getBogo2(userData);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Details3(
                              veggie: snapshot.data!,
                              user: currentUser,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Stack(
                                    children: [
                                      Card(
                                        child: Container(
                                          height: 260,
                                          width: 150,
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                height: 140,
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  image: DecorationImage(
                                                    image: NetworkImage(userData[
                                                        'รูปผัก']), // Replace this with your image asset
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                userData['ชื่อผัก'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              if (isDiscountPeriod)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${userData['ราคาผัก']} บาท',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                    ),
                                                    if (discountPrice != null)
                                                      Text(
                                                        '${(userData['ราคาผัก'] - discountPrice).toStringAsFixed(2)} บาท',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.red,
                                                            fontSize: 16),
                                                      ),
                                                  ],
                                                )
                                              else if (isDiscountPeriod2)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${userData['ราคาผัก']} บาท',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                    ),
                                                    if (percentageDiscount !=
                                                        null)
                                                      Text(
                                                        '${(userData['ราคาผัก'] * (1 - (percentageDiscount / 100))).toStringAsFixed(2)} บาท',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.red,
                                                            fontSize: 16),
                                                      ),
                                                  ],
                                                )
                                              else
                                                Text(
                                                  '${userData['ราคาผัก']} บาท',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                      fontSize: 16),
                                                ),
                                              Text(
                                                'สินค้าคงเหลือ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                '${userData['จำนวนผัก']} แพ็ค',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isDiscountPeriod2 &&
                                          percentageDiscount != null)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            color: Colors.red,
                                            child: Text(
                                              '${percentageDiscount.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (isDiscountPeriod &&
                                          discountPrice != null)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            color: Colors.red,
                                            child: Text(
                                              'ลดราคา',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (isDiscountPeriod1 &&
                                          bogo != null &&
                                          bogo == true)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            color: Colors.red,
                                            child: Text(
                                              '1 แถม 1',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
            //สินค้าแนะนำที่ 2
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Vegetable")
                    .doc("J6j11WbzSOPwkHAS69bF")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    bool isDiscountPeriod = _isDiscountPeriod(userData);
                    bool isDiscountPeriod1 = _isDiscountPeriod1(userData);
                    bool isDiscountPeriod2 = _isDiscountPeriod2(userData);
                    double? discountPrice = _getDiscountPrice(userData);
                    double? percentageDiscount =
                        _getPercentageDiscount1(userData);
                    bool? bogo = _getBogo2(userData);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Details4(
                              veggie: snapshot.data!,
                              user: currentUser,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Stack(
                                    children: [
                                      Card(
                                        child: Container(
                                          height: 260,
                                          width: 150,
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                height: 140,
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  image: DecorationImage(
                                                    image: NetworkImage(userData[
                                                        'รูปผัก']), // Replace this with your image asset
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                userData['ชื่อผัก'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              if (isDiscountPeriod)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${userData['ราคาผัก']} บาท',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                    ),
                                                    if (discountPrice != null)
                                                      Text(
                                                        '${(userData['ราคาผัก'] - discountPrice).toStringAsFixed(2)} บาท',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.red,
                                                            fontSize: 16),
                                                      ),
                                                  ],
                                                )
                                              else if (isDiscountPeriod2)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${userData['ราคาผัก']} บาท',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                    ),
                                                    if (percentageDiscount !=
                                                        null)
                                                      Text(
                                                        '${(userData['ราคาผัก'] * (1 - (percentageDiscount / 100))).toStringAsFixed(2)} บาท',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.red,
                                                            fontSize: 16),
                                                      ),
                                                  ],
                                                )
                                              else
                                                Text(
                                                  '${userData['ราคาผัก']} บาท',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                      fontSize: 16),
                                                ),
                                              Text(
                                                'สินค้าคงเหลือ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                '${userData['จำนวนผัก']} แพ็ค',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isDiscountPeriod2 &&
                                          percentageDiscount != null)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            color: Colors.red,
                                            child: Text(
                                              '${percentageDiscount.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (isDiscountPeriod &&
                                          discountPrice != null)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            color: Colors.red,
                                            child: Text(
                                              'ลดราคา',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (isDiscountPeriod1 &&
                                          bogo != null &&
                                          bogo == true)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            color: Colors.red,
                                            child: Text(
                                              '1 แถม 1',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
      ),
    );
  }
}
