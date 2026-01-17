import 'package:flutter/material.dart';
import 'package:currency_converter/pages/profile.dart';
import 'package:currency_converter/presentation/pages/home_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:currency_converter/business/controllers/flood_alert_controller.dart';
import 'package:currency_converter/core/service_locator.dart';
import 'package:currency_converter/presentation/widgets/common_widgets.dart';

/// Trang chính (Map + Navigation)
/// 
/// Hiển thị:
/// - Bản đồ với các cảnh báo lũ lụt
/// - Thông tin hồ sơ người dùng
/// 
/// Sử dụng BottomNavigationBar để navigate giữa Map và Profile
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Key _mapKey = UniqueKey();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      // Reset behavior nếu tap vào item đang chọn
      if (index == 0) {
        setState(() {
          _mapKey = UniqueKey();
        });
      }
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      MapContent(key: _mapKey),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Bản đồ cảnh báo' : 'Hồ sơ',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Bản đồ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Hồ sơ',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Widget hiển thị bản đồ và cảnh báo lũ lụt
class MapContent extends StatefulWidget {
  const MapContent({Key? key}) : super(key: key);

  @override
  State<MapContent> createState() => _MapContentState();
}

class _MapContentState extends State<MapContent> {
  late final FloodAlertController _alertController;
  GoogleMapController? _mapController;

  // Vị trí mặc định (Gò Vấp, Hồ Chí Minh)
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(10.776530, 106.700981),
    zoom: 12,
  );

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _alertController = getIt<FloodAlertController>();
    _setupControllerCallbacks();
    _loadAlerts();
  }

  /// Setup callbacks để cập nhật UI
  void _setupControllerCallbacks() {
    _alertController.onAlertsChanged = (alerts) {
      _updateMarkers(alerts);
    };

    _alertController.onError = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    };
  }

  /// Tải tất cả cảnh báo
  void _loadAlerts() {
    _alertController.loadAllAlerts();
  }

  /// Cập nhật markers trên bản đồ
  void _updateMarkers(alerts) {
    final newMarkers = <Marker>{};

    for (final alert in alerts) {
      final marker = Marker(
        markerId: MarkerId(alert.id),
        position: LatLng(alert.latitude, alert.longitude),
        infoWindow: InfoWindow(
          title: alert.title,
          snippet: alert.description,
        ),
        // Thay đổi màu marker dựa trên severity
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getSeverityHue(alert.severity),
        ),
        onTap: () {
          _showAlertDetails(alert);
        },
      );
      newMarkers.add(marker);
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  /// Lấy hue color dựa trên severity
  double _getSeverityHue(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return BitmapDescriptor.hueRed; // Đỏ
      case 'high':
        return BitmapDescriptor.hueOrange; // Cam
      case 'medium':
        return BitmapDescriptor.hueYellow; // Vàng
      case 'low':
        return BitmapDescriptor.hueGreen; // Xanh
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  /// Hiển thị chi tiết cảnh báo
  void _showAlertDetails(alert) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mức độ: ${alert.severity}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                alert.description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Zoom vào marker này
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(alert.latitude, alert.longitude),
                    ),
                  );
                },
                child: const Text('Xem trên bản đồ'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Quay về vị trí ban đầu
  void _recenterMap() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(_initialPosition),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: _initialPosition,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // Ẩn button mặc định
        ),

        // Loading indicator
        if (_alertController.state == AlertState.loading)
          const LoadingWidget(message: 'Đang tải cảnh báo...'),

        // Empty state
        if (_alertController.state == AlertState.empty)
          EmptyStateWidget(
            title: 'Không có cảnh báo',
            description: 'Không có cảnh báo lũ lụt trong khu vực này',
            icon: Icons.info,
            onRetry: _loadAlerts,
          ),

        // Recenter button (góc phải dưới)
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            onPressed: _recenterMap,
            child: const Icon(Icons.my_location),
          ),
        ),

        // Refresh button (góc phải)
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _loadAlerts,
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}
