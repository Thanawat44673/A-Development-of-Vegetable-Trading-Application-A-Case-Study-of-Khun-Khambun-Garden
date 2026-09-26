import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_appshop1/Pagesuse_admin/OrderDetailScreen.dart';
import 'package:intl/intl.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgroud2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final orders = snapshot.data!.docs;

            // Group orders by customer and day
            Map<String, List<DocumentSnapshot>> groupedOrders = {};
            for (var order in orders) {
              final customer = order['ชื่อลูกค้า'];
              final timestamp = order['timestamp'] as Timestamp;
              final orderDate = DateFormat('yyyy-MM-dd')
                  .format(timestamp.toDate().add(const Duration(days: 198326)));

              String groupKey = '$customer-$orderDate';

              if (!groupedOrders.containsKey(groupKey)) {
                groupedOrders[groupKey] = [];
              }
              groupedOrders[groupKey]!.add(order);
            }

            return ListView.builder(
              itemCount: groupedOrders.keys.length,
              itemBuilder: (context, index) {
                final groupKey = groupedOrders.keys.elementAt(index);
                final groupOrders = groupedOrders[groupKey]!;

                // Display customer name and date (groupKey is in format 'customer-date')
                final splitKey = groupKey.split('-');
                final customerName = splitKey[0];
                final orderDate =
                    splitKey.sublist(1).join('-'); // Rejoin the date

                // Check for pending orders and approved orders
                bool hasPendingOrders =
                    groupOrders.any((doc) => doc['status'] == 'รอการอนุมัติ');
                bool hasApprovedOrders =
                    groupOrders.any((doc) => doc['status'] == 'อนุมัติแล้ว');
                bool hasInsufficientStockPendingOrders =
                    groupOrders.any((doc) => doc['status'] == 'รอการอนุมัติ');

                return Card(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.all(10),
                  child: ExpansionTile(
                    title: Text('$customerName - $orderDate'),
                    children: [
                      // Button to approve all pending orders for this customer
                      if (hasPendingOrders)
                        ElevatedButton(
                          onPressed: () =>
                              _approveAllOrdersForCustomer(groupOrders),
                          style: ElevatedButton.styleFrom(
                            iconColor: const Color.fromARGB(
                                255, 0, 0, 0), // Background color
                            shadowColor: Colors.white, // Text color
                            elevation: 5, // Add a shadow effect to the button
                            padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20), // Increase padding
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Rounded corners
                              side: const BorderSide(
                                  color: Colors.black,
                                  width: 2), // Border around the button
                            ),
                          ),
                          child: Text(
                            'อนุมัติออเดอร์ทั้งหมดของ $customerName',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),

                      // Button to confirm all deliveries for approved orders
                      if (hasApprovedOrders)
                        ElevatedButton(
                          onPressed: () =>
                              _confirmAllDeliveriesForCustomer(groupOrders),
                          style: ElevatedButton.styleFrom(
                            iconColor: Colors.orange, // Background color
                            shadowColor: Colors.white, // Text color
                            elevation: 5, // Add a shadow effect to the button
                            padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20), // Increase padding
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Rounded corners
                              side: const BorderSide(
                                  color: Colors.black,
                                  width: 2), // Border around the button
                            ),
                          ),
                          child: Text(
                            'ยืนยันการส่งทั้งหมดของ $customerName',
                            style: TextStyle(
                                fontSize: 16, // Adjust the text size
                                fontWeight: FontWeight.bold,
                                color: Colors.black // Make the text bold
                                ),
                          ),
                        ),

                      // Button to cancel orders that are pending approval and have insufficient stock
                      if (hasInsufficientStockPendingOrders)
                        ElevatedButton(
                          onPressed: () =>
                              _cancelAllInsufficientStockPendingOrders(
                                  groupOrders),
                          style: ElevatedButton.styleFrom(
                            iconColor: Colors.red, // Background color
                            shadowColor: Colors.white, // Text color
                            elevation: 5, // Add a shadow effect to the button
                            padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20), // Increase padding
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Rounded corners
                              side: const BorderSide(
                                  color: Colors.red,
                                  width: 2), // Border around the button
                            ),
                          ),
                          child: Text(
                            'ยกเลิกออเดอร์ทั้งหมดของ $customerName',
                            style: TextStyle(
                                fontSize: 16, // Adjust the text size
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.red // Make the text red for cancel
                                ),
                          ),
                        ),

                      ...groupOrders.map((doc) {
                        return ListTile(
                          title: Text(doc['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('จำนวน: ${doc['quantity']} กก.'),
                              Text(
                                  'ราคารวม: ${doc['price'] * doc['quantity']} บาท'),
                              Text('สถานะ: ${doc['status']}'),
                            ],
                          ),
                          trailing: (doc['status'] ==
                                  'รอการอนุมัติ') // Show cancel button only if pending
                              ? IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    _cancelOrder(doc.id, doc['veggieId'],
                                        doc['quantity']);
                                  },
                                )
                              : null, // No cancel button if the status is not 'รอการอนุมัติ'
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetailScreen(orderId: doc.id),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ฟังก์ชั่น อนุมัติสินค้าทั้งหมดโดย ไม่จำเป็นต้องไปกดอนุมัติทีละตัว
  void _approveAllOrdersForCustomer(List<DocumentSnapshot> groupOrders) {
    for (var order in groupOrders) {
      if (order['status'] == 'รอการอนุมัติ') {
        _updateOrderStatus(order.id, 'อนุมัติแล้ว');
      }
    }
  }

  // Function to confirm all deliveries for approved orders
  void _confirmAllDeliveriesForCustomer(List<DocumentSnapshot> groupOrders) {
    for (var order in groupOrders) {
      if (order['status'] == 'อนุมัติแล้ว') {
        _updateOrderStatus(order.id, 'คำสั่งซื้อสำเร็จ');
      }
    }
  }

  // Function to cancel pending orders with insufficient stock
  void _cancelAllInsufficientStockPendingOrders(
      List<DocumentSnapshot> groupOrders) {
    for (var order in groupOrders) {
      if (order['status'] == 'รอการอนุมัติ') {
        _updateOrderStatus(order.id, 'ยกเลิกคำสั่งซื้อ');
      }
    }
  }

  void _cancelOrder(String orderId, String productId, int quantity) async {
    DocumentReference productRef =
        FirebaseFirestore.instance.collection('Vegetable').doc(productId);
    DocumentReference orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orderId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot productSnapshot = await transaction.get(productRef);

      if (!productSnapshot.exists) {
        throw Exception("ไม่พบสินค้า");
      }

      Map<String, dynamic> data =
          productSnapshot.data() as Map<String, dynamic>;
      bool isBogo = data['bogo'] ?? false;
      Timestamp? promotionEnd =
          data['bogo_end'] as Timestamp?; // Handle null safety here
      bool isPromotionValid = isBogo &&
          promotionEnd != null &&
          promotionEnd.toDate().isAfter(DateTime.now());

      int quantityToRestore = isPromotionValid ? quantity : quantity;
      int newStock = productSnapshot['จำนวนผัก'] + quantityToRestore;

      transaction.update(productRef, {'จำนวนผัก': newStock});
      transaction.delete(orderRef);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('คำสั่งซื้อถูกยกเลิกแล้ว')),
    );
  }

  Widget _buildActionButton(DocumentSnapshot doc) {
    String status = doc['status'];

    if (status == 'รอการอนุมัติ') {
      return ElevatedButton(
        onPressed: () {
          _updateOrderStatus(doc.id, 'อนุมัติแล้ว');
        },
        child: const Text('อนุมัติ'),
      );
    } else if (status == 'อนุมัติแล้ว') {
      return ElevatedButton(
        onPressed: () {
          _updateOrderStatus(doc.id, 'คำสั่งซื้อสำเร็จ');
        },
        child: const Text('ยืนยันการส่ง'),
      );
    } else if (status == 'รอการอนุมัติ') {
      return ElevatedButton(
        onPressed: () {
          _updateOrderStatus(doc.id, 'ยกเลิกคำสั่งซื้อ');
        },
        style: ElevatedButton.styleFrom(
          iconColor: Colors.red,
        ),
        child: Text('ยกเลิกออเดอร์'),
      );
    } else {
      return Container(); // No button for completed or canceled orders
    }
  }

  // Function to update order status
  void _updateOrderStatus(String orderId, String newStatus) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      '${newStatus}At': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('สถานะการสั่งซื้อได้รับการอัปเดตเป็น $newStatus')),
    );
  }
}
