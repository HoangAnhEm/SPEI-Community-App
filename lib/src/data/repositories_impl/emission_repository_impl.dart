import '../../domain/entities/emission_details.dart';
import '../../domain/entities/emission_result.dart';
import '../../domain/entities/household_emission.dart';
import '../../domain/repositories/emission_repository.dart';
import '../datasources/remote/emission_remote_data_source.dart';

class EmissionRepositoryImpl implements EmissionRepository {
  final EmissionRemoteDataSource remoteDataSource;

  EmissionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<EmissionResultResponse> calculateEmission(
    CalculateEmissionRequest request,
  ) async {
    final data = await remoteDataSource.calculateEmission(request);
    return EmissionResultResponse.fromJson(data);
  }

  @override
  Future<List<HouseholdEmission>> getHouseholdCurrentEmissions() async {
    final data = await remoteDataSource.getHouseholdCurrentEmissions();
    return data
        .map((item) => HouseholdEmission.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<HouseholdEmission>> getHouseholdEmissionsByPeriod({
    required int year,
    required int month,
  }) async {
    final data = await remoteDataSource.getHouseholdEmissionsByPeriod(
      year: year,
      month: month,
    );
    return data
        .map((item) => HouseholdEmission.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<HouseholdEmission>> getHouseholdEmissionHistory({int limit = 12}) async {
    final data = await remoteDataSource.getHouseholdEmissionHistory(limit: limit);
    return data
        .map((item) => HouseholdEmission.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HouseholdEmission> recordHouseholdEmission(
    RecordHouseholdEmissionRequest request,
  ) async {
    final data = await remoteDataSource.recordHouseholdEmission(request);
    return HouseholdEmission.fromJson(data);
  }
}
