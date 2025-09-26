import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_appshop1/Pagesuse/Cart.dart';
import 'package:flutter_appshop1/Pagesuse/Details_of_ordering_products.dart';
import 'package:flutter_appshop1/Widgets/ProductBottomSheet.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductDetailScreen extends StatefulWidget {
  final DocumentSnapshot veggie;
  final User user;
  final DocumentSnapshot productDocument;

  ProductDetailScreen({
    Key? key,
    required this.productDocument,
    required this.veggie,
    required this.user,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
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
    final data = widget.productDocument.data() as Map<String, dynamic>?;
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

  @override
  Widget build(BuildContext context) {
    final data = widget.productDocument.data() as Map<String, dynamic>?;

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
    double? percentageDiscount = _getPercentageDiscount(data);
    double? discountPrice = _getDiscountPrice1(data);

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
            image: AssetImage('assets/backgroud2.jpg'),
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
                      fontSize: 25),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDiscountPeriod)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            Column(
                              children: [
                                Text(
                                  'ลดราคา ${discountPrice} บาท เหลือ $discountedPrice บาท',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      )
                    else if (isDiscountPeriod2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            Column(
                              children: [
                                Text(
                                  'ลดราคา ${percentageDiscount} % เหลือ  $discountedPrice1 บาท',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
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

class ProductDetailsBottomSheet extends StatefulWidget {
  final DocumentSnapshot veggie;
  final User user;

  const ProductDetailsBottomSheet({
    Key? key,
    required this.veggie,
    required this.user,
  }) : super(key: key);

  @override
  _ProductDetailsBottomSheetState createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
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
                    data['รูปผัก'],
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
                  if (selectedQuantity < data['จำนวนผัก']) {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderConfirmationScreen(user: widget.user),
                  ),
                );
                await _updateCart(
                    widget.veggie,
                    selectedQuantity,
                    (isDiscountPeriod && discountPrice != null) ||
                            (isDiscountPeriod2 && discountPrice != null)
                        ? discountPrice
                        : price);
              },
              child: Text('สั่งซื้อสินค้า', style: TextStyle(fontSize: 20)),
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
