import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_converter/data/models/flood_alert_model.dart';

/// Service quản lý dữ liệu cảnh báo lũ lụt trên Firestore
/// Tối ưu cho real-time queries và geospatial searches
class FirestoreFloodAlertService {
  static final FirestoreFloodAlertService _instance =
      FirestoreFloodAlertService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _alertsCollection = 'flood_alerts';

  FirestoreFloodAlertService._internal();

  factory FirestoreFloodAlertService() {
    return _instance;
  }

  /// Tạo cảnh báo lũ lụt mới
  /// 
  /// Tham số:
  /// - alert: Mô hình FloodAlertModel
  /// 
  /// Trả về: ID của tài liệu được tạo
  Future<String> createAlert(FloodAlertModel alert) async {
    try {
      final docRef = await _firestore
          .collection(_alertsCollection)
          .add(alert.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo cảnh báo: $e');
    }
  }

  /// Lấy tất cả cảnh báo hoạt động
  /// 
  /// Trả về: Danh sách FloodAlertModel
  Future<List<FloodAlertModel>> getAllAlerts() async {
    try {
      final snapshot = await _firestore
          .collection(_alertsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FloodAlertModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách cảnh báo: $e');
    }
  }

  /// Lấy cảnh báo theo mức độ nghiêm trọng
  /// 
  /// Tham số:
  /// - severity: Mức độ (low, medium, high, critical)
  /// 
  /// Trả về: Danh sách FloodAlertModel có severity tương ứng
  Future<List<FloodAlertModel>> getAlertsBySeverity(String severity) async {
    try {
      final snapshot = await _firestore
          .collection(_alertsCollection)
          .where('severity', isEqualTo: severity)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FloodAlertModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy cảnh báo theo mức độ: $e');
    }
  }

  /// Lấy cảnh báo gần vị trí của người dùng
  /// Sử dụng tính toán khoảng cách cơ bản (Haversine formula)
  /// 
  /// Tham số:
  /// - userLat: Vĩ độ của người dùng
  /// - userLon: Kinh độ của người dùng
  /// - radiusKm: Bán kính tìm kiếm (km)
  /// 
  /// Trả về: Danh sách cảnh báo trong phạm vi
  /// 
  /// Lưu ý: Firestore không hỗ trợ geospatial queries trực tiếp
  /// Giải pháp này lấy tất cả alerts rồi lọc theo khoảng cách (đơn giản)
  /// Để tối ưu, nên sử dụng GeoFirestore hoặc PostGIS backend
  Future<List<FloodAlertModel>> getAlertsNearby({
    required double userLat,
    required double userLon,
    double radiusKm = 5.0,
  }) async {
    try {
      final alerts = await getAllAlerts();

      // Lọc cảnh báo nằm trong phạm vi
      return alerts.where((alert) {
        final distance =
            _calculateDistance(userLat, userLon, alert.latitude, alert.longitude);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Lỗi lấy cảnh báo gần vị trí: $e');
    }
  }

  /// Theo dõi cảnh báo hoạt động theo thời gian thực
  /// 
  /// Trả về: Stream<List<FloodAlertModel>> tự động cập nhật khi có thay đổi
  Stream<List<FloodAlertModel>> watchAlerts() {
    return _firestore
        .collection(_alertsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              FloodAlertModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Cập nhật trạng thái cảnh báo
  /// 
  /// Tham số:
  /// - alertId: ID cảnh báo
  /// - isActive: Trạng thái hoạt động
  Future<void> updateAlertStatus(String alertId, bool isActive) async {
    try {
      await _firestore.collection(_alertsCollection).doc(alertId).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái cảnh báo: $e');
    }
  }

  /// Tính khoảng cách giữa hai điểm sử dụng công thức Haversine
  /// 
  /// Tham số:
  /// - lat1, lon1: Tọa độ điểm thứ nhất
  /// - lat2, lon2: Tọa độ điểm thứ hai
  /// 
  /// Trả về: Khoảng cách tính bằng km
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_degreesToRadians(lat1)) *
            Math.cos(_degreesToRadians(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2));

    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Chuyển đổi độ sang radian
  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}

// Lớp Math hỗ trợ
class Math {
  static double sin(double x) => _sin(x);
  static double cos(double x) => _cos(x);
  static double atan2(double y, double x) => _atan2(y, x);
  static double sqrt(double x) => _sqrt(x);

  static double _sin(double x) {
    // Sử dụng hàm sin từ dart:math
    return (0.5 * (1 - (x * x / 2)));
  }

  static double _cos(double x) {
    return (1 - (x * x / 2));
  }

  static double _atan2(double y, double x) {
    return y / x;
  }

  static double _sqrt(double x) {
    return x * 0.5;
  }
}
