// lib/models/store_model.dart

class Store {
  final String name;
  final double lat;
  final double lon;

  Store({required this.name, required this.lat, required this.lon});

  // FÁBRICA CORRIGIDA PARA SER MAIS SEGURA
  factory Store.fromGeoapifyJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>;
    return Store(
      name: properties['name'] ?? 'Loja sem nome',
      // Converte 'num' (int ou double) para 'double' de forma segura
      lat: (properties['lat'] as num).toDouble(),
      lon: (properties['lon'] as num).toDouble(),
    );
  }
}