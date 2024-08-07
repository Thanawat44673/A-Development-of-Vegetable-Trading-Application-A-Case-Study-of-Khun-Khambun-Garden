import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Edit_Promotion_admin extends StatefulWidget {
  @override
  _Edit_Promotion_adminState createState() => _Edit_Promotion_adminState();
}

class _Edit_Promotion_adminState extends State<Edit_Promotion_admin> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String imageUrl = '';

  final usersCollection =
      FirebaseFirestore.instance.collection("Promotion_img");

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

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
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
                        } catch (error) {}
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
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
                        String fileName =
                            DateTime.now().microsecondsSinceEpoch.toString();
                        Reference ref = FirebaseStorage.instance.ref();
                        Reference referenceDireImages = ref.child('images');

                        Reference referenceImageaToUpload =
                            referenceDireImages.child(fileName);

                        try {
                          await referenceImageaToUpload
                              .putFile(File(file!.path));

                          imageUrl =
                              await referenceImageaToUpload.getDownloadURL();
                          Fluttertoast.showToast(
                              msg: "อัพโหลดรูปโปรไฟล์เรียบร้อยแล้ว",
                              gravity: ToastGravity.BOTTOM);
                        } catch (error) {}
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
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
  }

  final CollectionReference _Vegetable =
      FirebaseFirestore.instance.collection("Promotion_img");

  Future<void> _updata([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {}
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
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
                    "แก้ไขรูปภาพโปรโมชั่น",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Stack(children: [
                  Center(
                    child: IconButton(
                      onPressed: () {
                        showImagePickerOption(context);
                      },
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          if (imageUrl != null) {
                            FirebaseFirestore.instance
                                .collection("Promotion_img")
                                .doc(documentSnapshot?.id)
                                .update({'รูป': imageUrl});

                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('แก้ไข')),
                    SizedBox(
                      width: 10,
                    ),
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //ชื่อมุมขวาบน
        title: Text('แก้ไขภาพโปรโมชั่น'),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/number1.jpg'), // Replace this with your image asset
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
                      color: Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          documentSnapshot['เลขที่รูป'].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(documentSnapshot['รูป']),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => _updata(documentSnapshot),
                                icon: const Icon(Icons.edit),
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
    );
  }
}
