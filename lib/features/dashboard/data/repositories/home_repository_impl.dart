import '../datasources/remote/home_remote_datasource.dart';
import '../datasources/local/home_local_datasource.dart';
// ...existing code...
import '../models/home_hive_model.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
	final HomeRemoteDatasource remoteDatasource;
	final HomeLocalDatasource localDatasource;

	HomeRepositoryImpl({
		required this.remoteDatasource,
		required this.localDatasource,
	});

	@override
	Future<List<HomeEntity>> getProducts() async {
		try {
			final remoteProducts = await remoteDatasource.fetchProducts();
			final hiveModels = remoteProducts.map((e) => HomeHiveModel.fromApiModel(e)).toList();
			await localDatasource.cacheProducts(hiveModels);
			return remoteProducts
				.map((e) => HomeEntity(
					  id: e.id,
					  name: e.name,
					  price: e.price,
					  quantity: e.quantity,
					  image: e.image,
					  category: e.category,
					  description: e.description,
					  unit: e.unit,
					  availability: e.availability,
					))
				.toList();
		} catch (e) {
			// On error, fallback to local cache
			final cached = localDatasource.getCachedProducts();
			return cached
				.map((e) => HomeEntity(
					  id: e.id,
					  name: e.name,
					  price: e.price,
					  quantity: e.quantity,
					  image: e.image,
					  category: e.category,
					  description: e.description,
					  unit: e.unit,
					  availability: e.availability,
					))
				.toList();
		}
	}
}
