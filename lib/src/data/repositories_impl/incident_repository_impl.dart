import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/entities/incident.dart';
import '../../domain/repositories/incident_repository.dart';
import '../datasources/remote/incident_remote_data_source.dart';
import '../models/incident_model.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource remoteDataSource;

  IncidentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Incident>> getIncidents({
    String status = 'all',
    int limit = 50,
    int offset = 0,
  }) async {
    final rawList = await remoteDataSource.getIncidents(
      status: status,
      limit: limit,
      offset: offset,
    );
    return rawList
        .map((e) => Incident.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Incident>> getMyIncidents() async {
    final rawList = await remoteDataSource.getMyIncidents();
    return rawList
        .map((e) => Incident.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Incident> getIncidentById(String incidentId) async {
    final raw = await remoteDataSource.getIncidentById(incidentId);
    return Incident.fromJson(raw);
  }

  @override
  Future<Incident> submitIncident(CreateIncidentRequest request) async {
    if (request.filePaths.isNotEmpty) {
      final formData = await request.toFormData();
      final raw = await remoteDataSource.submitIncident(formData);
      return Incident.fromJson(raw);
    } else {
      final raw = await remoteDataSource.submitIncidentJson(request.toJson());
      return Incident.fromJson(raw);
    }
  }

  @override
  Future<IncidentEvidence> uploadEvidence({
    required String incidentId,
    required String filePath,
  }) async {
    final filename = filePath.split(Platform.pathSeparator).last;
    final file = await MultipartFile.fromFile(filePath, filename: filename);
    final raw = await remoteDataSource.uploadEvidence(
      incidentId: incidentId,
      file: file,
    );
    return IncidentEvidence.fromJson(raw);
  }

  @override
  Future<List<IncidentEvidence>> uploadMultipleEvidences({
    required String incidentId,
    required List<String> filePaths,
  }) async {
    final multipartFiles = <MultipartFile>[];
    for (final path in filePaths) {
      if (path.isEmpty) continue;
      final filename = path.split(Platform.pathSeparator).last;
      multipartFiles.add(
        await MultipartFile.fromFile(path, filename: filename),
      );
    }
    final rawList = await remoteDataSource.uploadMultipleEvidences(
      incidentId: incidentId,
      files: multipartFiles,
    );
    return rawList
        .map((e) => IncidentEvidence.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Incident> updateIncidentStatus({
    required String incidentId,
    required UpdateIncidentStatusRequest request,
  }) async {
    final raw = await remoteDataSource.updateIncidentStatus(
      incidentId: incidentId,
      data: request.toJson(),
    );
    return Incident.fromJson(raw);
  }
}
