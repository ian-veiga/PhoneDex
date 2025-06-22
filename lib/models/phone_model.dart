class Phone {
  final String id;
  final String name;
  final String imageUrl;
  final String storage;
  final String ram;
  final String processor;
  final String battery;
  final String camera;

  Phone({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.storage,
    required this.ram,
    required this.processor,
    required this.battery,
    required this.camera,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'storage': storage,
      'ram': ram,
      'processor': processor,
      'battery': battery,
      'camera': camera,
    };
  }

  factory Phone.fromMap(Map<String, dynamic> map, String id) {
    return Phone(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      storage: map['storage'] ?? '',
      ram: map['ram'] ?? '',
      processor: map['processor'] ?? '',
      battery: map['battery'] ?? '',
      camera: map['camera'] ?? '',
    );
  }
}