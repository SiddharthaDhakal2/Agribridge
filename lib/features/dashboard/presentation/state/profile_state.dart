import '../../domain/entities/profile_entity.dart';

class ProfileState {
  final ProfileEntity? profile;
  final bool isLoading;
  final String? error;

  ProfileState({this.profile, this.isLoading = false, this.error});

  ProfileState copyWith({ProfileEntity? profile, bool? isLoading, String? error}) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
