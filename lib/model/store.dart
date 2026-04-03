class Store {
  final String id;
  final String name;
  final double lat;
  final double lng;

  Store({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory Store.fromMap(Map<String, dynamic> map, String id) {
  return Store(
    id: id,
    name: map['name'] ?? '',
    lat: (map['lat'] ?? 0).toDouble(),
    lng: (map['lng'] ?? 0).toDouble(),
  );
}
}