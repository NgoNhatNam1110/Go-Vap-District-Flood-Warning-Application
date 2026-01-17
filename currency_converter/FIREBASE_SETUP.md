# 🚀 Hướng Dẫn Setup Firebase Cho Ứng Dụng

## 📋 Các Bước Thực Hiện

### Step 1: Tạo Firebase Project

1. Truy cập: https://console.firebase.google.com
2. Nhấp vào **"Create a project"**
3. Nhập tên project: `flood-warning-app` (hoặc tên khác)
4. Chọn **"Use Google Analytics"** (tùy chọn)
5. Nhấp **"Create Project"**

### Step 2: Đăng Ký Ứng Dụng Flutter

#### Android:
1. Trong Firebase Console, nhấp **"Add app"** → chọn Android
2. Nhập Package name: `com.example.currency_converter`
3. Nhập SHA-1 fingerprint (lấy từ terminal):
   ```bash
   # Windows
   cd android
   ./gradlew signingReport
   
   # macOS/Linux
   cd android
   ./gradlew signingReport
   ```
   Sao chép SHA1 từ output
4. Tải `google-services.json`
5. Đặt vào: `android/app/google-services.json`

#### iOS:
1. Nhấp **"Add app"** → chọn iOS
2. Nhập Bundle ID: `com.example.currencyConverter`
3. Tải `GoogleService-Info.plist`
4. Đặt vào: `ios/Runner/GoogleService-Info.plist`
5. Sử dụng Xcode để thêm file (drag & drop hoặc Add Files)

### Step 3: Cấu Hình Firebase CLI

```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Hoặc sử dụng Flutter Fire
flutter pub global activate flutterfire_cli

# Cấu hình tự động (nên dùng cách này)
flutterfire configure

# Hoặc cấu hình thủ công (nếu flutterfire không hoạt động)
```

### Step 4: Kích Hoạt Services Trong Firebase

1. **Authentication**:
   - Console → Authentication → Sign-in method
   - Bật "Email/Password"
   - Nhấp "Save"

2. **Firestore Database**:
   - Console → Firestore Database → Create database
   - Chọn "Start in test mode" (tạm thời)
   - Chọn region: `asia-southeast1` (Đông Nam Á - gần Việt Nam)

3. **Realtime Database** (Tùy chọn):
   - Console → Realtime Database → Create Database
   - Chọn cùng region

### Step 5: Cấu Hình Firestore Rules

Trong Firebase Console:
1. Truy cập: Firestore Database → Rules
2. Thay thế nội dung bằng:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - chỉ user được sửa của riêng mình
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }
    
    // Flood alerts - tất cả người dùng có thể đọc
    match /flood_alerts/{alertId} {
      allow read: if request.auth != null;
      allow create: if request.auth.token.admin == true;
      allow update: if request.auth.token.admin == true;
      allow delete: if request.auth.token.admin == true;
    }
  }
}
```

3. Nhấp "Publish"

### Step 6: Lấy Firebase Configuration

1. Console → Project Settings (⚙️ icon)
2. Kéo xuống "Your apps"
3. Sao chép thông tin API Key cho từng platform

### Step 7: Cập Nhật firebase_options.dart

File `lib/firebase_options.dart` đã được tạo sẵn. Cập nhật các giá trị:

```dart
// Ví dụ cho Android
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', // Từ Firebase Console
  appId: '1:123456789:android:abcdef1234567890',
  messagingSenderId: '123456789',
  projectId: 'flood-warning-app',
  databaseURL: 'https://flood-warning-app.firebaseio.com',
);
```

**Lấy từ Firebase Console:**
- Console → Project Settings → General tab
- Tìm phần "Your apps" → chọn ứng dụng
- Copy các giá trị tương ứng

### Step 8: Kiểm Tra Cài Đặt

```bash
# 1. Tải dependencies
flutter pub get

# 2. Kiểm tra lỗi
flutter doctor -v

# 3. Chạy ứng dụng
flutter run

