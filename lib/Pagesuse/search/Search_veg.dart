import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appshop1/Widgets/ProductDetailScreen.dart';

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

final currentUser = FirebaseAuth.instance.currentUser!;

class _SearchFormState extends State<SearchForm> {
  void _openProductDetailPage(
      BuildContext context, DocumentSnapshot productDocument) {
    // สร้างหน้าต่างใหม่เพื่อแสดงรายละเอียดของสินค้า
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          productDocument: productDocument,
          veggie: productDocument,
          user: currentUser,
        ),
      ),
    );
  }

  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  bool _isSearching = false;

  void _searchProducts(String query) async {
    setState(() {
      _isSearching = true;
    });

    // Fetch all products
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Vegetable').get();

    // Filter products based on query
    List<DocumentSnapshot> filteredProducts = snapshot.docs.where((doc) {
      String productName = doc['ชื่อผัก'].toString().toLowerCase();
      return productName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _searchResults = filteredProducts;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ค้นหาผัก'),
        backgroundColor: const Color.fromARGB(255, 216, 255, 171),
      ),
      body: Container(
        //alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/number1.jpg'), // Replace this with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ]),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 200,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                                hintText: "ค้นหาสินค้าได้ตรงนี้",
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 90),
                        child: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            _searchProducts(_searchController.text);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            _isSearching
                ? CircularProgressIndicator()
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          'ไม่พบสินค้า',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            var vegetable = _searchResults[index];
                            return GestureDetector(
                              onTap: () {
                                _openProductDetailPage(context, vegetable);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 50, right: 50),
                                child: Card(
                                  child: Column(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 2,
                                        child: Container(
                                          color: Colors.white,
                                          child: Image.network(
                                              vegetable['รูปผัก']),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        vegetable['ชื่อผัก'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        '${vegetable['ราคาผัก']} บาท/กก.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
