class Location {
  final String id;
  final String name;
  final bool hasZones;
  final List<String> zones;

  const Location({
    required this.id,
    required this.name,
    required this.hasZones,
    this.zones = const [],
  });
}
