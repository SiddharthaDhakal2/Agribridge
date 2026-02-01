import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/save_profile_image_usecase.dart';
import '../state/profile_state.dart';

class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final SaveProfileImageUseCase saveProfileImageUseCase;

  ProfileViewModel({required this.getProfileUseCase, required this.saveProfileImageUseCase}) : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await getProfileUseCase();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> saveProfileImage(String imagePath, String customerId) async {
    state = state.copyWith(isLoading: true);
    try {
      await saveProfileImageUseCase(imagePath, customerId);
      await loadProfile();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
