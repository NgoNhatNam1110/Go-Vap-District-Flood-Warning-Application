# Ứng Dụng Cảnh Báo Lũ Lụt Gò Vấp 🌊

Ứng dụng Flutter cảnh báo lũ lụt real-time cho khu vực Gò Vấp, Hồ Chí Minh.

## 📋 Mục Lục

- [Kiến Trúc](#kiến-trúc)
- [Cài Đặt](#cài-đặt)
- [Cấu Hình Firebase](#cấu-hình-firebase)
- [Các Tính Năng](#các-tính-năng)
- [Cấu Trúc Thư Mục](#cấu-trúc-thư-mục)
- [Best Practices](#best-practices)
- [Tối Ưu Hóa](#tối-ưu-hóa)

## 🏗️ Kiến Trúc

### Mô Hình 3 Lớp (3-Tier Architecture)

```
┌─────────────────────────────────────────┐
│   PRESENTATION LAYER (UI)               │
│  - Pages, Widgets, Navigation           │
│  - Xử lý UI Logic                       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│   BUSINESS LAYER (Business Logic)       │
│  - Controllers, Providers               │
│  - Business Rules, Validation           │
│  - State Management                     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│   DATA LAYER (Database & API)           │
│  - Models, Repositories                 │
│  - Firebase Services                    │
│  - Data Persistence                     │
└─────────────────────────────────────────┘
```

### OOP Principles Được Áp Dụng

- **Encapsulation**: Dữ liệu được ẩn, chỉ expose các method cần thiết
- **Inheritance**: Tái sử dụng code qua inheritance
- **Polymorphism**: Flexibility thông qua abstract classes
- **Abstraction**: Repository pattern trừu tượng hóa data sources

### Design Patterns

- **Singleton**: Firebase Services, Service Locator
- **Repository**: Trừu tượng hóa data access
- **Dependency Injection**: GetIt service locator
- **MVC/MVVM**: Controller-based state management

## 🚀 Cài Đặt

### Yêu Cầu Hệ Thống

- Flutter >= 3.10.4
- Dart >= 3.10.4
- Android SDK 21+ hoặc iOS 11+
- Firebase Project

### Các Bước Cài Đặt

```bash
# 1. Clone dự án
git clone <repo-url>
cd currency_converter

# 2. Cài đặt dependencies
flutter pub get

# 3. Cấu hình Firebase (xem phần dưới)
flutterfire configure

# 4. Chạy ứng dụng
flutter run
```

## 🔥 Cấu Hình Firebase

### Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Tạo project mới
3. Bật Firestore Database và Authentication

### Bước 2: Đăng Ký Ứng Dụng

```bash
# Chạy lệnh sau (sẽ tự động cấu hình)
flutterfire configure --platforms=android,ios,web,windows,macos
```

Hoặc cấu hình thủ công:

#### Android (google-services.json)
```bash
# Tải từ Firebase Console → Project Settings
# Đặt vào: android/app/google-services.json
```

#### iOS (GoogleService-Info.plist)
```bash
# Tải từ Firebase Console → Project Settings
# Đặt vào: ios/Runner/GoogleService-Info.plist
```

### Bước 3: Cập Nhật firebase_options.dart

Sau khi chạy `flutterfire configure`, file sẽ được tự động generate.

Nếu cấu hình thủ công, hãy cập nhật:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_GCP_PROJECT_NUMBER',
  projectId: 'your-firebase-project-id',
  databaseURL: 'https://your-project.firebaseio.com',
);
```

### Bước 4: Cấu Hình Firestore Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      allow create: if request.auth.uid != null;
    }
    
    // Flood alerts collection
    match /flood_alerts/{alertId} {
      allow read: if request.auth.uid != null;
      allow create, update: if request.auth.token.admin == true;
      allow delete: if request.auth.token.admin == true;
    }
  }
}
```

### Bước 5: Cấu Hình Authentication

1. Truy cập Firebase Console → Authentication → Sign-in method
2. Bật "Email/Password"
3. Tùy chọn: Bật "Google Sign-In"

## 📱 Các Tính Năng

### 1. Xác Thực (Authentication)
- ✅ Đăng ký tài khoản
- ✅ Đăng nhập
- ✅ Đăng xuất
- 🔄 Quên mật khẩu (TODO)
- 🔄 Email verification (TODO)

### 2. Bản Đồ (Map)
- ✅ Hiển thị Google Map
- ✅ Hiển thị cảnh báo lũ lụt theo vị trí
- ✅ Zoom và navigate bản đồ
- 🔄 Real-time location tracking (TODO)
- 🔄 Geofencing alerts (TODO)

### 3. Cảnh Báo Lũ Lụt (Flood Alerts)
- ✅ Lấy danh sách cảnh báo
- ✅ Lọc theo mức độ
- ✅ Sắp xếp theo thời gian/mức độ
- ✅ Real-time updates (Stream)
- 🔄 Lọc theo vị trí (cần tối ưu)

### 4. Hồ Sơ Người Dùng (Profile)
- 🔄 Hiển thị thông tin cá nhân (TODO)
- 🔄 Cập nhật hồ sơ (TODO)
- 🔄 Lịch sử cảnh báo (TODO)

## 📂 Cấu Trúc Thư Mục

```
lib/
├── main.dart                    # Entry point
├── firebase_options.dart        # Firebase configuration
│
├── core/
│   └── service_locator.dart    # Dependency Injection setup
│
├── data/                        # Data Layer
│   ├── models/
│   │   ├── user_model.dart     # User data model
│   │   └── flood_alert_model.dart
│   ├── services/
│   │   ├── firebase_auth_service.dart    # Firebase Auth
│   │   ├── firestore_user_service.dart   # Firestore Users
│   │   └── firestore_flood_alert_service.dart
│   └── repositories/
│       ├── auth_repository.dart          # Auth abstraction
│       └── flood_alert_repository.dart
│
├── business/                    # Business Layer
│   ├── controllers/
│   │   ├── auth_controller.dart         # Auth logic
│   │   └── flood_alert_controller.dart  # Alert logic
│   └── providers/              # (TODO) Provider-based state management
│
├── presentation/               # Presentation Layer
│   ├── pages/
│   │   └── home_page.dart      # Home page (re-export)
│   └── widgets/
│       └── common_widgets.dart  # Reusable widgets
│
├── pages/                      # Old structure (keep for compatibility)
│   ├── authen.dart             # Authentication page (refactored)
│   ├── map.dart                # HomePage (refactored)
│   └── profile.dart
│
└── fonts/                      # Custom fonts
```

## 💡 Best Practices Được Áp Dụng

### 1. Clean Code
- ✅ Tên biến, function rõ ràng
- ✅ Single Responsibility Principle (SRP)
- ✅ Comments và documentation
- ✅ Consistent naming conventions

### 2. Quản Lý Tài Nguyên
- ✅ Dispose Controllers khi không dùng
- ✅ Unsubscribe Streams để tránh memory leaks
- ✅ Singleton pattern cho services
- ✅ Proper error handling

### 3. Bảo Mật
- ✅ Firebase Rules kiểm soát truy cập
- ✅ Input validation
- ✅ Password hashing (Firebase)
- ✅ UID-based authorization

### 4. Tái Sử Dụng Code
- ✅ Common Widgets (CustomTextField, CustomButton, etc.)
- ✅ Repository Pattern
- ✅ Service Locator
- ✅ Inheritance và composition

## ⚡ Tối Ưu Hóa

### Real-Time Performance

#### 1. Stream Subscription Management
```dart
// ✅ ĐÚNG: Unsubscribe khi dispose
Stream<List<FloodAlertModel>> _alertStream;

@override
void dispose() {
  _alertStream.listen(...).cancel(); // Cancel subscription
  super.dispose();
}

// ❌ SAI: Memory leak nếu không cancel
```

#### 2. Lazy Loading
```dart
// ✅ Chỉ load khi cần thiết
Future<void> loadAlertsNearby({required double lat, required double lon}) async {
  // Load chỉ khi người dùng cần
}
```

#### 3. Caching
```dart
// TODO: Implement local caching
// - Provider package cho state management
// - Hive hoặc SharedPreferences cho local storage
```

#### 4. Query Optimization
```dart
// ✅ Chỉ lấy dữ liệu cần thiết
await _firestore
    .collection('flood_alerts')
    .where('isActive', isEqualTo: true)
    .limit(50)  // Limit results
    .get();
```

### Geospatial Query Optimization

**Hiện Tại**: Lấy tất cả alerts rồi filter (không hiệu quả)

```dart
// Current implementation (O(n) complexity)
Future<List<FloodAlertModel>> getAlertsNearby(...) async {
  final alerts = await getAllAlerts();  // Fetch all
  return alerts.where((a) => distance <= radius).toList();
}
```

**Giải Pháp Tối Ưu**:

**Option 1: Geohashing (Firestore)**
```dart
// Store geohash with each alert
// Query by geohash prefix
// Library: geoflutterfire hoặc geo_hash
```

**Option 2: GeoFirestore**
```dart
// Specialized library for geospatial queries
// npm install geofirestore (Node.js backend)
```

**Option 3: PostGIS Backend** (Khuyến nghị)
```dart
// Sử dụng PostgreSQL + PostGIS
// Query: SELECT * FROM alerts 
//        WHERE ST_DWithin(location, user_location, 5000)
// Hiệu quả tối đa cho geospatial queries
```

### Memory Management

```dart
// ✅ Sử dụng Singleton để tiết kiệm memory
final authService = FirebaseAuthService();  // Chỉ 1 instance

// ❌ Tránh tạo nhiều instance
final service1 = FirebaseAuthService();
final service2 = FirebaseAuthService();  // Lãng phí memory
```

## 📊 Thống Kê Ứng Dụng

- **Total Lines of Code**: ~1500+ (excluding comments)
- **Reusable Widgets**: 5 (CustomTextField, CustomButton, ErrorMessage, Loading, EmptyState)
- **Models**: 2 (UserModel, FloodAlertModel)
- **Services**: 3 (FirebaseAuth, FirestoreUser, FirestoreFloodAlert)
- **Repositories**: 2 (AuthRepository, FloodAlertRepository)
- **Controllers**: 2 (AuthController, FloodAlertController)

## 🔧 Troubleshooting

### 1. Firebase Initialization Error
```
Error: DefaultFirebaseOptions.currentPlatform is not initialized
```
**Giải pháp**: Chạy `flutterfire configure` hoặc cập nhật firebase_options.dart

### 2. Google Map Error
```
Error: Could not find Map widget
```
**Giải pháp**: 
- Android: Thêm Google Maps API key vào AndroidManifest.xml
- iOS: Thêm vào GoogleService-Info.plist

### 3. Firestore Permission Denied
```
Error: PERMISSION_DENIED: Missing or insufficient permissions
```
**Giải pháp**: Cập nhật Firestore Rules (xem phần Firebase Setup)

## 📚 Tài Liệu Tham Khảo

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Integration](https://firebase.flutter.dev)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [GetIt Service Locator](https://pub.dev/packages/get_it)

## 📝 License

MIT License

## 👨‍💻 Author

Tên Tác Giả

## 🤝 Contributing

Mọi đóng góp đều được hoan nghênh!

1. Fork dự án
2. Tạo branch feature (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request
