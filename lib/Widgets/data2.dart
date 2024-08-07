import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
      id: doc.id,
      name: doc['ชื่อผัก'],
      price: doc['ราคาผัก'],
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
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
