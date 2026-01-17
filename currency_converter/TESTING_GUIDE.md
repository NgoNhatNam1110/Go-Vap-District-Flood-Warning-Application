# 🧪 Testing Checklist

## Unit Tests (TODO)

Các tests cần viết:

### Data Layer Tests
```dart
// test/data/models/user_model_test.dart
test('UserModel.fromJson() - convert JSON correctly', () {
  final json = {
    'uid': 'user123',
    'email': 'test@example.com',
    'fullName': 'John Doe',
  };
  
  final user = UserModel.fromJson(json);
  
  expect(user.uid, 'user123');
  expect(user.email, 'test@example.com');
});

// test/data/repositories/auth_repository_test.dart
test('AuthRepository.login() - returns UserModel on success', () async {
  // Mock FirebaseAuthService
  // Mock FirestoreUserService
  
  final result = await repository.login(
    email: 'test@example.com',
    password: '123456',
  );
  
  expect(result, isA<UserModel>());
});
```

### Business Layer Tests
```dart
// test/business/controllers/auth_controller_test.dart
test('AuthController.login() - updates state to authenticated', () async {
  final controller = AuthController(repository: mockRepository);
  
  await controller.login(email: 'test@example.com', password: '123456');
  
  expect(controller.state, AuthState.authenticated);
  expect(controller.currentUser, isNotNull);
});
```

### Presentation Layer Tests (Widget Tests)
```dart
// test/presentation/widgets/custom_text_field_test.dart
testWidgets('CustomTextField - displays label', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CustomTextField(
          label: 'Email',
          hint: 'Enter email',
          prefixIcon: Icons.email,
        ),
      ),
    ),
  );
  
  expect(find.text('Email'), findsOneWidget);
});
```

## Manual Testing Checklist

### Authentication Flow
- [ ] **Signup**
  - [ ] Nhập email hợp lệ
  - [ ] Nhập mật khẩu >= 6 ký tự
  - [ ] Xác nhận mật khẩu trùng khớp
  - [ ] Nhấp "Đăng ký"
  - [ ] Thấy "Đăng ký thành công!"
  - [ ] Form trở về mode login
  - [ ] Kiểm tra Firestore: Collection "users" có document mới

- [ ] **Validation**
  - [ ] Email để trống → "Vui lòng nhập email"
  - [ ] Email sai format → "Email không hợp lệ"
  - [ ] Password < 6 ký tự → "Mật khẩu phải có ít nhất 6 ký tự"
  - [ ] Password không trùng → "Mật khẩu không trùng khớp"
  - [ ] Email đã tồn tại → "Email đã được đăng ký"

- [ ] **Login**
  - [ ] Nhập email & password đúng → Chuyển tới HomePage
  - [ ] Nhập password sai → "Mật khẩu không chính xác"
  - [ ] Email không tồn tại → "Email này không tồn tại"
  - [ ] Kiểm tra Firestore: Thấy user data

### Map Features
- [ ] **Map Display**
  - [ ] Bản đồ hiển thị
  - [ ] Center tại Gò Vấp (10.776530, 106.700981)
  - [ ] Zoom level = 12
  - [ ] Có thể pan, zoom

- [ ] **Flood Alerts**
  - [ ] Alerts hiển thị dưới dạng markers
  - [ ] Màu marker thay đổi theo severity
    - [ ] Critical = Red
    - [ ] High = Orange
    - [ ] Medium = Yellow
    - [ ] Low = Green
  - [ ] Nhấp marker → Hiện thông tin
  - [ ] Nhấp "Xem trên bản đồ" → Zoom vào alert

- [ ] **Navigation**
  - [ ] Nhấp icon "My Location" → Map focus vào vị trí người dùng
  - [ ] Nhấp icon "Refresh" → Tải lại alerts
  - [ ] Nhấp "Hồ sơ" → Chuyển sang tab Profile
  - [ ] Nhấp "Bản đồ" → Quay lại tab Map

### Real-time Updates
- [ ] Mở 2 browser tabs cùng Firestore
- [ ] Thêm alert mới trong Firestore
- [ ] Kiểm tra app tự động cập nhật (không cần reload)

### Error Handling
- [ ] Network offline → Hiển thị error message
- [ ] Firebase timeout → Hiển thị "Yêu cầu hết thời gian"
- [ ] Firebase permission denied → Hiển thị error chi tiết

## Performance Testing

### Memory Profile
```bash
# Chạy app
flutter run

# Monitor memory
dart devtools
# Kết nối & theo dõi memory usage
```

### Frame Rate
- [ ] Khi scroll alerts → FPS >= 60
- [ ] Khi pan map → FPS >= 60
- [ ] Khi real-time update → Không lag

### Startup Time
```bash
# Kiểm tra startup time
flutter run --verbose

# Target: < 5 seconds
```

## Security Testing

### Firebase Rules
- [ ] Người dùng chỉ có thể đọc/sửa tài liệu của mình
- [ ] Người dùng không thể tạo/sửa alerts (chỉ admin)
- [ ] Các truy vấn không được phép bị reject

### Data Validation
- [ ] Email validation
- [ ] Password strength
- [ ] Input sanitization

## Cross-Platform Testing

### Android
- [ ] [ ] Login/Signup hoạt động
- [ ] [ ] Map hiển thị đúng
- [ ] [ ] Alerts load correctly
- [ ] [ ] Navigation hoạt động

### iOS
- [ ] [ ] Login/Signup hoạt động
- [ ] [ ] Map hiển thị đúng
- [ ] [ ] Alerts load correctly
- [ ] [ ] Navigation hoạt động

### Web (Optional)
- [ ] [ ] Login/Signup hoạt động
- [ ] [ ] Map hiển thị đúng
- [ ] [ ] Responsive layout

## Test Results Template

```markdown
## Test Date: [DATE]

### Authentication ✅/❌
- Signup: ✅
- Login: ✅
- Validation: ✅

### Map Features ✅/❌
- Display: ✅
- Markers: ✅
- Real-time: ✅

### Performance ✅/❌
- FPS: 60+ ✅
- Startup: < 5s ✅
- Memory: Normal ✅

### Issues Found:
- None

### Comments:
- Application working as expected
```

## Bug Report Template

```markdown
## Bug Title: [Brief description]

### Steps to Reproduce:
1. ...
2. ...
3. ...

### Expected Result:
...

### Actual Result:
...

### Screenshots:
[Attach if possible]

### Device:
- OS: Android 12 / iOS 15
- Device: [Model]
- Flutter version: 3.10.4

### Logs:
[Paste error logs]
```

---

**Lưu ý:** Tất cả tests cần được chạy trước khi push code!
