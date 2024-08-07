import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  TextEditingController _addressController = TextEditingController();
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: MarkerId("currentLocation"),
            position: _selectedLocation!,
          ),
        );
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _selectedLocation!,
                zoom: 17,
              ),
            ),
          );
        }
      });
    } catch (e) {
      print("Failed to get current location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: 'ค้นหาตำแหน่งที่อยู่',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    String address = _addressController.text;
                    try {
                      List<Location> locations =
                          await locationFromAddress(address);
                      if (locations.isNotEmpty) {
                        Location location = locations.first;
                        setState(() {
                          _selectedLocation =
                              LatLng(location.latitude, location.longitude);
                          _markers.clear(); // ลบปักหมุดเก่าออก
                          _markers.add(
                            Marker(
                              markerId: MarkerId("searchedLocation"),
                              position: _selectedLocation!,
                            ),
                          );
                        });
                        _mapController!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _selectedLocation!,
                              zoom: 17,
                            ),
                          ),
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: 'ไม่พบที่อยู่',
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: 'เกิดข้อผิดพลาดในการค้นหาที่อยู่',
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                  if (_selectedLocation != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _selectedLocation!,
                          zoom: 17,
                        ),
                      ),
                    );
                  }
                });
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0), // Default position
                zoom: 2,
              ),
              markers: _markers,
              onTap: (position) {
                setState(() {
                  _markers.clear();
                  _markers.add(
                    Marker(
                      markerId: MarkerId(position.toString()),
                      position: position,
                    ),
                  );
                  _selectedLocation = position;
                });
              },
            ),
          ),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  // กำหนดรูปร่างของปุ่ม
                  side: BorderSide(
                      color: Colors.black87, width: 2), // กำหนดเส้นขอบของปุ่ม
                  borderRadius: BorderRadius.circular(
                      0), // กำหนดรัศมีของมุมเป็น 0 จะทำให้มีรูปร่างเป็นสี่เหลี่ยม
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                _markers.clear();
                _getCurrentLocation();
              },
              child: Text('ตำแหน่งปัจจุบัน', style: TextStyle(fontSize: 20)),
            ),
          ),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  // กำหนดรูปร่างของปุ่ม
                  side: BorderSide(
                      color: Colors.black87, width: 2), // กำหนดเส้นขอบของปุ่ม
                  borderRadius: BorderRadius.circular(
                      0), // กำหนดรัศมีของมุมเป็น 0 จะทำให้มีรูปร่างเป็นสี่เหลี่ยม
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
              child: Text('เพิ่มที่อยู่ใหม่', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}
