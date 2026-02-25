
class HomeApiModel {
	final String id;
	final String name;
	final double price;
	final int quantity;
	final String image;
	final String category;
	final String description;
	final String unit;
	final String availability;

	HomeApiModel({
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

	       factory HomeApiModel.fromJson(Map<String, dynamic> json) {
		       return HomeApiModel(
			       id: json['_id'] ?? '',
			       name: json['name'] ?? '',
			       price: (json['price'] is int)
				       ? (json['price'] as int).toDouble()
				       : (json['price'] as num?)?.toDouble() ?? 0.0,
			       quantity: json['quantity'] ?? 0,
			       image: json['image'] ?? '',
			       category: json['category'] ?? '',
			       description: (json['description'] as String?)?.isNotEmpty == true ? json['description'] : 'No description available.',
			       unit: (json['unit'] as String?)?.isNotEmpty == true ? json['unit'] : 'Kg',
			       availability: (json['availability'] as String?)?.isNotEmpty == true ? json['availability'] : 'Available',
		       );
	       }
}
