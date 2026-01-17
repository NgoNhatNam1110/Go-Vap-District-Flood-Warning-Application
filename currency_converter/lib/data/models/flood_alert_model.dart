/// Mô hình cảnh báo lũ lụt
/// Chứa thông tin chi tiết về các cảnh báo lũ lụt tại khu vực
class FloodAlertModel {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String severity; // low, medium, high, critical
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  FloodAlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Chuyển FloodAlertModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'severity': severity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Tạo FloodAlertModel từ JSON
  factory FloodAlertModel.fromJson(Map<String, dynamic> json) {
    return FloodAlertModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      severity: json['severity'] as String? ?? 'low',
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Sao chép FloodAlertModel với các giá trị mới
  FloodAlertModel copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? severity,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return FloodAlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Phương thức xác định mức độ nguy hiểm theo màu sắc
  String getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'critical':
        return '#FF0000'; // Đỏ
      case 'high':
        return '#FF9500'; // Cam
      case 'medium':
        return '#FFCC00'; // Vàng
      case 'low':
        return '#00C400'; // Xanh
      default:
        return '#808080'; // Xám
    }
  }
}
