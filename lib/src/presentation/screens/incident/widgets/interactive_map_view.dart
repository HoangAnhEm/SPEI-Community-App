import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Tiện ích tính toán tọa độ Web Mercator (EPSG:3857)
class MercatorProjection {
  static const double tileSize = 256.0;

  static double clip(double n, double minValue, double maxValue) {
    return math.min(math.max(n, minValue), maxValue);
  }

  /// Chuyển lat/lng sang world pixel tại zoom level z
  static ({double x, double y}) latLngToWorldPixel(
      double lat, double lng, int zoom) {
    final clippedLat = clip(lat, -85.05112878, 85.05112878);
    final clippedLng = clip(lng, -180.0, 180.0);
    final mapSize = tileSize * math.pow(2, zoom);

    final x = (clippedLng + 180.0) / 360.0 * mapSize;

    final sinLat = math.sin(clippedLat * math.pi / 180.0);
    final y = (0.5 -
            math.log((1.0 + sinLat) / (1.0 - sinLat)) / (4.0 * math.pi)) *
        mapSize;

    return (x: x, y: y);
  }

  /// Chuyển world pixel sang lat/lng tại zoom level z
  static ({double lat, double lng}) worldPixelToLatLng(
      double px, double py, int zoom) {
    final mapSize = tileSize * math.pow(2, zoom);

    final lng = (clip(px, 0.0, mapSize - 1) / mapSize) * 360.0 - 180.0;

    final y2 = 0.5 - (clip(py, 0.0, mapSize - 1) / mapSize);
    final lat =
        90.0 - 360.0 * math.atan(math.exp(-y2 * 2.0 * math.pi)) / math.pi;

    return (lat: lat, lng: lng);
  }
}

/// Widget bản đồ tương tác đa điểm (Zoom, Pan, Tap to Place Marker, User Location Marker)
/// Hỗ trợ tải ngói bản đồ siêu tốc từ Google Maps Tile API & CartoDB Voyager fallback
class InteractiveMapView extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final int initialZoom;
  final ({double lat, double lng})? userLocation;
  final String selectedMarkerLabel;
  final bool isInteractive;
  final void Function(double lat, double lng)? onLocationSelected;

  const InteractiveMapView({
    super.key,
    required this.initialLat,
    required this.initialLng,
    this.initialZoom = 15,
    this.userLocation,
    this.selectedMarkerLabel = 'Vị trí đã chọn',
    this.isInteractive = true,
    this.onLocationSelected,
  });

  @override
  State<InteractiveMapView> createState() => InteractiveMapViewState();
}

class InteractiveMapViewState extends State<InteractiveMapView> {
  late double _centerLat;
  late double _centerLng;
  late double _selectedLat;
  late double _selectedLng;
  late int _zoom;
  ({double lat, double lng})? _userLocation;

  Offset? _lastFocalPoint;
  double _previousScale = 1.0;

  @override
  void initState() {
    super.initState();
    _centerLat = widget.initialLat;
    _centerLng = widget.initialLng;
    _selectedLat = widget.initialLat;
    _selectedLng = widget.initialLng;
    _zoom = widget.initialZoom;
    _userLocation = widget.userLocation;
  }

