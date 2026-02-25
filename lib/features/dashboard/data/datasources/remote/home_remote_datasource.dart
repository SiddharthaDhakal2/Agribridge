import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/home_api_model.dart';

class HomeRemoteDatasource {
	final String baseUrl;

	HomeRemoteDatasource({required this.baseUrl});

	Future<List<HomeApiModel>> fetchProducts() async {
		final response = await http.get(Uri.parse('$baseUrl/api/products'));
		print('Product API response: \n${response.body}'); // Debug print
		if (response.statusCode == 200) {
			final data = json.decode(response.body);
			if (data['success'] == true && data['data'] is List) {
				return (data['data'] as List)
						.map((item) => HomeApiModel.fromJson(item))
						.toList();
			} else {
				throw Exception('Invalid response format');
			}
		} else {
			throw Exception('Failed to fetch products');
		}
	}
}
