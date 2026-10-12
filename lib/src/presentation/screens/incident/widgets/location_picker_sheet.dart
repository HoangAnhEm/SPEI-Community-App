import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/location_service.dart';
import 'interactive_map_view.dart';

/// Bottom Sheet tương tác chọn vị trí trên bản đồ và đảo ngược địa chỉ
class LocationPickerSheet extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final String? initialAddress;

  const LocationPickerSheet({
    super.key,
    this.initialLat = LocationService.defaultLat,
    this.initialLng = LocationService.defaultLng,
    this.initialAddress,
  });

  static Future<({double lat, double lng, String address})?> show(
    BuildContext context, {
    double initialLat = LocationService.defaultLat,
    double initialLng = LocationService.defaultLng,
    String? initialAddress,
  }) {
    return showModalBottomSheet<({double lat, double lng, String address})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LocationPickerSheet(
        initialLat: initialLat,
        initialLng: initialLng,
        initialAddress: initialAddress,
      ),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final GlobalKey<InteractiveMapViewState> _mapKey = GlobalKey();

  late double _currentLat;
  late double _currentLng;
  String _currentAddress = 'Đang xác định địa chỉ...';
  bool _isLoadingAddress = false;
  bool _isGettingLocation = false;
  ({double lat, double lng})? _userLocation;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLat;
    _currentLng = widget.initialLng;
    if (widget.initialAddress != null &&
        widget.initialAddress!.isNotEmpty &&
        !widget.initialAddress!.startsWith('Tọa độ:') &&
        !widget.initialAddress!.contains('Đang xác định')) {
      _currentAddress = widget.initialAddress!;
    } else {
      _resolveAddress(_currentLat, _currentLng);
    }
    _checkInitialUserLocation();
  }

  Future<void> _checkInitialUserLocation() async {
    try {
      final status = await Permission.location.status;
      if (status.isGranted) {
        final loc = await LocationService().getCurrentLocation();
        if (mounted) {
          setState(() {
            _userLocation = (lat: loc.lat, lng: loc.lng);
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onCoordinatesChanged(double lat, double lng) {
    setState(() {
      _currentLat = lat;
      _currentLng = lng;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _resolveAddress(lat, lng);
    });
  }

  Future<void> _resolveAddress(double lat, double lng) async {
    if (!mounted) return;
    setState(() => _isLoadingAddress = true);
    final addr = await LocationService().getAddressFromCoordinates(lat, lng);
    if (!mounted) return;
    setState(() {
      _currentAddress = addr;
      _isLoadingAddress = false;
    });
  }

  Future<void> _handleGetCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    final loc = await LocationService().getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _currentLat = loc.lat;
      _currentLng = loc.lng;
      _currentAddress = loc.address;
      _userLocation = (lat: loc.lat, lng: loc.lng);
      _isGettingLocation = false;
    });
    _mapKey.currentState?.moveTo(loc.lat, loc.lng);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 2. Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chọn địa điểm',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2E1E),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kéo & chạm bản đồ để chỉ định vị trí vi phạm',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 3. Khung hiển thị địa chỉ đang chọn
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2EBE0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoadingAddress
                            ? 'Đang nhận diện địa chỉ...'
                            : _currentAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2E1E),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tọa độ: ${_currentLat.toStringAsFixed(5)}, ${_currentLng.toStringAsFixed(5)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingAddress)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // 4. Khung bản đồ tương tác (Google Maps Tiles + CartoDB Fallback)
          Expanded(
            child: ClipRRect(
              child: InteractiveMapView(
                key: _mapKey,
                initialLat: _currentLat,
                initialLng: _currentLng,
                initialZoom: 15,
                userLocation: _userLocation,
                selectedMarkerLabel: 'Vị trí vi phạm',
                isInteractive: true,
                onLocationSelected: (lat, lng) {
                  _onCoordinatesChanged(lat, lng);
                },
              ),
            ),
          ),

          // 5. Nút hành động ở đáy
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nút "Lấy vị trí hiện tại" nằm ngay trên nút xác nhận
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _isGettingLocation
                          ? null
                          : _handleGetCurrentLocation,
                      icon: _isGettingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location,
                              size: 18, color: Color(0xFF2E7D32)),
                      label: const Text(
                        'Lấy vị trí hiện tại của tôi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nút "Xác nhận vị trí này"
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          (
                            lat: _currentLat,
                            lng: _currentLng,
                            address: _currentAddress,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xác nhận vị trí này',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet chỉ để xem vị trí của Incident trên bản đồ (gọi từ Chi tiết phản ánh)
class LocationViewerSheet extends StatefulWidget {
  final double lat;
  final double lng;
  final String address;

  const LocationViewerSheet({
    super.key,
    required this.lat,
    required this.lng,
    required this.address,
  });

  static void show(
    BuildContext context, {
    required double lat,
    required double lng,
    required String address,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LocationViewerSheet(
        lat: lat,
        lng: lng,
        address: address,
      ),
    );
  }

  @override
  State<LocationViewerSheet> createState() => _LocationViewerSheetState();
}

class _LocationViewerSheetState extends State<LocationViewerSheet> {
  final GlobalKey<InteractiveMapViewState> _mapKey = GlobalKey();
  ({double lat, double lng})? _userLocation;
  late String _displayAddress;

  @override
  void initState() {
    super.initState();
    _displayAddress = widget.address;
    if (_displayAddress.startsWith('Tọa độ:') || _displayAddress.isEmpty) {
      LocationService()
          .getAddressFromCoordinates(widget.lat, widget.lng)
          .then((addr) {
        if (mounted && !addr.startsWith('Tọa độ:')) {
          setState(() => _displayAddress = addr);
        }
      });
    }
    _checkUserLocation();
  }

  Future<void> _checkUserLocation() async {
    try {
      final status = await Permission.location.status;
      if (status.isGranted) {
        final loc = await LocationService().getCurrentLocation();
        if (mounted) {
          setState(() {
            _userLocation = (lat: loc.lat, lng: loc.lng);
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Vị trí phản ánh',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E1E),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Địa chỉ
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2EBE0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2E1E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tọa độ: ${widget.lat.toStringAsFixed(5)}, ${widget.lng.toStringAsFixed(5)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bản đồ tương tác
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  child: InteractiveMapView(
                    key: _mapKey,
                    initialLat: widget.lat,
                    initialLng: widget.lng,
                    initialZoom: 16,
                    userLocation: _userLocation,
                    selectedMarkerLabel: 'Vị trí phản ánh',
                    isInteractive: true,
                  ),
                ),
                // Nút "Về vị trí phản ánh"
                Positioned(
                  left: 14,
                  bottom: 16,
                  child: InkWell(
                    onTap: () {
                      _mapKey.currentState?.centerOn(widget.lat, widget.lng, zoom: 16);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.near_me, size: 16, color: Color(0xFF2E7D32)),
                          SizedBox(width: 4),
                          Text(
                            'Về vị trí phản ánh',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2E1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
