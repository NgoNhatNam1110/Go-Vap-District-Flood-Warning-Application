/// Các hằng số sử dụng trong ứng dụng
/// Tập trung quản lý để dễ bảo trì

/// Hằng số về Firebase Firestore
class FirestoreConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String floodAlertsCollection = 'flood_alerts';

  // Document fields
  static const String fieldEmail = 'email';
  static const String fieldFullName = 'fullName';
  static const String fieldUid = 'uid';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldIsActive = 'isActive';
  static const String fieldSeverity = 'severity';
  static const String fieldLatitude = 'latitude';
  static const String fieldLongitude = 'longitude';
}

/// Hằng số về bản đồ
class MapConstants {
  // Default location: Gò Vấp, TP.HCM
  static const double defaultLatitude = 10.776530;
  static const double defaultLongitude = 106.700981;
  static const double defaultZoom = 12.0;

  // Geospatial
  static const double defaultRadiusKm = 5.0;
  static const double earthRadiusKm = 6371.0;
}

/// Hằng số về cảnh báo lũ lụt
class AlertConstants {
  // Severity levels
  static const String severityCritical = 'critical';
  static const String severityHigh = 'high';
  static const String severityMedium = 'medium';
  static const String severityLow = 'low';

  static const List<String> severityLevels = [
    severityCritical,
    severityHigh,
    severityMedium,
    severityLow,
  ];

  // Max alerts to load at once (để tối ưu)
  static const int maxAlertsPerPage = 50;

  // Cache duration (nếu implement cache)
  static const Duration cacheDuration = Duration(minutes: 5);
}

/// Hằng số về validation
class ValidationConstants {
  // Email
  static const String emailPattern = r'^[^@]+@[^@]+\.[^@]+$';

  // Password
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;

  // Name
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // Phone
  static const String phonePattern = r'^\d{10,12}$';
}

/// Hằng số về thời gian
class TimeConstants {
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetries = 3;

  // Alert expiry
  static const Duration alertExpiryDuration = Duration(days: 7);
}

/// Hằng số về UI
class UIConstants {
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Animation duration
  static const Duration animationDuration = Duration(milliseconds: 300);
}

/// Hằng số về error messages
class ErrorMessages {
  // Network
  static const String networkError = 'Không có kết nối mạng. Vui lòng kiểm tra lại.';
  static const String timeoutError = 'Yêu cầu hết thời gian. Vui lòng thử lại.';

  // Validation
  static const String emailRequired = 'Vui lòng nhập email';
  static const String emailInvalid = 'Email không hợp lệ';
  static const String passwordRequired = 'Vui lòng nhập mật khẩu';
  static const String passwordTooShort = 'Mật khẩu phải có ít nhất ${ValidationConstants.minPasswordLength} ký tự';
  static const String passwordMismatch = 'Mật khẩu không trùng khớp';
  static const String nameRequired = 'Vui lòng nhập tên';

  // Auth
  static const String emailExists = 'Email đã được sử dụng';
  static const String userNotFound = 'Tài khoản không tồn tại';
  static const String wrongPassword = 'Mật khẩu không chính xác';
  static const String signupFailed = 'Đăng ký thất bại. Vui lòng thử lại.';
  static const String loginFailed = 'Đăng nhập thất bại. Vui lòng thử lại.';

  // Generic
  static const String unknownError = 'Có lỗi xảy ra. Vui lòng thử lại.';
  static const String tryAgain = 'Thử lại';

  static String getValidationError(String field) {
    return 'Vui lòng kiểm tra lại $field';
  }
}

/// Hằng số về success messages
class SuccessMessages {
  static const String signupSuccess = 'Đăng ký thành công! Vui lòng đăng nhập.';
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String logoutSuccess = 'Đã đăng xuất';
  static const String updateSuccess = 'Cập nhật thành công!';
  static const String deleteSuccess = 'Xóa thành công!';
}
