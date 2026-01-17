import 'package:currency_converter/data/models/flood_alert_model.dart';
import 'package:currency_converter/data/repositories/flood_alert_repository.dart';

/// Enum trạng thái lấy dữ liệu
enum AlertState { loading, loaded, error, empty }

/// Controller quản lí logic cảnh báo lũ lụt
/// Xử lí việc lấy, lọc, sắp xếp cảnh báo
/// Cách ly business logic khỏi UI
class FloodAlertController {
  final FloodAlertRepository _repository;

  AlertState _state = AlertState.empty;
  String? _errorMessage;
  List<FloodAlertModel> _alerts = [];
  List<FloodAlertModel> _filteredAlerts = [];

  // Callbacks
  Function(AlertState)? _onStateChanged;
  Function(String)? _onError;
  Function(List<FloodAlertModel>)? _onAlertsChanged;

  FloodAlertController({required FloodAlertRepository repository})
      : _repository = repository;

  // Getters
  AlertState get state => _state;
  String? get errorMessage => _errorMessage;
  List<FloodAlertModel> get alerts => _filteredAlerts.isEmpty ? _alerts : _filteredAlerts;
  List<FloodAlertModel> get allAlerts => _alerts;

  // Setters
  set onStateChanged(Function(AlertState)? callback) => _onStateChanged = callback;
  set onError(Function(String)? callback) => _onError = callback;
  set onAlertsChanged(Function(List<FloodAlertModel>)? callback) =>
      _onAlertsChanged = callback;

  /// Tải tất cả cảnh báo
  Future<void> loadAllAlerts() async {
    try {
      _setState(AlertState.loading);
      _alerts = await _repository.getAllAlerts();

      if (_alerts.isEmpty) {
        _setState(AlertState.empty);
      } else {
        _setState(AlertState.loaded);
      }

      _notifyAlertsChanged();
      _clearError();
    } catch (e) {
      _setError(e.toString());
      _setState(AlertState.error);
    }
  }

  /// Tải cảnh báo gần vị trí người dùng
  /// 
  /// Tham số:
  /// - userLat: Vĩ độ người dùng
  /// - userLon: Kinh độ người dùng
  /// - radiusKm: Bán kính tìm kiếm (mặc định 5km)
  Future<void> loadAlertsNearby({
    required double userLat,
    required double userLon,
    double radiusKm = 5.0,
  }) async {
    try {
      _setState(AlertState.loading);
      _alerts = await _repository.getAlertsNearby(
        userLat: userLat,
        userLon: userLon,
        radiusKm: radiusKm,
      );

      if (_alerts.isEmpty) {
        _setState(AlertState.empty);
      } else {
        _setState(AlertState.loaded);
      }

      _notifyAlertsChanged();
      _clearError();
    } catch (e) {
      _setError(e.toString());
      _setState(AlertState.error);
    }
  }

  /// Tải cảnh báo mức độ cao
  /// 
  /// Lấy các cảnh báo critical và high để hiển thị ưu tiên
  Future<void> loadHighSeverityAlerts() async {
    try {
      _setState(AlertState.loading);
      _alerts = await _repository.getHighSeverityAlerts();

      if (_alerts.isEmpty) {
        _setState(AlertState.empty);
      } else {
        _setState(AlertState.loaded);
      }

      _notifyAlertsChanged();
      _clearError();
    } catch (e) {
      _setError(e.toString());
      _setState(AlertState.error);
    }
  }

  /// Tải cảnh báo mới
  /// 
  /// Lấy các cảnh báo trong 24 giờ qua
  Future<void> loadRecentAlerts() async {
    try {
      _setState(AlertState.loading);
      _alerts = await _repository.getRecentAlerts();

      if (_alerts.isEmpty) {
        _setState(AlertState.empty);
      } else {
        _setState(AlertState.loaded);
      }

      _notifyAlertsChanged();
      _clearError();
    } catch (e) {
      _setError(e.toString());
      _setState(AlertState.error);
    }
  }

  /// Theo dõi cảnh báo real-time
  /// 
  /// Trả về: Stream để subscribe từ UI
  Stream<List<FloodAlertModel>> watchAlerts() {
    return _repository.watchAlerts();
  }

  /// Lọc cảnh báo theo mức độ
  /// 
  /// Tham số:
  /// - severity: Mức độ lọc (low, medium, high, critical)
  void filterBySeverity(String severity) {
    if (severity.isEmpty) {
      _filteredAlerts = [];
    } else {
      _filteredAlerts = _alerts
          .where((alert) =>
              alert.severity.toLowerCase() == severity.toLowerCase())
          .toList();
    }
    _notifyAlertsChanged();
  }

  /// Lọc cảnh báo theo khoảng cách
  /// 
  /// Tham số:
  /// - centerLat: Vĩ độ tâm
  /// - centerLon: Kinh độ tâm
  /// - radiusKm: Bán kính lọc
  void filterByDistance({
    required double centerLat,
    required double centerLon,
    required double radiusKm,
  }) {
    _filteredAlerts = _alerts
        .where((alert) {
          final distance = _calculateDistance(
            centerLat,
            centerLon,
            alert.latitude,
            alert.longitude,
          );
          return distance <= radiusKm;
        })
        .toList();
    _notifyAlertsChanged();
  }

  /// Xóa filter, hiển thị tất cả
  void clearFilter() {
    _filteredAlerts = [];
    _notifyAlertsChanged();
  }

  /// Sắp xếp cảnh báo theo thời gian (mới nhất trước)
  void sortByTime() {
    final listToSort = _filteredAlerts.isEmpty ? _alerts : _filteredAlerts;
    listToSort.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _notifyAlertsChanged();
  }

  /// Sắp xếp cảnh báo theo mức độ (cao nhất trước)
  /// 
  /// Thứ tự: critical > high > medium > low
  void sortBySeverity() {
    const severityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
    final listToSort = _filteredAlerts.isEmpty ? _alerts : _filteredAlerts;

    listToSort.sort((a, b) {
      final orderA = severityOrder[a.severity.toLowerCase()] ?? 99;
      final orderB = severityOrder[b.severity.toLowerCase()] ?? 99;
      return orderA.compareTo(orderB);
    });
    _notifyAlertsChanged();
  }

  // Helper methods
  void _setState(AlertState newState) {
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

  void _notifyAlertsChanged() {
    _onAlertsChanged?.call(alerts);
  }

  /// Tính khoảng cách giữa 2 điểm (Haversine)
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

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  void dispose() {
    _onStateChanged = null;
    _onError = null;
    _onAlertsChanged = null;
  }
}

class Math {
  static double sin(double x) => (x - (x * x * x / 6));
  static double cos(double x) => (1 - (x * x / 2));
  static double atan2(double y, double x) => y / x;
  static double sqrt(double x) => (x * 0.5);
}
