import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  TextEditingController _addressController = TextEditingController();
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  List<dynamic> _placeSuggestions = [];
  static const String _googleApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');

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

  Future<void> _searchPlaces(String query) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&language=th';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        _placeSuggestions = result['predictions'];
      });
    } else {
      Fluttertoast.showToast(
        msg: 'ไม่สามารถดึงข้อมูลได้',
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final lat = result['result']['geometry']['location']['lat'];
      final lng = result['result']['geometry']['location']['lng'];

      setState(() {
        _selectedLocation = LatLng(lat, lng);
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId("searchedLocation"),
            position: _selectedLocation!,
          ),
        );
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedLocation!,
              zoom: 17,
            ),
          ),
        );
      });
    } else {
      Fluttertoast.showToast(
        msg: 'ไม่สามารถดึงรายละเอียดสถานที่ได้',
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // แสดงแผนที่ Google Map
          GoogleMap(
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

          // วางช่องค้นหาและปุ่มย้อนกลับบนแผนที่
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.black,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: 'ค้นหาตำแหน่งที่อยู่',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _searchPlaces(value);
                              } else {
                                setState(() {
                                  _placeSuggestions.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // แสดงรายการตำแหน่งที่แนะนำ
                if (_placeSuggestions.isNotEmpty)
                  Container(
                    height: 200, // ความสูงของกล่องรายการ
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: _placeSuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_placeSuggestions[index]['description']),
                          onTap: () {
                            _getPlaceDetails(
                                _placeSuggestions[index]['place_id']);
                            _addressController.clear();
                            setState(() {
                              _placeSuggestions.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // วางช่องค้นหาและปุ่มย้อนกลับบนแผนที่
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Column(
              children: [
                // ช่องค้นหาและรายการแนะนำ
              ],
            ),
          ),

          // ปุ่มตำแหน่งปัจจุบัน
          Positioned(
            bottom: 80, // ปรับตำแหน่งให้อยู่ด้านล่างของหน้าจอ
            left: 50,
            right: 50,
            child: SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black87, width: 2),
                    borderRadius: BorderRadius.circular(0),
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
          ),

          // ปุ่มเพิ่มที่อยู่ใหม่
          Positioned(
            bottom: 20, // วางปุ่มที่ด้านล่างสุด
            left: 50,
            right: 50,
            child: SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black87, width: 2),
                    borderRadius: BorderRadius.circular(0),
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
          ),
        ],
      ),
    );
  }
}
