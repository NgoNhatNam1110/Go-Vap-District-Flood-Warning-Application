import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Service quản lý Firebase Authentication
/// Xử lý đăng ký, đăng nhập, đăng xuất người dùng
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseAuthService._internal();

  factory FirebaseAuthService() {
    return _instance;
  }

  /// Lấy người dùng hiện tại đang đăng nhập
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Đăng ký người dùng mới
  /// 
  /// Tham số:
  /// - email: Email người dùng
  /// - password: Mật khẩu người dùng
  /// 
  /// Trả về: User nếu thành công, null nếu thất bại
  /// 
  /// Ném Exception nếu có lỗi (email đã tồn tại, mật khẩu yếu, v.v.)
  Future<UserCredential?> signup({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Đăng nhập người dùng
  /// 
  /// Tham số:
  /// - email: Email người dùng
  /// - password: Mật khẩu người dùng
  /// 
  /// Trả về: User nếu thành công
  /// 
  /// Ném Exception nếu email hoặc mật khẩu sai
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Đăng xuất người dùng
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Lỗi đăng xuất: $e');
    }
  }

  /// Gửi email xác minh
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Lỗi gửi email xác minh: $e');
    }
  }

  /// Đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Xử lý các lỗi Firebase Authentication
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng chọn email khác.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Email này không tồn tại.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'operation-not-allowed':
        return 'Thao tác này không được phép.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      default:
        return 'Lỗi xác thực: ${e.message}';
    }
  }
}
