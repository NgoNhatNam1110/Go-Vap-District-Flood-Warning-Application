import 'package:currency_converter/data/models/flood_alert_model.dart';
import 'package:currency_converter/data/services/firestore_flood_alert_service.dart';

/// Repository quản lý dữ liệu cảnh báo lũ lụt
/// Cung cấp interface duy nhất cho Business Layer
/// Trừu tượng hóa các chi tiết Firebase
class FloodAlertRepository {
  final FirestoreFloodAlertService _firestoreService;

  FloodAlertRepository({
    FirestoreFloodAlertService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreFloodAlertService();

  /// Tạo cảnh báo lũ lụt mới
  /// 
  /// Tham số:
  /// - alert: Mô hình FloodAlertModel chứa thông tin cảnh báo
  /// 
  /// Trả về: ID của tài liệu được tạo
  Future<String> createAlert(FloodAlertModel alert) async {
    try {
      return await _firestoreService.createAlert(alert);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy tất cả cảnh báo lũ lụt hoạt động
  /// 
  /// Trả về: Danh sách FloodAlertModel
  Future<List<FloodAlertModel>> getAllAlerts() async {
    try {
      return await _firestoreService.getAllAlerts();
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy cảnh báo theo mức độ nghiêm trọng
  /// 
  /// Tham số:
  /// - severity: Mức độ cảnh báo (low, medium, high, critical)
  /// 
  /// Trả về: Danh sách cảnh báo có severity tương ứng
  Future<List<FloodAlertModel>> getAlertsBySeverity(String severity) async {
    try {
      return await _firestoreService.getAlertsBySeverity(severity);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy cảnh báo gần vị trí của người dùng
  /// 
  /// Tham số:
  /// - userLat: Vĩ độ
  /// - userLon: Kinh độ
  /// - radiusKm: Bán kính tìm kiếm (mặc định 5km)
  /// 
  /// Trả về: Danh sách cảnh báo trong phạm vi
  /// 
  /// Lưu ý: Hiệu năng phụ thuộc vào số lượng alerts toàn bộ
  /// Để tối ưu, nên sử dụng geospatial database như PostGIS
  Future<List<FloodAlertModel>> getAlertsNearby({
    required double userLat,
    required double userLon,
    double radiusKm = 5.0,
  }) async {
    try {
      return await _firestoreService.getAlertsNearby(
        userLat: userLat,
        userLon: userLon,
        radiusKm: radiusKm,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Theo dõi cảnh báo lũ lụt theo thời gian thực
  /// Tự động cập nhật UI khi có cảnh báo mới hoặc thay đổi
  /// 
  /// Trả về: Stream<List<FloodAlertModel>>
  /// 
  /// Ưu điểm: Real-time update, tiết kiệm bandwidth
  /// Nhược điểm: Cần quản lí stream subscription để tránh memory leak
  Stream<List<FloodAlertModel>> watchAlerts() {
    return _firestoreService.watchAlerts();
  }

  /// Cập nhật trạng thái hoạt động của cảnh báo
  /// 
  /// Tham số:
  /// - alertId: ID cảnh báo
  /// - isActive: true để hoạt động, false để hủy
  Future<void> updateAlertStatus(String alertId, bool isActive) async {
    try {
      await _firestoreService.updateAlertStatus(alertId, isActive);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy cảnh báo mức độ cao nhất (critical + high)
  /// Sử dụng để hiển thị thông báo ưu tiên
  /// 
  /// Trả về: Danh sách cảnh báo mức độ cao
  Future<List<FloodAlertModel>> getHighSeverityAlerts() async {
    try {
      final critical = await _firestoreService.getAlertsBySeverity('critical');
      final high = await _firestoreService.getAlertsBySeverity('high');
      return [...critical, ...high];
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy cảnh báo gần đây (trong 24 giờ qua)
  /// 
  /// Trả về: Danh sách cảnh báo mới
  Future<List<FloodAlertModel>> getRecentAlerts() async {
    try {
      final alerts = await _firestoreService.getAllAlerts();
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));

      return alerts
          .where((alert) => alert.createdAt.isAfter(oneDayAgo))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
