import 'package:hive/hive.dart';
import '../../models/home_hive_model.dart';
import 'package:agribridge/core/constants/hive_table_constants.dart';

class HomeLocalDatasource {
	Box<HomeHiveModel> get _productBox => Hive.box<HomeHiveModel>(HiveTableConstant.productTable);

	Future<void> cacheProducts(List<HomeHiveModel> products) async {
		await _productBox.clear();
		for (var product in products) {
			await _productBox.put(product.id, product);
		}
	}

	List<HomeHiveModel> getCachedProducts() {
		return _productBox.values.toList();
	}
}