# 4. Test đăng ký tài khoản
# - Nhấp "Đăng ký ngay"
# - Nhập email: test@example.com
# - Nhập mật khẩu: 123456
# - Confirm password: 123456
# - Nhấp "Đăng ký"
```

## ✅ Kiểm Tra Hoạt Động

### 1. Kiểm Tra Firestore

```bash
# Trong Firebase Console:
# Firestore Database → Collection "users"
# Bạn sẽ thấy tài liệu mới với email đã đăng ký
```

### 2. Kiểm Tra Authentication

```bash
# Firebase Console → Authentication → Users
# Sẽ thấy người dùng vừa đăng ký
```

### 3. Test Real-time Update

```bash
# Mở ứng dụng 2 lần
# Cập nhật hồ sơ trong tab 1
# Kiểm tra nếu tab 2 tự động cập nhật
```

## 🐛 Khắc Phục Lỗi Thường Gặp

### Lỗi 1: "DefaultFirebaseOptions is not initialized"
**Giải pháp**:
```bash
# Chạy lại
flutterfire configure

# Hoặc cập nhật firebase_options.dart thủ công
```

### Lỗi 2: "PERMISSION_DENIED" khi đăng ký
**Giải pháp**:
```javascript
// Firestore Rules - cho phép create user
allow create: if request.auth.uid == userId;
```

### Lỗi 3: Google Maps không hiển thị
**Android**:
1. Tạo API Key từ Google Cloud Console
2. Thêm vào `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />
```

**iOS**:
1. Thêm vào `ios/Runner/Info.plist`:
```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
<key>GoogleMapsApiKey</key>
<string>YOUR_API_KEY_HERE</string>
```

### Lỗi 4: App crashes khi khởi động
**Giải pháp**:
```bash
# Xóa build artifacts
flutter clean

# Rebuild
flutter pub get
flutter run
```

## 🔐 Security Best Practices

### 1. Protect API Keys (Production)
```dart
// ❌ KHÔNG đặt hardcoded API key trong code
const String apiKey = 'AIzaSyDxxx...'; // Sai!

// ✅ SỬ DỤNG environment variables hoặc config file
// lib/config/firebase_config.dart
```

### 2. Firestore Rules
```javascript
// ✅ ĐỦ
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// ❌ NGUY HIỂM
match /{document=**} {
  allow read, write: if true;  // Mở cho tất cả!
}
```

### 3. Password Security
- Firebase tự động hash mật khẩu
- Không bao giờ gửi plain text

## 📈 Tối Ưu Hóa Firestore

### 1. Indexing
```javascript
// Firebase tự động tạo index cho queries
// Nếu query chậm, tạo composite index tại:
// Firestore → Indexes → Create Index
```

### 2. Data Modeling
```dart
// ✅ TỐT: Dữ liệu được chuẩn hóa
Collection "users" {
  "uid123" {
    "email": "...",
    "name": "...",
    "location": { "lat": 10.77, "lon": 106.70 }
  }
}

// ❌ TỒI: Lồng sâu quá
Collection "users" {
  "alerts": [
    { "id": "1", "title": "..." },
    { "id": "2", "title": "..." }
  ]
}
```

### 3. Query Optimization
```dart
// ✅ TỐT: Specific queries
query('users')
  .where('email', '==', email)
  .limit(1)
  .get()

// ❌ TỒI: Fetch all then filter
query('users').get()  // Lấy 10000 records
  .filter(u => u.email == email)
```

## 📚 Tài Liệu Tham Khảo

- [Firebase Setup Guide](https://firebase.flutter.dev/docs/overview/)
- [Firestore Security](https://firebase.google.com/docs/firestore/security/start)
- [Flutter Firebase](https://pub.dev/packages/firebase_core)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)

## 🎯 Checklist Setup

- [ ] Tạo Firebase Project
- [ ] Đăng ký Android app
- [ ] Tải google-services.json
- [ ] Đăng ký iOS app
- [ ] Tải GoogleService-Info.plist
- [ ] Chạy `flutterfire configure`
- [ ] Kích hoạt Authentication (Email/Password)
- [ ] Tạo Firestore Database
- [ ] Cập nhật Firestore Rules
- [ ] Test đăng ký tài khoản
- [ ] Kiểm tra Firestore collections
- [ ] Setup Google Maps API Key
- [ ] Test real-time updates

---

✅ **Setup xong! Ứng dụng sẵn sàng sử dụng Firebase.**
