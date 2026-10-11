import '../../domain/entities/household.dart';
import '../../domain/entities/household_invitation.dart';
import '../../domain/entities/household_join_request.dart';
import '../../domain/entities/household_lookup_result.dart';
import '../../domain/entities/user_lookup_result.dart';
import '../../domain/repositories/household_repository.dart';
import '../datasources/remote/household_remote_data_source.dart';

class HouseholdRepositoryImpl implements HouseholdRepository {
  final HouseholdRemoteDataSource remoteDataSource;

  HouseholdRepositoryImpl({required this.remoteDataSource});

  // --- Quản lý hộ gia đình ---

  @override
  Future<Household?> getMyHousehold() async {
    final data = await remoteDataSource.getMyHousehold();
    if (data == null) return null;
    return Household.fromJson(data);
  }

  @override
  Future<Household> createHousehold(String name) async {
    final data = await remoteDataSource.createHousehold(name);
    return Household.fromJson(data);
  }

  @override
  Future<Household> updateHousehold(String name) async {
    final data = await remoteDataSource.updateHousehold(name);
    return Household.fromJson(data);
  }

  @override
  Future<Household> transferOwnership(String newOwnerId) async {
    final data = await remoteDataSource.transferOwnership(newOwnerId);
    return Household.fromJson(data);
  }

  @override
  Future<void> deleteHousehold() {
    return remoteDataSource.deleteHousehold();
  }

  @override
  Future<void> leaveHousehold() {
    return remoteDataSource.leaveHousehold();
  }

  @override
  Future<void> removeMember(String targetUserId) {
    return remoteDataSource.removeMember(targetUserId);
  }

  // --- Lời mời trực tiếp (Direct Invitations) ---

  @override
  Future<UserLookupResult> lookupUser(String userId) async {
    final data = await remoteDataSource.lookupUser(userId);
    return UserLookupResult.fromJson(data);
  }

  @override
  Future<HouseholdInvitation> inviteDirect(String inviteeId) async {
    final data = await remoteDataSource.inviteDirect(inviteeId);
    return HouseholdInvitation.fromJson(data);
  }

  @override
  Future<List<HouseholdInvitation>> getSentInvitations() async {
    final list = await remoteDataSource.getSentInvitations();
    return list
        .map((item) => HouseholdInvitation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<HouseholdInvitation>> getReceivedInvitations() async {
    final list = await remoteDataSource.getReceivedInvitations();
    return list
        .map((item) => HouseholdInvitation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Household> acceptInvitation(String invitationId) async {
    final data = await remoteDataSource.acceptInvitation(invitationId);
    return Household.fromJson(data);
  }

  @override
  Future<void> rejectInvitation(String invitationId) {
    return remoteDataSource.rejectInvitation(invitationId);
  }

  @override
  Future<void> revokeInvitation(String invitationId) {
    return remoteDataSource.revokeInvitation(invitationId);
  }

  // --- Yêu cầu gia nhập (Join Requests) ---

  @override
  Future<HouseholdLookupResult> lookupHousehold(String householdId) async {
    final data = await remoteDataSource.lookupHousehold(householdId);
    return HouseholdLookupResult.fromJson(data);
  }

  @override
  Future<HouseholdJoinRequest> createJoinRequest(String householdId) async {
    final data = await remoteDataSource.createJoinRequest(householdId);
    return HouseholdJoinRequest.fromJson(data);
  }

  @override
  Future<List<HouseholdJoinRequest>> getMyJoinRequests() async {
    final list = await remoteDataSource.getMyJoinRequests();
    return list
        .map((item) => HouseholdJoinRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cancelMyJoinRequest(String requestId) {
    return remoteDataSource.cancelMyJoinRequest(requestId);
  }

  @override
  Future<List<HouseholdJoinRequest>> getHouseholdJoinRequests() async {
    final list = await remoteDataSource.getHouseholdJoinRequests();
    return list
        .map((item) => HouseholdJoinRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HouseholdMember> approveJoinRequest(String requestId) async {
    final data = await remoteDataSource.approveJoinRequest(requestId);
    return HouseholdMember.fromJson(data);
  }

  @override
  Future<void> rejectJoinRequest(String requestId) {
    return remoteDataSource.rejectJoinRequest(requestId);
  }
}
