import '../entities/emission_details.dart';
import '../entities/emission_result.dart';
import '../entities/household_emission.dart';

abstract class EmissionRepository {
  /// Tính toán phát thải từ payload các loại (Điện, Gas, Phương tiện, Rác, Chất làm lạnh)
  Future<EmissionResultResponse> calculateEmission(CalculateEmissionRequest request);

  /// Lấy danh sách các bản ghi phát thải tháng hiện tại của hộ gia đình
  Future<List<HouseholdEmission>> getHouseholdCurrentEmissions();

  /// Lấy danh sách các bản ghi phát thải của hộ gia đình theo kỳ năm và tháng
  Future<List<HouseholdEmission>> getHouseholdEmissionsByPeriod({
    required int year,
    required int month,
  });

  /// Lấy lịch sử phát thải của hộ gia đình theo thứ tự thời gian giảm dần
  Future<List<HouseholdEmission>> getHouseholdEmissionHistory({int limit = 12});

  /// Ghi nhận chỉ số phát thải tháng cho hộ gia đình
  Future<HouseholdEmission> recordHouseholdEmission(RecordHouseholdEmissionRequest request);

  /// Chỉnh sửa bản ghi phát thải hộ gia đình
  Future<HouseholdEmission> updateHouseholdEmission({
    required String emissionId,
    required UpdateHouseholdEmissionRequest request,
  });

  /// Xóa bản ghi phát thải hộ gia đình
  Future<void> deleteHouseholdEmission(String emissionId);
}
