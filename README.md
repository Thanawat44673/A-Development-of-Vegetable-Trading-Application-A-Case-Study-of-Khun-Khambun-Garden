# แอปพลิเคชันซื้อขายผักสวนขุนคำบุ้น

แอปพลิเคชัน Flutter สำหรับซื้อขายผัก เชื่อมต่อ Firebase Authentication, Cloud Firestore, Firebase Storage และ Firebase Cloud Messaging รวมถึง Google Maps/Places API

## ข้อกำหนดเบื้องต้น

- Flutter SDK และ Dart SDK ตามเวอร์ชันที่ระบุใน `pubspec.yaml`
- Android Studio หรือเครื่องมือ Android SDK
- บัญชี Google สำหรับสร้าง Firebase project และเปิดใช้ Google Maps Platform (หากใช้แผนที่)
- Firebase CLI และ FlutterFire CLI สำหรับตั้งค่า Firebase

## เริ่มต้นใช้งานหลัง Clone

```bash
git clone <URL-ของ-repository>
cd flutter_appshop1
flutter pub get
```

ตั้งค่า Firebase project ของตนเอง แล้วสร้างไฟล์ตั้งค่าของแพลตฟอร์มผ่าน FlutterFire CLI:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

คำสั่งจะสร้าง/ปรับ `lib/firebase_options.dart` และไฟล์ native configuration ที่จำเป็น โปรเจกต์นี้ตั้งค่า Firebase สำหรับ Android ไว้ใน repository บางส่วนแล้ว แต่ผู้ที่นำไปต่อยอดควรผูกกับ Firebase project ของตนเองและตรวจสอบ Firebase rules ก่อนใช้งานจริง ส่วน `google-services.json` และ `GoogleService-Info.plist` เป็นไฟล์เฉพาะโปรเจกต์และถูกยกเว้นจาก Git

## ตั้งค่า Google Maps API Key

Flutter ไม่มีระบบ `.env` ที่ซ่อนค่าไว้ในแอปที่ติดตั้งบนเครื่องผู้ใช้ การใช้ `flutter_dotenv` หรือ `--dart-define` ช่วยแยกค่าจากซอร์สโค้ดได้ แต่ค่าที่ถูกนำไปใช้ใน mobile app ยังสามารถดึงออกจากแอปได้ จึงห้ามใส่ service account key, FCM server credential หรือ secret ที่ให้สิทธิ์สูงไว้ในแอปหรือ `.env`

สำหรับ Places API ใน Dart ให้สร้างไฟล์ `.env.json` ในรากโปรเจกต์ (ไฟล์นี้อยู่ใน `.gitignore`) เช่น:

```json
{
  "GOOGLE_MAPS_API_KEY": "ใส่_API_key_ของคุณ"
}
```

สำหรับ Google Maps SDK บน Android ให้เปิด `android/local.properties` ซึ่ง Flutter สร้างไว้ในเครื่อง แล้วเพิ่มบรรทัดนี้:

```properties
MAPS_API_KEY=ใส่_API_key_ของคุณ
```

รันแอปโดยส่งค่าจากไฟล์ JSON:

```bash
flutter run --dart-define-from-file=.env.json
```

จำกัด API key ใน Google Cloud Console ให้ใช้ได้เฉพาะ Android app/package และ API ที่จำเป็น เช่น Maps SDK for Android และ Places API พร้อมตั้ง quota และ billing alert ตามเหมาะสม หากเผยแพร่แอปจริงให้แยก key ตามแพลตฟอร์มและ environment

## การส่ง Push Notification

การส่งข้อความผ่าน FCM HTTP v1 ต้องทำจาก backend ที่เชื่อถือได้ เช่น Firebase Cloud Functions โดยให้ service account อยู่ใน Secret Manager/สภาพแวดล้อม backend และตรวจสิทธิ์ผู้ดูแลก่อนส่ง โค้ดในแอปนี้ไม่เก็บ service account key และปุ่มส่งข้อความจะแจ้งให้ตั้งค่า Cloud Function ก่อน ฟังก์ชันดังกล่าวต้องพัฒนาและ deploy ใน Firebase project ของผู้ดูแลก่อนเปิดใช้งานจริง

## ตรวจสอบและสร้างแอป

```bash
flutter analyze
flutter run --dart-define-from-file=.env.json
flutter build apk --dart-define-from-file=.env.json
```

## การจัดการข้อมูลลับ

- ห้าม commit `.env.json`, `android/local.properties`, service account JSON, keystore หรือ credential ใด ๆ
- `.env.example` เป็นเพียงตัวอย่างสำหรับคัดลอก ห้ามใส่ key ที่ใช้งานจริงลงไป
- Firebase API key ใน `firebase_options.dart` เป็น client configuration ที่แอปจำเป็นต้องใช้และไม่ใช่การป้องกันฐานข้อมูล ให้ตั้ง Firebase Security Rules, จำกัด API key และเปิด App Check ตามความเหมาะสม
- หากเคย push key หรือ credential ขึ้น GitHub แล้ว ให้ถือว่าถูกเปิดเผย แม้ลบจากไฟล์หรือประวัติ commit แล้วก็ตาม ให้เพิกถอน/หมุนเวียน key ที่เกี่ยวข้อง ตรวจสอบการใช้งานย้อนหลัง และสร้าง credential ใหม่ก่อนดำเนินงานต่อ

## เทคโนโลยีหลัก

- Flutter / Dart
- Firebase Authentication, Cloud Firestore, Firebase Storage, Firebase Cloud Messaging
- Google Maps / Places API

