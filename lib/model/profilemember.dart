class Profile {
  //กำหนด ข้อมูลหน้ากรอก
  String? Name;
  String? Lastname;
  String? Email;
  String? Password;
  String? Trypassword;
  String? Number;
  String? Address;
  String? Image;

  Profile({
    required this.Name,
    required this.Lastname,
    required this.Email,
    required this.Password,
    required this.Trypassword,
    required this.Number,
    required this.Address,
    required this.Image,
  }); // ชี้ไปยัง
}
