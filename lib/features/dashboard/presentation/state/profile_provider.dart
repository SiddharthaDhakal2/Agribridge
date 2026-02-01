import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/features/dashboard/presentation/state/profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/profile_view_model.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/save_profile_image_usecase.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../data/datasources/remote/profile_remote_datasource.dart';

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>(
  (ref) {
    // Set up all dependencies here
    final apiClient = ref.read(apiClientProvider);
    final remoteDataSource = ProfileRemoteDataSourceImpl(apiClient: apiClient);
    final localDataSource = ProfileDataSource();
    final repository = ProfileRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
    final getProfileUseCase = GetProfileUseCase(repository);
    final saveProfileImageUseCase = SaveProfileImageUseCase(repository);
    return ProfileViewModel(
      getProfileUseCase: getProfileUseCase,
      saveProfileImageUseCase: saveProfileImageUseCase,
    );
  },
);