import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appshop1/Home/Map_Screen.dart';
import 'package:flutter_appshop1/auth/text_box.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Profile_edit_map extends StatefulWidget {
  const Profile_edit_map({super.key});

  @override
  State<Profile_edit_map> createState() => _Profile_edit_mapState();
}

class _Profile_edit_mapState extends State<Profile_edit_map> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("members");

  GoogleMapController? _mapController;
  LatLng? _savedLocation;
  Set<Marker> _markers = {};
  StreamSubscription<DocumentSnapshot>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _getSavedLocation();
    _listenForLocationUpdates();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getSavedLocation() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('members')
            .doc(user.email)
            .get();
        if (doc.exists) {
          _updateLocation(doc);
        }
      }
    } catch (e) {
      print("Failed to get saved location: $e");
    }
  }

  void _listenForLocationUpdates() {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _locationSubscription = FirebaseFirestore.instance
            .collection('members')
            .doc(user.email)
            .snapshots()
            .listen((doc) {
          if (doc.exists) {
            _updateLocation(doc);
          }
        });
      }
    } catch (e) {
      print("Failed to listen for location updates: $e");
    }
  }

  void _updateLocation(DocumentSnapshot doc) {
    String savedLocation = doc['พิกัด'];
    List<String> latLng = savedLocation.split(',');
    double latitude = double.parse(latLng[0].trim());
    double longitude = double.parse(latLng[1].trim());
    LatLng newLocation = LatLng(latitude, longitude);

    setState(() {
      _savedLocation = newLocation;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('savedLocation'),
          position: newLocation,
          infoWindow: InfoWindow(title: 'Saved Location'),
        ),
      );
    });

    _moveCameraToLocation(newLocation);
  }

  void _moveCameraToLocation(LatLng location) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 17,
          ),
        ),
      );
    }
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("แก้ไข" + field),
        content: TextField(
          autocorrect: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "กรอก $fieldใหม่",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: Text(
              'บันทึก',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
    //คำสั่งอัพโหลดข้อมูลการแก้ไข
    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขที่อยู่'),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("members")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/number1.jpg'), // Replace this with your image asset
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView(
                children: [
                  const SizedBox(height: 50),
                  MyTextBox(
                    text: userData['ที่อยู๋'],
                    sectionName: 'ที่อยู่',
                    onPressed: () => editField('ที่อยู๋'),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black87,
                          width: 2,
                        ),
                      ),
                      child: GoogleMap(
                        onMapCreated: (controller) {
                          _mapController = controller;
                          if (_savedLocation != null) {
                            _moveCameraToLocation(_savedLocation!);
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: _savedLocation ??
                              LatLng(0, 0), // Default position
                          zoom: 2,
                        ),
                        markers: _markers,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  Padding(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.black87, width: 2),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapScreen()),
                        );
                        if (result != null) {
                          setState(() {
                            //_address = result;
                            _savedLocation = result;
                            _mapController?.animateCamera(
                                CameraUpdate.newLatLng(_savedLocation!));
                          });
                          FirebaseFirestore.instance
                              .collection("members")
                              .doc(currentUser.email)
                              .update({
                            'พิกัด': _savedLocation != null
                                ? "${_savedLocation!.latitude}, ${_savedLocation!.longitude}"
                                : "",
                          });
                        }
                      },
                      child: Text('เพิ่มพิกัดใหม่ของท่าน',
                          style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
