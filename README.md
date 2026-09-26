# การพัฒนาแอปพลิเคชันซื้อขายผัก กรณีศึกษา: สวนคุณคำบุญ

แอปพลิเคชันซื้อขายผักบนมือถือที่พัฒนาด้วย Flutter เพื่อขยายช่องทางการตลาดให้สวนคุณคำบุญ เชื่อมต่อผู้ขายและผู้ซื้อผ่านระบบออนไลน์ ผู้ขายจัดการสินค้าและสต๊อกได้ ส่วนลูกค้าค้นหาผัก เลือกซื้อ และติดตามคำสั่งซื้อในแอปได้

> โครงงานนี้จัดทำขึ้นเพื่อการศึกษาและพัฒนาต่อยอด

## ภาพตัวอย่าง

<!-- TODO: เพิ่มภาพหน้าจอแอปไว้ใน docs/images/ แล้วแทนที่ placeholder ด้านล่าง -->

| หน้าร้านค้า | รายละเอียดสินค้า | โปรไฟล์ผู้ใช้ |
| --- | --- | --- |
| เพิ่มภาพหน้าจอหน้าร้านค้า | เพิ่มภาพหน้าจอรายละเอียดสินค้า | เพิ่มภาพหน้าจอโปรไฟล์ |

## ฟีเจอร์หลัก

- สมัครสมาชิกและเข้าสู่ระบบด้วย Firebase Authentication
- แสดงรายการผัก รายละเอียดสินค้า ราคา และโปรโมชั่น
- เลือกสินค้าและจัดการตะกร้าสินค้า
- สร้างและดูรายการคำสั่งซื้อ
- หน้าจอผู้ดูแลสำหรับจัดการสินค้า โปรโมชั่น และคำสั่งซื้อ
- แสดงข้อมูลสถิติการขายสำหรับผู้ดูแล
- ใช้ Google Maps และ Places เพื่อค้นหา/เลือกตำแหน่งที่อยู่
- เลือกรูปโปรไฟล์จากแกลเลอรีหรือกล้อง และบันทึกรูปไว้ในเครื่องของผู้ใช้
- รองรับการรับการแจ้งเตือนผ่าน Firebase Cloud Messaging

> หมายเหตุ: รูปโปรไฟล์ที่บันทึกในเครื่องจะไม่ซิงก์ไปอุปกรณ์อื่น และอาจหายเมื่อถอนการติดตั้งหรือล้างข้อมูลแอป ส่วนการส่ง Push Notification จากหน้าผู้ดูแลต้องตั้งค่า Firebase Cloud Function ฝั่ง server ก่อน

## เทคโนโลยีที่ใช้

- **Flutter / Dart** — แอปพลิเคชันมือถือ
- **Firebase Authentication** — ยืนยันตัวตนผู้ใช้
- **Cloud Firestore** — ข้อมูลสมาชิก สินค้า โปรโมชั่น และคำสั่งซื้อ
- **Firebase Storage** — จัดเก็บไฟล์ที่แอปส่วนอื่นใช้งาน เช่น รูปสินค้า/โปรโมชั่น
- **Firebase Cloud Messaging** — รับ Push Notification
- **Google Maps Platform** — แผนที่และค้นหาสถานที่

## เริ่มต้นใช้งาน

### สิ่งที่ต้องติดตั้ง

- Flutter SDK และ Dart SDK ตามข้อกำหนดใน `pubspec.yaml`
- Android Studio พร้อม Android SDK และ Android Emulator หรืออุปกรณ์ Android
- Firebase CLI และ FlutterFire CLI
- Google Maps API key ที่เปิดใช้ API และจำกัดสิทธิ์สำหรับแอปนี้แล้ว

### 1. Clone โปรเจกต์และติดตั้งแพ็กเกจ

```bash
git clone <URL-ของ-repository>
cd <โฟลเดอร์โปรเจกต์>
flutter pub get
```

### 2. ตั้งค่า Firebase ของคุณ

สร้าง Firebase project และตั้งค่า Authentication, Cloud Firestore, Storage และ Cloud Messaging ตามฟีเจอร์ที่ต้องการ จากนั้นเชื่อมแอปกับ Firebase ด้วย FlutterFire CLI:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

เลือก Android application และ Firebase project ของคุณ คำสั่งจะสร้างหรือปรับ `lib/firebase_options.dart` และไฟล์ native configuration ที่เกี่ยวข้อง ไฟล์ Firebase native config เช่น `google-services.json` เป็นไฟล์เฉพาะโปรเจกต์และถูกยกเว้นจาก Git

