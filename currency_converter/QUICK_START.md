# ⚡ Quick Start Guide - 5 Phút Đưa Ứng Dụng Chạy

## 1️⃣ Cài Đặt Dependencies (2 phút)

```bash
cd currency_converter

# Tải tất cả packages
flutter pub get

# Kiểm tra setup
flutter doctor -v
```

## 2️⃣ Setup Firebase (2 phút)

### Option A: Automatic (Recommended)
```bash
# Cài flutterfire_cli
flutter pub global activate flutterfire_cli

# Configure tự động
flutterfire configure --platforms=android,ios,windows,web,macos

# Done! File firebase_options.dart được gen tự động
```

### Option B: Manual (Nếu A không được)
1. Truy cập: https://console.firebase.google.com
2. Tạo project mới (hoặc dùng existing)
3. Đăng ký Android app: lấy `google-services.json` → đặt `android/app/`
4. Đăng ký iOS app: lấy `GoogleService-Info.plist` → đặt `ios/Runner/`
5. Cập nhật `lib/firebase_options.dart` (template đã có)

## 3️⃣ Kích Hoạt Firebase Services (1 phút)

Trong Firebase Console:
1. **Authentication** → Sign-in method → Bật "Email/Password"
2. **Firestore Database** → Create → "test mode" → Region: "asia-southeast1"

## 4️⃣ Chạy App (1 phút)

```bash
# Xóa build cũ (nếu có lỗi)
flutter clean

# Chạy app
flutter run

# Hoặc chạy cho platform cụ thể
flutter run -d android    # Android
flutter run -d chrome     # Web
```

## ✅ Test Nhanh

### Đăng Ký
1. Nhấp "Đăng ký ngay"
2. Nhập: email=`test@example.com`, password=`123456`
3. Confirm password: `123456`
4. Nhấp "Đăng ký"
5. Thấy thông báo "Đăng ký thành công!"
6. Kiểm tra Firebase Console → Authentication → Users

### Đăng Nhập
1. Nhập email: `test@example.com`
2. Nhập password: `123456`
3. Nhấp "Đăng nhập"
4. Thấy HomePage với bản đồ

### Map & Alerts
1. Bản đồ hiển thị trung tâm ở Gò Vấp
2. Nếu có alerts, sẽ thấy markers
3. Nhấp markers để xem chi tiết
4. Nhấp "Refresh" để load lại

## 📋 File Structure

```
Quan trọng nhất:
├── lib/firebase_options.dart    ← PHẢI cập nhật!
├── lib/main.dart                ← Firebase initialized
├── lib/data/                    ← Data layer
├── lib/business/                ← Business logic
├── lib/presentation/            ← UI
└── FIREBASE_SETUP.md            ← Chi tiết setup
```

## 🔧 Troubleshooting

| Error | Solution |
|-------|----------|
| `DefaultFirebaseOptions not initialized` | Chạy `flutterfire configure` |
| `google-services.json not found` | Đặt file vào `android/app/` |
| `Map not showing` | Thêm Google Maps API Key |
| `PERMISSION_DENIED` | Cập nhật Firestore Rules |
| `Build fails` | Chạy `flutter clean` rồi `flutter pub get` |

## 🚀 Next Steps

Sau khi chạy thành công:

1. **Explore Architecture** → Đọc `ARCHITECTURE.md`
2. **Setup Firestore Rules** → Xem `FIREBASE_SETUP.md` (Step 5)
3. **Setup Google Maps** → Xem `FIREBASE_SETUP.md` (Step 3)
4. **Unit Tests** → Xem `TESTING_GUIDE.md`
5. **Deploy** → Prepare for production

## 💡 Tips

```dart
// Kiểm tra auth state
final authController = getIt<AuthController>();
print(authController.isAuthenticated);  // true/false

// Kiểm tra alerts
final alertController = getIt<FloodAlertController>();
print(alertController.alerts);  // List<FloodAlertModel>

// Kiểm tra errors
print(authController.errorMessage);
print(alertController.errorMessage);
```

## 📞 Support

Nếu cần help:
1. Đọc file tương ứng (FIREBASE_SETUP, ARCHITECTURE, etc.)
2. Check error logs: `flutter run --verbose`
3. Kiểm tra Firebase Console

---

**Bây giờ chạy `flutter run` và enjoy! 🎉**
