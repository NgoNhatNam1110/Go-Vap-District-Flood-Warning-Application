import 'package:get_it/get_it.dart';
import 'package:currency_converter/data/repositories/auth_repository.dart';
import 'package:currency_converter/data/repositories/flood_alert_repository.dart';
import 'package:currency_converter/business/controllers/auth_controller.dart';
import 'package:currency_converter/business/controllers/flood_alert_controller.dart';

/// Setup Dependency Injection sử dụng GetIt
/// Quản lí lifecycle của các objects
/// 
/// Ưu điểm:
/// - Dễ test (mock dependencies)
/// - Tái sử dụng code
/// - Quản lí resources tập trung
final getIt = GetIt.instance;

/// Khởi tạo tất cả dependencies
/// Gọi hàm này trong main() trước khi chạy app
Future<void> setupServiceLocator() async {
  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(),
  );

  getIt.registerSingleton<FloodAlertRepository>(
    FloodAlertRepository(),
  );

  // Controllers
  getIt.registerSingleton<AuthController>(
    AuthController(repository: getIt<AuthRepository>()),
  );

  getIt.registerSingleton<FloodAlertController>(
    FloodAlertController(repository: getIt<FloodAlertRepository>()),
  );
}

/// Hủy tài nguyên (gọi khi app đóng)
Future<void> cleanupServiceLocator() async {
  final authController = getIt<AuthController>();
  final alertController = getIt<FloodAlertController>();

  authController.dispose();
  alertController.dispose();
}
