import '../../domain/entities/profile_entity.dart';

class ProfileState {
  static const Object _sentinel = Object();

  final ProfileEntity? profile;
  final bool isLoading;
  final String? error;

  ProfileState({this.profile, this.isLoading = false, this.error});

  ProfileState copyWith({
    Object? profile = _sentinel,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return ProfileState(
      profile: identical(profile, _sentinel)
          ? this.profile
          : profile as ProfileEntity?,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}