  @override
  void didUpdateWidget(covariant InteractiveMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userLocation != oldWidget.userLocation) {
      setState(() {
        _userLocation = widget.userLocation;
      });
    }
    if (widget.initialLat != oldWidget.initialLat ||
        widget.initialLng != oldWidget.initialLng) {
      setState(() {
        _selectedLat = widget.initialLat;
        _selectedLng = widget.initialLng;
      });
    }
  }

  /// Di chuyển cả tâm bản đồ và điểm chọn đến tọa độ mới
  void moveTo(double lat, double lng, {int? zoom}) {
    setState(() {
      _centerLat = lat;
      _centerLng = lng;
      _selectedLat = lat;
      _selectedLng = lng;
      if (zoom != null) _zoom = zoom;
    });
    widget.onLocationSelected?.call(lat, lng);
  }

  /// Đặt lại tâm bản đồ mà không thay đổi điểm chọn
  void centerOn(double lat, double lng, {int? zoom}) {
    setState(() {
      _centerLat = lat;
      _centerLng = lng;
      if (zoom != null) _zoom = zoom;
    });
  }

  /// Cập nhật vị trí người dùng
  void setUserLocation(double lat, double lng) {
    setState(() {
      _userLocation = (lat: lat, lng: lng);
    });
  }

  void zoomIn() {
    if (_zoom < 18) {
      setState(() => _zoom++);
    }
  }

  void zoomOut() {
    if (_zoom > 5) {
      setState(() => _zoom--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Tính pixel thế giới của tâm bản đồ
        final centerWorld =
            MercatorProjection.latLngToWorldPixel(_centerLat, _centerLng, _zoom);
        final leftWorld = centerWorld.x - width / 2;
        final topWorld = centerWorld.y - height / 2;

        final numTiles = math.pow(2, _zoom).toInt();
        final startTileX = (leftWorld / 256.0).floor();
        final endTileX = ((leftWorld + width) / 256.0).floor();
        final startTileY = (topWorld / 256.0).floor();
        final endTileY = ((topWorld + height) / 256.0).floor();

        // Tính vị trí màn hình của Marker chọn
        final selectedWorld = MercatorProjection.latLngToWorldPixel(
            _selectedLat, _selectedLng, _zoom);
        final selectedScreenX = selectedWorld.x - leftWorld;
        final selectedScreenY = selectedWorld.y - topWorld;

        // Tính vị trí màn hình của Marker người dùng nếu có
        double? userScreenX;
        double? userScreenY;
        if (_userLocation != null) {
          final userWorld = MercatorProjection.latLngToWorldPixel(
              _userLocation!.lat, _userLocation!.lng, _zoom);
          userScreenX = userWorld.x - leftWorld;
          userScreenY = userWorld.y - topWorld;
        }

        // Tạo danh sách các ngói bản đồ cần vẽ
        final tileWidgets = <Widget>[];
        for (int ty = startTileY; ty <= endTileY; ty++) {
          if (ty < 0 || ty >= numTiles) continue;
          for (int tx = startTileX; tx <= endTileX; tx++) {
            final wrappedTx = (tx % numTiles + numTiles) % numTiles;
            final posX = tx * 256.0 - leftWorld;
            final posY = ty * 256.0 - topWorld;
            final serverIdx = (wrappedTx + ty).abs() % 4;

            tileWidgets.add(
              Positioned(
                left: posX,
                top: posY,
                width: 256,
                height: 256,
                child: Image.network(
                  'https://mt$serverIdx.google.com/vt/lyrs=m&x=$wrappedTx&y=$ty&z=$_zoom&hl=vi',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.network(
                    'https://a.basemaps.cartocdn.com/rastertiles/voyager/$_zoom/$wrappedTx/$ty.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF2EFE9),
                      child: const Center(
                        child: Icon(Icons.map_outlined,
                            size: 24, color: Color(0xFFD4CEC3)),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTapDown: widget.isInteractive
              ? (details) {
                  zoomIn();
                }
              : null,
          onScaleStart: widget.isInteractive
              ? (details) {
                  _lastFocalPoint = details.localFocalPoint;
                  _previousScale = 1.0;
                }
              : null,
          onScaleUpdate: widget.isInteractive
              ? (details) {
                  // Xử lý kéo bản đồ (Pan)
                  if (_lastFocalPoint != null) {
                    final delta = details.localFocalPoint - _lastFocalPoint!;
                    if (delta.dx != 0 || delta.dy != 0) {
                      final centerWorld = MercatorProjection.latLngToWorldPixel(
                          _centerLat, _centerLng, _zoom);
                      final newCenterWorldX = centerWorld.x - delta.dx;
                      final newCenterWorldY = centerWorld.y - delta.dy;
                      final newLatLng = MercatorProjection.worldPixelToLatLng(
                          newCenterWorldX, newCenterWorldY, _zoom);
                      setState(() {
                        _centerLat = newLatLng.lat;
                        _centerLng = newLatLng.lng;
                      });
                    }
                  }
                  _lastFocalPoint = details.localFocalPoint;

                  // Xử lý chụm ngón tay thu phóng (Pinch to zoom)
                  if (details.scale != 1.0) {
                    final scaleRatio = details.scale / _previousScale;
                    if (scaleRatio > 1.25 && _zoom < 18) {
                      _previousScale = details.scale;
                      zoomIn();
                    } else if (scaleRatio < 0.8 && _zoom > 5) {
                      _previousScale = details.scale;
                      zoomOut();
                    }
                  }
                }
              : null,
          onScaleEnd: widget.isInteractive
              ? (details) {
                  _lastFocalPoint = null;
                  _previousScale = 1.0;
                }
              : null,
          onTapUp: widget.isInteractive
              ? (details) {
                  // Chạm bất kỳ đâu trên bản đồ để đặt marker chọn
                  final tappedWorldX = leftWorld + details.localPosition.dx;
                  final tappedWorldY = topWorld + details.localPosition.dy;
                  final tappedLatLng = MercatorProjection.worldPixelToLatLng(
                      tappedWorldX, tappedWorldY, _zoom);
                  setState(() {
                    _selectedLat = tappedLatLng.lat;
                    _selectedLng = tappedLatLng.lng;
                  });
                  widget.onLocationSelected
                      ?.call(tappedLatLng.lat, tappedLatLng.lng);
                }
              : null,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Lớp ngói bản đồ (Tile Map Layer)
              ...tileWidgets,

              // 2. Marker vị trí người dùng (Chấm xanh phát sáng "Bạn ở đây")
              if (userScreenX != null && userScreenY != null)
                Positioned(
                  left: userScreenX - 40,
                  top: userScreenY - 56,
                  width: 80,
                  height: 56,
                  child: IgnorePointer(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Bạn ở đây',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3)
                                    .withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. Marker điểm đã chọn (Ghim đỏ chỉ định vị trí vi phạm / đã chọn)
              Positioned(
                left: selectedScreenX - 55,
                top: selectedScreenY - 74,
                width: 110,
                height: 74,
                child: IgnorePointer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2E1E),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.selectedMarkerLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.location_on,
                        size: 42,
                        color: Color(0xFFE53935),
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Các nút điều khiển Zoom (+ / -) ở góc phải
              Positioned(
                right: 14,
                bottom: 20,
                child: Column(
                  children: [
                    _buildControlButton(
                      icon: Icons.add,
                      onTap: zoomIn,
                    ),
                    const SizedBox(height: 8),
                    _buildControlButton(
                      icon: Icons.remove,
                      onTap: zoomOut,
                    ),
                  ],
                ),
              ),

              // 5. Thẻ hướng dẫn thao tác chạm ở góc trái dưới
              if (widget.isInteractive)
                Positioned(
                  left: 14,
                  bottom: 16,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_outlined,
                              size: 14, color: Color(0xFF2E7D32)),
                          SizedBox(width: 4),
                          Text(
                            'Chạm bản đồ để đặt vị trí',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
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
        child: Icon(icon, size: 22, color: const Color(0xFF1B2E1E)),
      ),
    );
  }
}
