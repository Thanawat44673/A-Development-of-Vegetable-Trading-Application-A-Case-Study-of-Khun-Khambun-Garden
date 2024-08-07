import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Pagesuse/Cart.dart';
import 'package:flutter_appshop1/Widgets/ProductBottomSheet.dart';
import 'package:flutter_appshop1/Widgets/ProductDetailScreen.dart';

class Details1 extends StatefulWidget {
  final DocumentSnapshot veggie;
  final User user;

  const Details1({
    Key? key,
    required this.veggie,
    required this.user,
  }) : super(key: key);

  @override
  State<Details1> createState() => _Details1State();
}

class _Details1State extends State<Details1>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  OverlayEntry? _overlayEntry;
  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _addToCartKey = GlobalKey();
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fetchCartCount();
  }

  void _fetchCartCount() async {
    final cartCollection = FirebaseFirestore.instance.collection('cart');
    final cartItems =
        await cartCollection.where('userId', isEqualTo: widget.user.uid).get();

    // Count unique items
    final uniqueItemCount = cartItems.docs.length;

    setState(() {
      _cartItemCount = uniqueItemCount;
    });
  }

  void _startAddToCartAnimation() {
    final RenderBox cartBox =
        _cartKey.currentContext!.findRenderObject() as RenderBox;
    final cartPosition = cartBox.localToGlobal(Offset.zero);

    final RenderBox addToCartBox =
        _addToCartKey.currentContext!.findRenderObject() as RenderBox;
    final addToCartPosition = addToCartBox.localToGlobal(Offset.zero);

    _overlayEntry = _createOverlayEntry(addToCartPosition, cartPosition);
    Overlay.of(context)!.insert(_overlayEntry!);

    _animationController.forward().then((_) {
      _animationController.reset();
      _overlayEntry!.remove();
      _fetchCartCount(); // Update cart count after animation completes
    });
  }

  OverlayEntry _createOverlayEntry(Offset startPosition, Offset endPosition) {
    final data = widget.veggie.data() as Map<String, dynamic>?;
    return OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final double dx = startPosition.dx +
                (endPosition.dx - startPosition.dx) *
                    _animationController.value;
            final double dy = startPosition.dy +
                (endPosition.dy - startPosition.dy) *
                    _animationController.value;
            return Positioned(
              left: dx,
              top: dy,
              child: Image.network(
                data?['รูปผัก'],
                width: 30,
                height: 30,
              ),
            );
          },
        );
      },
    );
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

  double _calculateDiscountedPrice(Map<String, dynamic> data) {
    if (_isDiscountPeriod(data)) {
      final double originalPrice = data['ราคาผัก'];
      if (data.containsKey('discount_price')) {
        final double discountAmount = data['discount_price'];
        return originalPrice - discountAmount;
      }
    }
    return data['ราคาผัก'];
  }

  double _calculateDiscountedPrice1(Map<String, dynamic> data) {
    if (_isDiscountPeriod2(data)) {
      final double originalPrice = data['ราคาผัก'];
      if (data.containsKey('percentage_discount')) {
        final double discountPercentage = data['percentage_discount'];
        final double discountAmount =
            originalPrice * (discountPercentage / 100);
        return originalPrice - discountAmount;
      }
    }
    return data['ราคาผัก'];
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.veggie.data() as Map<String, dynamic>?;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: const Color.fromARGB(255, 216, 255, 171),
        ),
        body: Center(
          child: Text('No product data available'),
        ),
      );
    }

    bool isDiscountPeriod = _isDiscountPeriod(data);
    bool isDiscountPeriod2 = _isDiscountPeriod2(data);
    double discountedPrice = _calculateDiscountedPrice(data);
    double discountedPrice1 = _calculateDiscountedPrice1(data);

    return Scaffold(
      appBar: AppBar(
        title: Text(data['ชื่อผัก']),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
        actions: [
          Stack(
            children: [
              IconButton(
                key: _cartKey,
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.red,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                    builder: (context) => CartScreen(
                      user: widget.user,
                    ),
                  ))
                      .then((_) {
                    _fetchCartCount(); // Update cart count when returning from the cart screen
                  });
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/number1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Image.network(
                    data['รูปผัก'],
                    width: 350,
                    height: 250,
                  )
                ],
              )),
            ),
            SizedBox(height: 40),
            Container(
              width: 350,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: ListTile(
                title: Text(
                  '${data['ชื่อผัก']} (500 กรัม/แพ็ค)',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 22),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDiscountPeriod)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${data['ราคาผัก']} บาท',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 22,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          if (discountedPrice != null)
                            Text(
                              '$discountedPrice บาท',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 22,
                              ),
                            ),
                        ],
                      )
                    else if (isDiscountPeriod2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${data['ราคาผัก']} บาท',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 22,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          if (discountedPrice1 != null)
                            Text(
                              '$discountedPrice1 บาท',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 22,
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
                          fontSize: 22,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              data['จำนวนผัก'] > 0
                  ? 'สินค้าคงเหลือ: ${data['จำนวนผัก']} แพ็ค'
                  : 'สินค้าหมด',
              style: TextStyle(
                  fontSize: 20,
                  color: data['จำนวนผัก'] > 0 ? Colors.black : Colors.red),
            ),
            Expanded(
              child: SizedBox(),
            ),
            data['จำนวนผัก'] > 0
                ? Row(
                    children: [
                      GestureDetector(
                        key: _addToCartKey,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ProductDetailsBottomSheet1(
                                veggie: widget.veggie,
                                user: widget.user,
                                onAddToCart: () {
                                  _startAddToCartAnimation();
                                },
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          width: 161.4,
                          height: 75,
                          child: Container(
                            color: Colors.green,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    'เพิ่มลงในตะกร้า',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(),
                        child: SizedBox(
                          width: 250,
                          height: 75,
                          child: Padding(
                            padding: EdgeInsets.only(),
                            child: ElevatedButton(
                              child: Text("สั่งซื้อสินค้า",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                side: BorderSide(color: Colors.red, width: 2),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ProductDetailsBottomSheet(
                                      veggie: widget.veggie,
                                      user: widget.user,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
