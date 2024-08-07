import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  //กำหนด ข้อมูลหน้ากรอก
  final String? id;
  final String Name;
  final String Lastname;
  final String Email;
  final String Password;
  final String? Trypassword;
  final String Number;
  final String Address;

  const UserModel({
    this.id,
    required this.Name,
    required this.Lastname,
    required this.Email,
    required this.Password,
    this.Trypassword,
    required this.Number,
    required this.Address,
  }); // ชี้ไปยัง

  toJson() {
    return {
      "ชื่อ": Name,
      "นามสกุล": Lastname,
      "อีเมล": Email,
      "รหัสผ่าน": Password,
      "เบอร์โทรศัพท์": Number,
      "ที่อยู่": Address,
    };
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel(
        id: document.id,
        Name: data["ชื่อ"],
        Lastname: data["นามสกุล"],
        Email: data["อีเมล"],
        Password: data["รหัสผ่าน"],
        Number: data["เบอร์โทรศัพท์"],
        Address: data["ที่อยู่"]);
  }
}
