import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late GoogleMapController _mapController;
  LatLng? _customerLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดลูกค้า'),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgroud2.jpg'), // Replace this with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('orders')
                  .doc(widget.orderId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('ไม่พบข้อมูลการสั่งซื้อ'));
                }

                var doc = snapshot.data!;
                // แยกค่าสตริงเป็นค่า latitude และ longitude
                String latLong =
                    doc['พิกัด']; // ตรวจสอบว่าคุณเก็บค่าไว้ในฟิลด์ใด
                List<String> latLongList = latLong.split(',');
                double latitude = double.parse(latLongList[0].trim());
                double longitude = double.parse(latLongList[1].trim());
                _customerLocation = LatLng(latitude, longitude);

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 375,
                        width: 350,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2.5),
                          color: Colors.white,
                        ),
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                        ),
                        padding: const EdgeInsets.only(
                          left: 15,
                          bottom: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('ชื่อลูกค้า: ${doc['ชื่อลูกค้า']}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('นามสกุลลูกค้า: ${doc['นามสกุลลูกค้า']}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('เบอร์ลูกค้า: ${doc['เบอร์โทรศัพท์']}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('ที่อยู่ลูกค้า: ${doc['ที่อยู่']}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('ชื่อผัก: ${doc['name']}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('จำนวนที่สั่ง: ${doc['quantity']}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text(
                                'ราคารวม: ${doc['price'] * doc['quantity']} บาท',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('สถานะการสั่งซื้อ: ${doc['status']}',
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _customerLocation ?? const LatLng(0, 0),
                            zoom: 20,
                          ),
                          markers: _customerLocation != null
                              ? {
                                  Marker(
                                    markerId: const MarkerId('customerLocation'),
                                    position: _customerLocation!,
                                  )
                                }
                              : {},
                        ),
                      ),
                      const SizedBox(height: 53.1),
                      _buildActionButton(doc),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Widget _buildActionButton(DocumentSnapshot doc) {
    String status = doc['status'];

    if (status == 'รอการอนุมัติ') {
      return SizedBox(
        width: double.infinity,
        height: 75,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            side: const BorderSide(color: Colors.red, width: 2),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            await _updateOrderStatus(doc.id, 'อนุมัติแล้ว');
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text("อนุมัติ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (status == 'อนุมัติแล้ว') {
      return SizedBox(
        width: double.infinity,
        height: 75,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            side: const BorderSide(color: Colors.red, width: 2),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            await _updateOrderStatus(doc.id, 'การสั่งซื้อเสร็จสิ้น');
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text("การสั่งซื้อเสร็จสิ้น",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      return Container(); // ไม่ต้องการ action สำหรับคำสั่งซื้อที่เสร็จสิ้นแล้ว
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        '${newStatus}At': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('สถานะการสั่งซื้อได้รับการอัปเดตเป็น $newStatus')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปเดตสถานะ: $error')),
        );
      }
    }
  }
}
