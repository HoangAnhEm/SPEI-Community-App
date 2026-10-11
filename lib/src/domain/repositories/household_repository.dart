import '../entities/household.dart';
import '../entities/household_invitation.dart';
import '../entities/household_join_request.dart';
import '../entities/household_lookup_result.dart';
import '../entities/user_lookup_result.dart';

abstract class HouseholdRepository {
  // --- Quản lý hộ gia đình ---
  Future<Household?> getMyHousehold();
  Future<Household> createHousehold(String name);
  Future<Household> updateHousehold(String name);
  Future<Household> transferOwnership(String newOwnerId);
  Future<void> deleteHousehold();
  Future<void> leaveHousehold();
  Future<void> removeMember(String targetUserId);

  Future<UserLookupResult> lookupUser({
    String? userId,
    String? phoneNumber,
    String? email,
  });
  Future<HouseholdInvitation> inviteDirect(String inviteeId);
  Future<List<HouseholdInvitation>> getSentInvitations();
  Future<List<HouseholdInvitation>> getReceivedInvitations();
  Future<Household> acceptInvitation(String invitationId);
  Future<void> rejectInvitation(String invitationId);
  Future<void> revokeInvitation(String invitationId);

  // --- Yêu cầu gia nhập (Join Requests) ---
  Future<HouseholdLookupResult> lookupHousehold(String householdId);
  Future<HouseholdJoinRequest> createJoinRequest(String householdId);
  Future<List<HouseholdJoinRequest>> getMyJoinRequests();
  Future<void> cancelMyJoinRequest(String requestId);
  Future<List<HouseholdJoinRequest>> getHouseholdJoinRequests();
  Future<HouseholdMember> approveJoinRequest(String requestId);
  Future<void> rejectJoinRequest(String requestId);
}
