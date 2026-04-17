class Worker {
  final String id;
  final String name;
  final String role; // 'supervisor' or 'worker'

  const Worker({
    required this.id,
    required this.name,
    required this.role,
  });
}
