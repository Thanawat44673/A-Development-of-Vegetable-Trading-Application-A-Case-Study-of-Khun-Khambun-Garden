import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Pagesuse_admin/edit_pageadmin/add_u_admin.dart';

class Profile_a extends StatefulWidget {
  const Profile_a({super.key});

  @override
  State<Profile_a> createState() => _Profile_aState();
}

class _Profile_aState extends State<Profile_a> {
  //final currentUser = FirebaseAuth.instance.currentUser!;

  final TextEditingController _Name = TextEditingController();
  final TextEditingController _Lastname = TextEditingController();
  final TextEditingController _Email = TextEditingController();
  final TextEditingController _Password = TextEditingController();
  final TextEditingController _Number = TextEditingController();
  final TextEditingController _Address = TextEditingController();

  String _password = '';

  bool _passwordVisible = false;
  bool _isPasswordValid = true;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _password = value;
      _isPasswordValid = value.length >= 6;
    });
  }

  final CollectionReference _Profile =
      FirebaseFirestore.instance.collection("members");

  Future<void> _updata([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _Name.text = documentSnapshot['ชื่อ'];
      _Lastname.text = documentSnapshot['นามสกุล'];
      _Email.text = documentSnapshot['อีเมล'];
      _Password.text = documentSnapshot['รหัสผ่าน'];
      _Number.text = documentSnapshot['เบอร์โทรศัพท์'];
      _Address.text = documentSnapshot['ที่อยู๋'];
    }
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
                    "แก้ไขข้อมูลสมาชิก",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextField(
                  controller: _Name,
                  decoration:
                      const InputDecoration(labelText: 'ชื่อ', hintText: ''),
                ),
                TextField(
                  controller: _Lastname,
                  decoration:
                      const InputDecoration(labelText: 'นามสกุล', hintText: ''),
                ),
                TextField(
                  controller: _Email,
                  decoration:
                      const InputDecoration(labelText: 'อีเมล', hintText: ''),
                ),
                TextField(
                  controller: _Password,
                  decoration: const InputDecoration(
                      labelText: 'รหัสผ่าน', hintText: ''),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _Number,
                  decoration: const InputDecoration(
                      labelText: 'เบอร์โทรศัพท์', hintText: ''),
                ),
                TextField(
                  controller: _Address,
                  decoration:
                      const InputDecoration(labelText: 'ที่อยู๋', hintText: ''),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String name = _Name.text;
                      final String lastname = _Lastname.text;
                      final String email = _Email.text;
                      final String password = _Password.text;
                      final String number = _Number.text;
                      final String address = _Address.text;
                      if (number != null) {
                        FirebaseFirestore.instance
                            .collection("members")
                            .doc(documentSnapshot!.id)
                            .update({
                          'ชื่อ': name,
                          'นามสกุล': lastname,
                          'อีเมล': email,
                          'รหัสผ่าน': password,
                          'เบอร์โทรศัพท์': number,
                          'ที่อยู๋': address,
                        });
                        _Name.text = '';
                        _Lastname.text = '';
                        _Email.text = '';
                        _Password.text = '';
                        _Number.text = '';
                        _Address.text = '';

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('แก้ไข'))
              ],
            ),
          );
        });
  }

  Future<void> _delete(String ProductID) async {
    FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
    FirebaseFirestore.instance.collection("members").doc(ProductID).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          stream: _Profile.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
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
                          documentSnapshot['ชื่อ'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Text(documentSnapshot['อีเมล'].toString()),
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
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Add_u_admin();
          }));
        },
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
