import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final int stock; // จำนวนสินค้าที่มีอยู่ในสต็อก

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
      id: doc.id,
      name: doc['name'],
      price: (doc['price'] as num).toDouble(),
      stock: doc['stock'], // ดึงข้อมูล stock จาก Firestore
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class ShoppingCart {
  final List<CartItem> items = [];

  void addProduct(Product product) {
    for (var item in items) {
      if (item.product.id == product.id) {
        item.quantity++;
        return;
      }
    }
    items.add(CartItem(product: product));
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  void clear() {
    items.clear();
  }
}

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(ShoppingCart cart) async {
    CollectionReference orders = _firestore.collection('orders');

    List<Map<String, dynamic>> items = cart.items.map((cartItem) {
      return {
        'productId': cartItem.product.id,
        'name': cartItem.product.name,
        'quantity': cartItem.quantity,
        'price': cartItem.product.price,
      };
    }).toList();

    await orders.add({
      'items': items,
      'totalPrice': cart.totalPrice,
      'createdAt': Timestamp.now(),
    });

    cart.clear();
  }
}