ก่อนใช้งานจริง ให้ตรวจ Firebase Security Rules สำหรับ Firestore และ Storage โดยจำกัดสิทธิ์ตามผู้ใช้และบทบาท ห้ามเปิดอ่าน/เขียนข้อมูลทั้งหมดโดยไม่ตรวจสอบสิทธิ์

### 3. ตั้งค่า Google Maps API key

Flutter ไม่มี `.env` ที่ซ่อนค่าไว้ในแอปที่ติดตั้งบนอุปกรณ์ ค่า `--dart-define` ช่วยแยกค่าจากซอร์สโค้ด แต่ key ที่ใช้ใน mobile app ยังอาจถูกดึงออกจากตัวแอปได้ ให้ใช้ key ที่จำกัด API และ application/package แล้วเท่านั้น

คัดลอก `.env.example` เป็น `.env.json` ที่โฟลเดอร์เดียวกับ `pubspec.yaml` แล้วใส่ key สำหรับ Places API:

```json
{
  "GOOGLE_MAPS_API_KEY": "ใส่-key-ของคุณ"
}
```

เพิ่ม key สำหรับ Google Maps SDK ใน `android/local.properties` ซึ่ง Flutter สร้างไว้ในเครื่อง โดยคงบรรทัดอื่นในไฟล์ไว้:

```properties
MAPS_API_KEY=ใส่-key-ของคุณ
```

ไฟล์ `.env.json` และ `android/local.properties` ถูกยกเว้นจาก Git แล้ว ห้าม commit key ที่ใช้งานจริง

### 4. รันแอปบน Android

ตรวจสอบอุปกรณ์ที่ Flutter มองเห็น:

```bash
flutter devices
```

จากนั้นแทน `<device-id>` ด้วย ID ของ Android Emulator หรืออุปกรณ์ที่แสดง:

```bash
flutter run -d <device-id> --dart-define-from-file=.env.json
```

ตัวอย่าง build APK:

```bash
flutter build apk --dart-define-from-file=.env.json
```

## ตัวอย่างการใช้งาน

1. เปิดแอปและสมัครสมาชิกหรือเข้าสู่ระบบ
2. เลือกดูรายการผักและโปรโมชั่นจากหน้าร้านค้า
3. เปิดรายละเอียดสินค้า เลือกจำนวน แล้วเพิ่มลงตะกร้า
4. ตรวจสอบตะกร้าและดำเนินการสร้างคำสั่งซื้อ
5. ผู้ดูแลเข้าสู่ระบบเพื่อจัดการสินค้า โปรโมชั่น และตรวจสอบคำสั่งซื้อ

ชื่อเมนูและขั้นตอนอาจแตกต่างตามการตั้งค่าของ Firebase project และเวอร์ชันของแอป

## การร่วมพัฒนา

ยินดีรับข้อเสนอแนะและการพัฒนาต่อยอด โดยแนะนำให้:

1. Fork repository และสร้าง branch สำหรับการเปลี่ยนแปลง
2. อธิบายปัญหาหรือฟีเจอร์ที่ต้องการปรับปรุงให้ชัดเจน
3. ตรวจรูปแบบโค้ดและวิเคราะห์โปรเจกต์ก่อนส่ง Pull Request

```bash
dart format lib
flutter analyze
```

ห้ามแนบ API key, service account JSON, token, keystore หรือข้อมูลส่วนบุคคลลงใน issue, commit หรือ Pull Request

## ความปลอดภัยและข้อมูลลับ

- ห้ามใส่ FCM server credential หรือ service account key ไว้ในแอป Flutter; การส่ง Push Notification ต้องทำผ่าน Cloud Functions หรือ trusted server
- Firebase API key ใน `firebase_options.dart` เป็น client configuration ไม่ใช่กลไกป้องกันข้อมูล ต้องตั้ง Security Rules และจำกัด key สำหรับ Google APIs ที่เกี่ยวข้อง
- หาก key เคยถูก commit ให้เพิกถอน/หมุนเวียน key ก่อน และลบออกจากประวัติ Git ก่อนเผยแพร่ repository เป็นสาธารณะ

## License

ขณะนี้ repository ยังไม่มีไฟล์ `LICENSE` จึงยังไม่ได้กำหนดเงื่อนไขการอนุญาตให้นำโค้ดไปใช้หรือเผยแพร่ต่อ หากต้องการเปิดให้บุคคลอื่นนำไปใช้ โปรดเลือก License ที่เหมาะสมและเพิ่มไฟล์ `LICENSE` ก่อนเผยแพร่
