import 'package:flutter/material.dart';
import 'package:currency_converter/business/controllers/auth_controller.dart';
import 'package:currency_converter/core/service_locator.dart';
import 'package:currency_converter/presentation/widgets/common_widgets.dart';
import 'package:currency_converter/pages/map.dart';

/// Trang xác thực (đăng nhập/đăng ký)
/// 
/// Trách nhiệm:
/// - Hiển thị UI form đăng nhập/đăng ký
/// - Gọi AuthController để xử lý logic
/// - Cập nhật UI dựa trên trạng thái từ controller
/// 
/// Kiến trúc: MVVM pattern (Model-View-ViewModel)
/// - Model: UserModel, AuthState
/// - View: AuthenPage (widget)
/// - ViewModel: AuthController
class AuthenPage extends StatefulWidget {
  const AuthenPage({Key? key}) : super(key: key);

  @override
  State<AuthenPage> createState() => _AuthenPageState();
}

class _AuthenPageState extends State<AuthenPage> {
  late final AuthController _authController;
  bool _isLoginMode = true; // true: login, false: signup

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authController = getIt<AuthController>();
    _setupControllerCallbacks();
  }

  /// Setup callbacks để cập nhật UI khi state thay đổi
  void _setupControllerCallbacks() {
    _authController.onStateChanged = (state) {
      if (!mounted) return;

      switch (state) {
        case AuthState.authenticated:
          _handleAuthSuccess();
          break;
        case AuthState.error:
          _showErrorSnackBar(_authController.errorMessage ?? 'Có lỗi xảy ra');
          break;
        case AuthState.loading:
          // State sẽ được hiển thị qua build()
          setState(() {});
          break;
        case AuthState.unauthenticated:
          // Không cần xử lí gì
          break;
      }
    };

    _authController.onError = (message) {
      if (mounted) {
        _showErrorSnackBar(message);
      }
    };
  }

  /// Xử lí khi đăng nhập/đăng ký thành công
  void _handleAuthSuccess() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLoginMode ? 'Đăng nhập thành công!' : 'Đăng ký thành công!'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Chuyển tới trang chính
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  /// Hiển thị error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Xử lí đăng nhập
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!success && mounted) {
      setState(() {});
    }
  }

  /// Xử lí đăng ký
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      fullName: _nameController.text.trim(),
    );

    if (success && mounted) {
      // Sau khi đăng ký thành công, chuyển về mode login
      setState(() {
        _isLoginMode = true;
        _clearForm();
      });

      _showErrorSnackBar('Đăng ký thành công! Vui lòng đăng nhập.');
    }
  }

  /// Xóa nội dung form
  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _authController.state == AuthState.loading;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              // Logo/Title
              const Icon(Icons.warning, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Cảnh báo lũ lụt Gò Vấp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLoginMode ? 'Đăng nhập vào tài khoản' : 'Tạo tài khoản mới',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name field (only for signup)
                    if (!_isLoginMode)
                      CustomTextField(
                        label: 'Họ tên',
                        hint: 'Nhập họ tên của bạn',
                        prefixIcon: Icons.person,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ tên';
                          }
                          if (value.length < 3) {
                            return 'Họ tên phải có ít nhất 3 ký tự';
                          }
                          return null;
                        },
                      ),

                    // Email field
                    CustomTextField(
                      key: ValueKey('email_${_isLoginMode}'),
                      label: 'Email',
                      hint: 'Nhập email của bạn',
                      prefixIcon: Icons.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    // Password field
                    CustomTextField(
                      label: 'Mật khẩu',
                      hint: 'Nhập mật khẩu của bạn',
                      prefixIcon: Icons.lock,
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),

                    // Confirm Password field (only for signup)
                    if (!_isLoginMode)
                      CustomTextField(
                        label: 'Xác nhận mật khẩu',
                        hint: 'Nhập lại mật khẩu',
                        prefixIcon: Icons.lock,
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          if (value != _passwordController.text) {
                            return 'Mật khẩu không trùng khớp';
                          }
                          return null;
                        },
                      ),

                    const SizedBox(height: 8),

                    // Submit button
                    CustomButton(
                      label: _isLoginMode ? 'Đăng nhập' : 'Đăng ký',
                      isLoading: isLoading,
                      onPressed: _isLoginMode ? _handleLogin : _handleSignup,
                    ),

                    const SizedBox(height: 16),

                    // Toggle login/signup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLoginMode ? 'Chưa có tài khoản? ' : 'Đã có tài khoản? ',
                          style: const TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLoginMode = !_isLoginMode;
                                    _clearForm();
                                  });
                                },
                          child: Text(
                            _isLoginMode ? 'Đăng ký ngay' : 'Đăng nhập',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Forgot password (only for login)
                    if (_isLoginMode) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                // TODO: Implement forgot password
                              },
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
