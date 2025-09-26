import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Pagesuse/Cart.dart';
import 'package:flutter_appshop1/Pagesuse/search/Search_veg.dart';
import 'package:flutter_appshop1/Widgets/ProductDetailScreen.dart';
import 'package:flutter_appshop1/Widgets/PopularItemsWidget.dart';

class Home_v extends StatefulWidget {
  @override
  State<Home_v> createState() => _Home_vState();
}

class _Home_vState extends State<Home_v> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final CarouselController _controller = CarouselController();

  List _products = [];
  var _firestoreInstance = FirebaseFirestore.instance;

  int _current = 0;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    QuerySnapshot qn = await _firestoreInstance.collection("Vegetable").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        Map<String, dynamic> data = qn.docs[i].data() as Map<String, dynamic>;
        _products.add({
          "ชื่อผัก": data["ชื่อผัก"],
          "ราคาผัก": data["ราคาผัก"],
          "รูปผัก": data["รูปผัก"],
          "percentage_discount": data.containsKey("percentage_discount")
              ? data["percentage_discount"]
              : null,
          "discount_start": data.containsKey("discount_start")
              ? data["discount_start"]
              : null,
          "discount_end":
              data.containsKey("discount_end") ? data["discount_end"] : null,
          "bogo": data.containsKey("bogo") ? data["bogo"] : null,
          "discount_price": data.containsKey("discount_price")
              ? data["discount_price"]
              : null,
          "จำนวนผัก": data.containsKey("จำนวนผัก") ? data["จำนวนผัก"] : null,
        });
      }
    });
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

  double? _getPercentageDiscount(Map<String, dynamic> data) {
    if (data.containsKey('percentage_discount')) {
      return data['percentage_discount'];
    }
    return null;
  }

  double? _getDiscountPrice1(Map<String, dynamic> data) {
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

  void _openProductDetailPage(
      BuildContext context, DocumentSnapshot productDocument) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          productDocument: productDocument,
          veggie: productDocument,
          user: currentUser,
        ),
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
            image: AssetImage('assets/backgroud2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10, left: 20, bottom: 15),
              child: Text(
                "สวนคุณคำบุญ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SearchForm();
                    }));
                  },
                  child: Container(
                    width: 350,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ]),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.search,
                          ),
                          Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                "ค้นหาสินค้าได้ตรงนี้",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Colors.red,
                    size: 35,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CartScreen(
                        user: currentUser,
                      ),
                    ));
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Vegetable')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                }
                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Text('');
                }

                // Filter out products without promotions
                var promotedProducts = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  bool isDiscountPeriod = _isDiscountPeriod(data);
                  bool isDiscountPeriod1 = _isDiscountPeriod1(data);
                  bool isDiscountPeriod2 = _isDiscountPeriod2(data);
                  return isDiscountPeriod ||
                      isDiscountPeriod1 ||
                      isDiscountPeriod2;
                }).toList();

                if (promotedProducts.isEmpty) {
                  return SizedBox(); // Return an empty SizedBox when there are no promoted products
                }

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 5, right: 240, bottom: 5),
                      child: Text(
                        "สินค้าโปรโมชั่น",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 185,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: promotedProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document = promotedProducts[index];
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          bool isDiscountPeriod = _isDiscountPeriod(data);
                          bool isDiscountPeriod1 = _isDiscountPeriod1(data);
                          bool isDiscountPeriod2 = _isDiscountPeriod2(data);
                          double? percentageDiscount =
                              _getPercentageDiscount(data);
                          double? discountPrice = _getDiscountPrice1(data);
                          bool? bogo = _getBogo2(data);

                          return GestureDetector(
                            onTap: () {
                              _openProductDetailPage(context, document);
                            },
                            child: Stack(
                              children: [
                                Card(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 200, // Set the width as needed
                                        height: 75, // Set the height as needed
                                        child: AspectRatio(
                                          aspectRatio: 2,
                                          child: Container(
                                            color: Colors.white,
                                            child:
                                                Image.network(data['รูปผัก']),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        data['ชื่อผัก'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (isDiscountPeriod)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${data['ราคาผัก']} บาท',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 16,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                            if (discountPrice != null)
                                              Text(
                                                '${(data['ราคาผัก'] - discountPrice).toStringAsFixed(2)} บาท',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                  fontSize: 16,
                                                ),
                                              ),
                                          ],
                                        )
                                      else if (isDiscountPeriod2)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${data['ราคาผัก']} บาท',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 16,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                            if (percentageDiscount != null)
                                              Text(
                                                '${(data['ราคาผัก'] * (1 - (percentageDiscount / 100))).toStringAsFixed(2)} บาท',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                  fontSize: 16,
                                                ),
                                              ),
                                          ],
                                        )
                                      else
                                        Text(
                                          '${data['ราคาผัก']} บาท',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                      Text(
                                        'สินค้าคงเหลือ ${data['จำนวนผัก']} แพ็ค',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
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
                                if (isDiscountPeriod && discountPrice != null)
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
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 10),
              child: Text(
                "สินค้าผักแนะนำของทางสวน",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            PopularItemsWidget(),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 10),
              child: Text(
                "สินค้าผักทั้งหมด",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Vegetable')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                }
                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Text('ไม่พบข้อมูลสินค้า');
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    bool isDiscountPeriod = _isDiscountPeriod(data);
                    bool isDiscountPeriod1 = _isDiscountPeriod1(data);
                    bool isDiscountPeriod2 = _isDiscountPeriod2(data);
                    double? percentageDiscount = _getPercentageDiscount(data);
                    double? discountPrice = _getDiscountPrice1(data);
                    bool? bogo = _getBogo2(data);

                    return GestureDetector(
                      onTap: () {
                        _openProductDetailPage(context, document);
                      },
                      child: Stack(
                        children: [
                          Card(
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 2,
                                  child: Container(
                                    color: Colors.white,
                                    child: Image.network(data['รูปผัก']),
                                  ),
                                ),
                                Text(
                                  data['ชื่อผัก'],
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
                                        '${data['ราคาผัก']} บาท',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 16,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                      if (discountPrice != null)
                                        Text(
                                          '${(data['ราคาผัก'] - discountPrice).toStringAsFixed(2)} บาท',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
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
                                        '${data['ราคาผัก']} บาท',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 16,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                      if (percentageDiscount != null)
                                        Text(
                                          '${(data['ราคาผัก'] * (1 - (percentageDiscount / 100))).toStringAsFixed(2)} บาท',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                              fontSize: 16),
                                        ),
                                    ],
                                  )
                                else
                                  Text(
                                    '${data['ราคาผัก']} บาท',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 16),
                                  ),
                                Text(
                                  'สินค้าคงเหลือ ${data['จำนวนผัก']} แพ็ค',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          if (isDiscountPeriod2 && percentageDiscount != null)
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
                          if (isDiscountPeriod && discountPrice != null)
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
                          if (isDiscountPeriod1 && bogo != null && bogo == true)
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
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
