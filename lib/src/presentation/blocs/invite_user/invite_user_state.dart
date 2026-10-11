import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_lookup_result.dart';

enum UserSearchStatus { initial, loading, success, failure }
enum SendInviteStatus { initial, loading, success, failure }

class InviteUserState extends Equatable {
  final UserSearchStatus searchStatus;
  final UserLookupResult? searchedUser;
  final String? searchError;
  final SendInviteStatus inviteStatus;
  final String? inviteMessage;
  final bool hasInvited;

  const InviteUserState({
    this.searchStatus = UserSearchStatus.initial,
    this.searchedUser,
    this.searchError,
    this.inviteStatus = SendInviteStatus.initial,
    this.inviteMessage,
    this.hasInvited = false,
  });

  InviteUserState copyWith({
    UserSearchStatus? searchStatus,
    UserLookupResult? searchedUser,
    String? searchError,
    SendInviteStatus? inviteStatus,
    String? inviteMessage,
    bool? hasInvited,
    bool clearSearchedUser = false,
  }) {
    return InviteUserState(
      searchStatus: searchStatus ?? this.searchStatus,
      searchedUser: clearSearchedUser ? null : (searchedUser ?? this.searchedUser),
      searchError: searchError,
      inviteStatus: inviteStatus ?? this.inviteStatus,
      inviteMessage: inviteMessage,
      hasInvited: hasInvited ?? this.hasInvited,
    );
  }

  @override
  List<Object?> get props => [
        searchStatus,
        searchedUser,
        searchError,
        inviteStatus,
        inviteMessage,
        hasInvited,
      ];
}
