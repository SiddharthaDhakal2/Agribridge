import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/usecases/home_usecase.dart';
import '../../../dashboard/data/datasources/remote/home_remote_datasource.dart';
import '../../../dashboard/data/datasources/local/home_local_datasource.dart';
import '../../../dashboard/data/repositories/home_repository_impl.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, AsyncValue<List<HomeEntity>>>((ref) {
	final remote = HomeRemoteDatasource(baseUrl: ApiEndpoints.serverUrl);
	final local = HomeLocalDatasource();
	final repo = HomeRepositoryImpl(remoteDatasource: remote, localDatasource: local);
	final usecase = GetHomeProductsUseCase(repo);
	return HomeNotifier(usecase);
});

class HomeNotifier extends StateNotifier<AsyncValue<List<HomeEntity>>> {
	final GetHomeProductsUseCase usecase;

	HomeNotifier(this.usecase) : super(const AsyncValue.loading()) {
		fetchProducts();
	}

	Future<void> fetchProducts() async {
		state = const AsyncValue.loading();
		try {
			final products = await usecase();
			state = AsyncValue.data(products);
		} catch (e, st) {
			state = AsyncValue.error(e, st);
		}
	}
}
