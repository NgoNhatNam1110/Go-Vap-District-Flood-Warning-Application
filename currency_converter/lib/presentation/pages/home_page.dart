import 'package:flutter/material.dart';

/// Trang chính của ứng dụng
/// 
/// Lưu ý: HomePage đã được tạo trong map.dart
/// File này dùng để tạo import path rõ ràng cho presentation layer
///
/// Cấu trúc tệp:
/// - lib/presentation/pages/home_page.dart (re-export HomePage)
/// - lib/pages/map.dart (định nghĩa thực HomePage)

export 'package:currency_converter/pages/map.dart' show HomePage;
