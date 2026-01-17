import 'package:currency_converter/data/models/user_model.dart';
import 'package:currency_converter/data/repositories/auth_repository.dart';

/// Enum trạng thái đăng nhập
enum AuthState { loading, authenticated, unauthenticated, error }

/// Controller xử lí logic xác thực
/// Quản lí trạng thái đăng nhập/đăng ký/đăng xuất
/// Cách ly business logic khỏi UI
class AuthController {
  final AuthRepository _repository;

  AuthState _state = AuthState.unauthenticated;
  String? _errorMessage;
  UserModel? _currentUser;

  // Callbacks để cập nhật UI
  Function(AuthState)? _onStateChanged;
  Function(String)? _onError;
  Function(UserModel?)? _onUserChanged;

  AuthController({required AuthRepository repository})
      : _repository = repository {
    // Theo dõi trạng thái auth
    _repository.authStateChanges.listen((_) async {
      final user = await _repository.getCurrentUser();
      _setCurrentUser(user);
    });
  }

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Setters cho callbacks
  set onStateChanged(Function(AuthState)? callback) => _onStateChanged = callback;
  set onError(Function(String)? callback) => _onError = callback;
  set onUserChanged(Function(UserModel?)? callback) => _onUserChanged = callback;

  /// Đăng ký người dùng mới
  /// 
  /// Quy trình:
  /// 1. Kiểm tra input hợp lệ
  /// 2. Gọi repository.signup()
  /// 3. Cập nhật state
  /// 4. Gọi callbacks
  Future<bool> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
  }) async {
    try {
      _setState(AuthState.loading);

      // Validate input
      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        throw Exception('Vui lòng nhập đầy đủ thông tin');
      }

      if (password != confirmPassword) {
        throw Exception('Mật khẩu không trùng khớp');
      }

      if (password.length < 6) {
        throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
      }

      // Gọi repository
      final user = await _repository.signup(
        email: email,
        password: password,
        fullName: fullName,
      );

      _setCurrentUser(user);
      _setState(AuthState.authenticated);
      _clearError();

      return true;
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.error);
      return false;
    }
  }

  /// Đăng nhập
  /// 
  /// Tham số:
  /// - email: Email người dùng
  /// - password: Mật khẩu
  /// 
  /// Trả về: true nếu thành công, false nếu thất bại
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setState(AuthState.loading);

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Vui lòng nhập email và mật khẩu');
      }

      final user = await _repository.login(
        email: email,
        password: password,
      );

      if (user == null) {
        throw Exception('Đăng nhập thất bại');
      }

      _setCurrentUser(user);
      _setState(AuthState.authenticated);
      _clearError();

      return true;
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.error);
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      _setState(AuthState.loading);
      await _repository.logout();
      _setCurrentUser(null);
      _setState(AuthState.unauthenticated);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Cập nhật thông tin hồ sơ
  /// 
  /// Tham số: Các trường cần cập nhật (tất cả tùy chọn)
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (_currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      await _repository.updateUserProfile(
        uid: _currentUser!.uid,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      // Cập nhật user local
      _setCurrentUser(_currentUser!.copyWith(
        fullName: fullName ?? _currentUser!.fullName,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        address: address ?? _currentUser!.address,
        latitude: latitude ?? _currentUser!.latitude,
        longitude: longitude ?? _currentUser!.longitude,
      ));

      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Gửi email đặt lại mật khẩu
  Future<bool> resetPassword(String email) async {
    try {
      _setState(AuthState.loading);
      await _repository.resetPassword(email);
      _setState(AuthState.unauthenticated);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.error);
      return false;
    }
  }

  // Helper methods
  void _setState(AuthState newState) {
    _state = newState;
    _onStateChanged?.call(newState);
  }

  void _setError(String message) {
    _errorMessage = message;
    _onError?.call(message);
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setCurrentUser(UserModel? user) {
    _currentUser = user;
    _onUserChanged?.call(user);
  }

  /// Dispose resources
  void dispose() {
    _onStateChanged = null;
    _onError = null;
    _onUserChanged = null;
  }
}
