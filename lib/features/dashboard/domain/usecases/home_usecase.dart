import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeProductsUseCase {
	final HomeRepository repository;

	GetHomeProductsUseCase(this.repository);

	Future<List<HomeEntity>> call() async {
		return await repository.getProducts();
	}
}
