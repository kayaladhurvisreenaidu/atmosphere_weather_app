class Place {
  const Place({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1 = '',
  });

  final String name;
  final String country;
  final String admin1;
  final double latitude;
  final double longitude;

  String get displayName => admin1.isEmpty
      ? '$name, $country'
      : '$name, $admin1, $country';

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'admin1': admin1,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        name: json['name'] as String? ?? 'Unknown',
        country: json['country'] as String? ?? '',
        admin1: json['admin1'] as String? ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}
