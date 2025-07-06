// lib/services/geoapify_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pphonedex/models/store_model.dart';

class GeoapifyService {
  final String apiKey;

  GeoapifyService(this.apiKey);

  Future<List<Store>> findNearbyStores(double lat, double lon) async {
    // Busca por lojas de celular num raio de 5km (5000 metros)
    final url = Uri.parse(
        'https://api.geoapify.com/v2/places?categories=adult.casino&filter=circle:$lon,$lat,5000&bias=proximity:$lon,$lat&apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List;
      
      // Usa a fábrica corrigida do store_model
      return features
          .map((feature) => Store.fromGeoapifyJson(feature as Map<String, dynamic>))
          .toList();
    } else {
      // Lança uma exceção mais clara em caso de erro na API
      throw Exception('Falha ao carregar lojas: ${response.body}');
    }
  }
}