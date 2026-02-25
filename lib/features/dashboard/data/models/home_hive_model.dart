import 'package:hive/hive.dart';

part 'home_hive_model.g.dart';

@HiveType(typeId: 2)
class HomeHiveModel extends HiveObject {
	@HiveField(0)
	String id;

	@HiveField(1)
	String name;

	@HiveField(2)
	double price;

	@HiveField(3)
	int quantity;

	@HiveField(4)
	String image;

	@HiveField(5)
	String category;

	@HiveField(6)
	String description;

	@HiveField(7)
	String unit;

	@HiveField(8)
	String availability;

	HomeHiveModel({
		required this.id,
		required this.name,
		required this.price,
		required this.quantity,
		required this.image,
		required this.category,
		required this.description,
		required this.unit,
		required this.availability,
	});

	factory HomeHiveModel.fromApiModel(dynamic apiModel) {
		return HomeHiveModel(
			id: apiModel.id,
			name: apiModel.name,
			price: apiModel.price,
			quantity: apiModel.quantity,
			image: apiModel.image,
			category: apiModel.category,
			description: (apiModel.description != null && apiModel.description.isNotEmpty) ? apiModel.description : 'No description available.',
			unit: (apiModel.unit != null && apiModel.unit.isNotEmpty) ? apiModel.unit : 'Kg',
			availability: (apiModel.availability != null && apiModel.availability.isNotEmpty) ? apiModel.availability : 'Available',
		);
	}
}
