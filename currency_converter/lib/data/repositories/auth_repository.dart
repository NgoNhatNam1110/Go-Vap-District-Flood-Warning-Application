import 'package:currency_converter/data/models/user_model.dart';
import 'package:currency_converter/data/services/firebase_auth_service.dart';
import 'package:currency_converter/data/services/firestore_user_service.dart';

/// Repository quản lý xác thực và dữ liệu người dùng
/// Kết nối Firebase Auth Service và Firestore User Service
/// Cung cấp interface duy nhất cho Business Layer
class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreUserService _firestoreService;

  AuthRepository({
    FirebaseAuthService? authService,
    FirestoreUserService? firestoreService,
  })  : _authService = authService ?? FirebaseAuthService(),
        _firestoreService = firestoreService ?? FirestoreUserService();

  /// Đăng ký người dùng mới
  /// 
  /// Quy trình:
  /// 1. Tạo tài khoản Firebase Auth
  /// 2. Tạo document người dùng trên Firestore
  /// 
  /// Tham số:
  /// - email: Email người dùng
  /// - password: Mật khẩu người dùng
  /// - fullName: Họ tên người dùng
  /// 
  /// Trả về: UserModel của người dùng mới tạo
  Future<UserModel> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Kiểm tra email đã tồn tại chưa
      final exists = await _firestoreService.emailExists(email);
      if (exists) {
        throw Exception('Email đã được đăng ký');
      }

      // Tạo tài khoản Firebase
      final userCredential = await _authService.signup(
        email: email,
        password: password,
      );

      if (userCredential == null || userCredential.user == null) {
        throw Exception('Đăng ký thất bại');
      }

      // Tạo user document trên Firestore
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createUser(user);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng nhập người dùng
  /// 
  /// Tham số:
  /// - email: Email người dùng
  /// - password: Mật khẩu người dùng
  /// 
  /// Trả về: UserModel của người dùng
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authService.login(
        email: email,
        password: password,
      );

      if (userCredential?.user == null) {
        return null;
      }

      // Lấy thông tin người dùng từ Firestore
      final user = await _firestoreService.getUser(userCredential!.user!.uid);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng xuất người dùng
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy thông tin người dùng hiện tại
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return null;
      }

      return await _firestoreService.getUser(currentUser.uid);
    } catch (e) {
      return null;
    }
  }

  /// Cập nhật thông tin người dùng
  /// 
  /// Tham số:
  /// - uid: ID người dùng
  /// - fullName: Họ tên (tùy chọn)
  /// - phoneNumber: Số điện thoại (tùy chọn)
  /// - address: Địa chỉ (tùy chọn)
  /// - latitude: Vĩ độ vị trí (tùy chọn)
  /// - longitude: Kinh độ vị trí (tùy chọn)
  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;

      await _firestoreService.updateUser(uid, updates);
    } catch (e) {
      rethrow;
    }
  }

  /// Theo dõi thông tin người dùng theo thời gian thực
  Stream<UserModel?> watchCurrentUser(String uid) {
    return _firestoreService.watchUser(uid);
  }

  /// Gửi email đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy trạng thái auth hiện tại (Stream)
  Stream<dynamic> get authStateChanges => _authService.authStateChanges;
}
