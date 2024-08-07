import 'package:cloud_firestore/cloud_firestore.dart';

class Product1 {
  final String id;
  final String name;
  final double price;

  Product1({required this.id, required this.name, required this.price});

  factory Product1.fromDocument(DocumentSnapshot doc) {
    return Product1(
      id: doc.id,
      name: doc['ชื่อผัก'],
      price: doc['ราคาผัก'],
    );
  }
}

class CartItem {
  final Product1 product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class ShoppingCart1 {
  final List<CartItem> items = [];

  void addProduct(Product1 product) {
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
