import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Editvegetable_admin extends StatefulWidget {
  const Editvegetable_admin({super.key});

  @override
  _Editvegetable_adminState createState() => _Editvegetable_adminState();
}

class _Editvegetable_adminState extends State<Editvegetable_admin> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _Product = TextEditingController();
  final TextEditingController _Price = TextEditingController();
  final TextEditingController _Number_product = TextEditingController();

  String? imageUrl;

  final usersCollection = FirebaseFirestore.instance.collection("Vegetable");

  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> showImagePickerOption(BuildContext context) async {
    String? imageUrl;

    await showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final file = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (file == null) return;
                        String fileName =
                            DateTime.now().microsecondsSinceEpoch.toString();
                        Reference ref = FirebaseStorage.instance.ref();
                        Reference referenceDireImages = ref.child('images');
                        Reference referenceImageaToUpload =
                            referenceDireImages.child(fileName);

                        try {
                          await referenceImageaToUpload
                              .putFile(File(file.path));

                          imageUrl =
                              await referenceImageaToUpload.getDownloadURL();
                          Fluttertoast.showToast(
                              msg: "อัพโหลดรูปโปรไฟล์เรียบร้อยแล้ว",
                              gravity: ToastGravity.BOTTOM);
                        } catch (error) {
                          // จัดการ error ได้ตามความเหมาะสม
                        }
                        Navigator.of(context)
                            .pop(imageUrl); // คืนค่า imageUrl กลับไป
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                            ),
                            Text("แกลลอรี่"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final file = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (file == null) return;

                        String fileName =
                            DateTime.now().microsecondsSinceEpoch.toString();
                        Reference ref = FirebaseStorage.instance.ref();
                        Reference referenceDireImages = ref.child('images');
                        Reference referenceImageaToUpload =
                            referenceDireImages.child(fileName);

                        try {
                          await referenceImageaToUpload
                              .putFile(File(file.path));

                          imageUrl =
                              await referenceImageaToUpload.getDownloadURL();
                          Fluttertoast.showToast(
                              msg: "อัพโหลดรูปโปรไฟล์เรียบร้อยแล้ว",
                              gravity: ToastGravity.BOTTOM);
                        } catch (error) {
                          // จัดการ error ได้ตามความเหมาะสม
                        }
                        Navigator.of(context)
                            .pop(imageUrl); // คืนค่า imageUrl กลับไป
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera,
                              size: 70,
                            ),
                            Text("กล้อง"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });

    return imageUrl; // คืนค่า URL ของรูปภาพกลับไป
  }

  final CollectionReference _Vegetable =
      FirebaseFirestore.instance.collection("Vegetable");

  void _create() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            right: 20,
            left: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "เพิ่มสินค้า",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                controller: _Product,
                decoration: const InputDecoration(labelText: 'ชื่อผัก'),
              ),
              TextField(
                controller: _Price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ราคาผัก'),
              ),
              TextField(
                controller: _Number_product,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'จำนวนผัก'),
              ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          imageUrl != null ? NetworkImage(imageUrl!) : null,
                      child: imageUrl == null
                          ? const Icon(Icons.add_a_photo,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: () async {
                          String? uploadedUrl =
                              await showImagePickerOption(context);
                          if (uploadedUrl != null) {
                            setState(() {
                              imageUrl = uploadedUrl; // Update the image URL
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final String product = _Product.text;
                      final int? numberPdt =
                          int.tryParse(_Number_product.text);
                      final double? price = double.tryParse(_Price.text);

                      if (price != null &&
                          product.isNotEmpty &&
                          numberPdt != null) {
                        try {
                          // Upload product data to Firestore
                          await FirebaseFirestore.instance
                              .collection("Vegetable")
                              .doc()
                              .set({
                            'ชื่อผัก': product,
                            'ราคาผัก': price,
                            'จำนวนผัก': numberPdt,
                            'รูปผัก': imageUrl // Use the uploaded image URL
                          });
                        } on FirebaseAuthException catch (e) {
                          print(e.code);
                        }

                        // Clear the text fields
                        _Product.clear();
                        _Price.clear();
                        _Number_product.clear();

                        // Reset the image URL to clear the image
                        setState(() {
                          imageUrl = null;
                        });

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('เพิ่ม'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('ยกเลิก'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updata([DocumentSnapshot? documentSnapshot]) async {
    String imageUrl = ''; // ประกาศตัวแปร imageUrl

    if (documentSnapshot != null) {
      _Product.text = documentSnapshot['ชื่อผัก'];
      _Price.text = (documentSnapshot['ราคาผัก'] as num).toDouble().toString();
      _Number_product.text =
          (documentSnapshot['จำนวนผัก'] as num).toInt().toString();

      // รับ URL ของรูปภาพจาก documentSnapshot
      imageUrl = documentSnapshot['รูปผัก'] ?? '';
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: EdgeInsets.only(
                    top: 20,
                    right: 20,
                    left: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "แก้ไขข้อมูลผัก",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // แสดงรูปภาพ ถ้ามี URL
                    if (imageUrl.isNotEmpty)
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // สีของกรอบ
                              width: 3, // ความหนาของกรอบ
                            ),
                            borderRadius:
                                BorderRadius.circular(10), // มุมโค้งของกรอบ
                          ),
                          child: Image.network(
                            imageUrl, // URL ของรูปภาพ
                            height: 150, // ขนาดของรูป
                            width: 150, // ขนาดของรูป
                            fit: BoxFit.cover, // วิธีการจัดรูปภาพให้พอดีกับกรอบ
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Text(
                          'ไม่มีรูปภาพ', // ข้อความกรณีไม่มีรูป
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _Product,
                      decoration: const InputDecoration(
                          labelText: 'ชื่อผัก', hintText: ''),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: _Price,
                      decoration: const InputDecoration(
                          labelText: 'ราคาผัก', hintText: ''),
                    ),
                    TextField(
                      controller: _Number_product,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'จำนวนผัก', hintText: ''),
                    ),

                    const SizedBox(height: 20),

                    Stack(children: [
                      Center(
                        child: IconButton(
                          onPressed: () async {
                            String? newImageUrl =
                                await showImagePickerOption(context);
                            if (newImageUrl != null && newImageUrl.isNotEmpty) {
                              setState(() {
                                imageUrl = newImageUrl; // อัปเดต URL ของรูปภาพ
                              });
                            }
                          },
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              final String product = _Product.text;
                              final double? price =
                                  double.tryParse(_Price.text);
                              final int? numberPdt =
                                  int.tryParse(_Number_product.text);

                              if (price != null) {
                                Map<String, dynamic> updateData = {
                                  'ชื่อผัก': product,
                                  'ราคาผัก': price,
                                  'จำนวนผัก': numberPdt,
                                };

                                // อัปเดตรูปภาพถ้ามีการเลือกใหม่
                                if (imageUrl.isNotEmpty) {
                                  updateData['รูปผัก'] = imageUrl;
                                }

                                FirebaseFirestore.instance
                                    .collection("Vegetable")
                                    .doc(documentSnapshot?.id)
                                    .update(updateData);

                                _Product.text = '';
                                _Price.text = '';
                                _Number_product.text = '';

                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('แก้ไข')),
                        const SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('ยกเลิก')),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Future<void> _delete(String ProductID) async {
    FirebaseFirestore.instance.collection("Vegetable").doc(ProductID).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgroud2.jpg'), // Replace this with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder(
          stream: _Vegetable.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                  key: formKey,
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    return Card(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          documentSnapshot['ชื่อผัก'].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Text(
                            '${documentSnapshot['ราคาผัก']} บาท/500 กรัม                               สินค้าคงเหลือ  ${documentSnapshot['จำนวนผัก']} แพ็ค'
                                .toString()),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(documentSnapshot['รูปผัก']),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => _updata(documentSnapshot),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () => _delete(documentSnapshot.id),
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
