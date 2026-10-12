import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

/// Dịch vụ định vị và đảo ngược tọa độ (Reverse Geocoding)
/// Tích hợp đa nguồn: Photon by Komoot (miễn phí, siêu nét địa chỉ đường phố Việt Nam)
/// kết hợp BigDataCloud API và OpenStreetMap Nominatim làm dự phòng
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'User-Agent': 'SpeiCommunityApp/1.0 (contact@spei.vn)',
        'Accept-Language': 'vi,en;q=0.9',
      },
    ),
  );

  // Bộ nhớ cache tạm thời để tránh gọi API lặp lại cho cùng 1 tọa độ
  final Map<String, String> _addressCache = {};

  // Tọa độ mặc định: Thủ đô Hà Nội
  static const double defaultLat = 21.028511;
  static const double defaultLng = 105.854167;
  static const String defaultAddress = 'Hoàn Kiếm, Hà Nội, Việt Nam';

  /// Lấy địa chỉ hiển thị bằng tiếng Việt từ tọa độ lat/lng
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    final cacheKey = '${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}';
    if (_addressCache.containsKey(cacheKey)) {
      final cached = _addressCache[cacheKey]!;
      if (!cached.startsWith('Tọa độ:')) {
        return cached;
      }
    }

    // 1. Thử nguồn 1: Photon by Komoot (rất mạnh về số nhà, tên đường, quận huyện VN)
    try {
      final photonRes = await _dio.get(
        'https://photon.komoot.io/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
        },
      );

      if (photonRes.statusCode == 200 && photonRes.data != null) {
        final data = photonRes.data is String
            ? jsonDecode(photonRes.data as String) as Map<String, dynamic>
            : photonRes.data as Map<String, dynamic>;

        final features = data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final first = features.first as Map<String, dynamic>;
          final props = first['properties'] as Map<String, dynamic>?;
          if (props != null) {
            final formatted = _formatPhotonAddress(props);
            if (formatted.isNotEmpty && formatted != 'Hà Nội' && formatted != 'Việt Nam') {
              _addressCache[cacheKey] = formatted;
              return formatted;
            }
          }
        }
      }
    } catch (_) {
      // Bỏ qua thử tiếp nguồn 2
    }

    // 2. Thử nguồn 2: BigDataCloud Client Reverse Geocode
    try {
      final bdcRes = await _dio.get(
        'https://api-bdc.io/data/reverse-geocode-client',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'localityLanguage': 'vi',
        },
      );

      if (bdcRes.statusCode == 200 && bdcRes.data != null) {
        final data = bdcRes.data is String
            ? jsonDecode(bdcRes.data as String) as Map<String, dynamic>
            : bdcRes.data as Map<String, dynamic>;

        final locality = data['locality'] as String?;
        final principalSubdivision = data['principalSubdivision'] as String?;
        final city = data['city'] as String?;

        final parts = <String>[];
        if (locality != null && locality.isNotEmpty) {
          parts.add(locality);
        }
        final cityPart = principalSubdivision ?? city;
        if (cityPart != null && cityPart.isNotEmpty && !parts.contains(cityPart)) {
          parts.add(cityPart);
        }

        if (parts.isNotEmpty) {
          final formatted = parts.join(', ');
          _addressCache[cacheKey] = formatted;
          return formatted;
        }
      }
    } catch (_) {
      // Bỏ qua thử tiếp nguồn 3
    }

    // 3. Thử nguồn 3: OpenStreetMap Nominatim
    try {
      final osmRes = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 18,
          'addressdetails': 1,
        },
      );

      if (osmRes.statusCode == 200 && osmRes.data != null) {
        final data = osmRes.data is String
            ? jsonDecode(osmRes.data as String) as Map<String, dynamic>
            : osmRes.data as Map<String, dynamic>;

        final addressMap = data['address'] as Map<String, dynamic>?;
        final displayName = data['display_name'] as String?;

        if (addressMap != null) {
          final formatted = _formatVietnameseAddress(addressMap, displayName);
          if (formatted.isNotEmpty) {
            _addressCache[cacheKey] = formatted;
            return formatted;
          }
        }
      }
    } catch (_) {
      // Bỏ qua
    }

    // Fallback nếu không có kết nối mạng: trả về tọa độ nhưng KHÔNG lưu vào cache
    return 'Tọa độ: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  /// Trích xuất tên địa danh từ Photon properties
  String _formatPhotonAddress(Map<String, dynamic> props) {
    final name = (props['name'] as String?)?.trim();
    final street = (props['street'] as String?)?.trim();
    final housenumber = (props['housenumber'] as String?)?.trim();
    final locality = (props['locality'] as String?)?.trim();
    final district = (props['district'] as String?)?.trim();
    var city = (props['city'] as String?)?.trim() ?? (props['state'] as String?)?.trim();

    // Chuẩn hóa tên thành phố quen thuộc
    if (city != null) {
      final cityLower = city.toLowerCase();
      if (cityLower.contains('ho chi minh') || cityLower.contains('sài gòn')) {
        city = 'TP. Hồ Chí Minh';
      } else if (cityLower.contains('ha noi')) {
        city = 'Hà Nội';
      } else if (cityLower.contains('da nang')) {
        city = 'Đà Nẵng';
      }
    }

    final parts = <String>[];

    // Số nhà + Tên đường
    if (housenumber != null && housenumber.isNotEmpty && street != null && street.isNotEmpty) {
      parts.add('$housenumber $street');
    } else if (street != null && street.isNotEmpty) {
      parts.add(street);
    }

    // Tên địa danh cụ thể nếu có
    if (name != null && name.isNotEmpty) {
      final isRedundant = parts.contains(name) ||
          (street != null && name.contains(street)) ||
          name.toLowerCase() == 'hà nội' ||
          name.toLowerCase() == 'việt nam';
      if (!isRedundant) {
        parts.insert(0, name);
      }
    }

    // Khu phố / Phường xã nếu chưa có tên đường
    if (parts.isEmpty && locality != null && locality.isNotEmpty) {
      parts.add(locality);
    }

    // Quận / Huyện
    if (district != null && district.isNotEmpty && !parts.contains(district)) {
      parts.add(district);
    }

    // Tỉnh / Thành phố
    if (city != null && city.isNotEmpty && !parts.contains(city)) {
      parts.add(city);
    }

    return parts.join(', ');
  }

  /// Trích xuất tên địa danh ngắn gọn, quen thuộc theo phong cách Việt Nam (Nominatim)
  String _formatVietnameseAddress(
    Map<String, dynamic> addr,
    String? displayName,
  ) {
    final landmark = addr['amenity'] ??
        addr['leisure'] ??
        addr['tourism'] ??
        addr['building'] ??
        addr['park'] ??
        addr['historic'] ??
        '';

    final road = addr['road'] ?? addr['pedestrian'] ?? '';
    final subDistrict = addr['suburb'] ??
        addr['quarter'] ??
        addr['neighbourhood'] ??
        addr['village'] ??
        '';

    final district = addr['district'] ??
        addr['city_district'] ??
        addr['county'] ??
        '';

    final city = addr['city'] ?? addr['province'] ?? addr['state'] ?? '';

    final parts = <String>[];
    if (landmark.isNotEmpty) parts.add(landmark.toString());
    if (road.isNotEmpty && !parts.contains(road)) parts.add(road.toString());
    if (district.isNotEmpty) {
      parts.add(district.toString());
    } else if (subDistrict.isNotEmpty) {
      parts.add(subDistrict.toString());
    }
    if (city.isNotEmpty && parts.length < 3) parts.add(city.toString());

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(', ').take(3).join(', ');
    }

    return '';
  }

  /// Xin quyền vị trí và lấy tọa độ ước tính qua mạng IP
  Future<({double lat, double lng, String address})> getCurrentLocation() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        // Thử lấy vị trí mạng qua IP
        final ipRes = await _dio.get(
          'http://ip-api.com/json',
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );
        if (ipRes.statusCode == 200 && ipRes.data != null) {
          final data = ipRes.data is String
              ? jsonDecode(ipRes.data as String) as Map<String, dynamic>
              : ipRes.data as Map<String, dynamic>;

          if (data['status'] == 'success') {
            final lat = (data['lat'] as num?)?.toDouble();
            final lng = (data['lon'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              final addr = await getAddressFromCoordinates(lat, lng);
              return (lat: lat, lng: lng, address: addr);
            }
          }
        }
      }
    } catch (_) {
      // Fallback
    }

    // Mặc định về Hà Nội
    final addr = await getAddressFromCoordinates(defaultLat, defaultLng);
    return (lat: defaultLat, lng: defaultLng, address: addr);
  }
}
