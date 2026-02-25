import '../models/home_api_model.dart';
import '../models/home_hive_model.dart';

abstract class HomeDatasource {
	Future<List<HomeApiModel>> fetchProducts();
	Future<void> cacheProducts(List<HomeHiveModel> products);
	List<HomeHiveModel> getCachedProducts();
}
