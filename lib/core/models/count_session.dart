enum CountSessionStatus { draft, inProgress, submitted, approved }

enum CountEntryMethod { scanned, typed }

class CountSession {
  final String id;
  final String location;
  final String? label;
  final DateTime startedAt;
  final CountSessionStatus status;
  final List<CountItem> items;
  final String? locationId;
  final String? assignedWorkerId;
  final DateTime? deadline;
  final String? zoneAisle;

  const CountSession({
    required this.id,
    required this.location,
    this.label,
    required this.startedAt,
    required this.status,
    this.items = const [],
    this.locationId,
    this.assignedWorkerId,
    this.deadline,
    this.zoneAisle,
  });

  CountSession copyWith({
    CountSessionStatus? status,
    List<CountItem>? items,
    String? locationId,
    String? assignedWorkerId,
    DateTime? deadline,
    String? zoneAisle,
  }) =>
      CountSession(
        id: id,
        location: location,
        label: label,
        startedAt: startedAt,
        status: status ?? this.status,
        items: items ?? this.items,
        locationId: locationId ?? this.locationId,
        assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
        deadline: deadline ?? this.deadline,
        zoneAisle: zoneAisle ?? this.zoneAisle,
      );

  @override
  bool operator ==(Object other) => other is CountSession && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class CountItem {
  final String id;

  /// The server's item id; null in Sample mode.
  final String? itemId;
  final String itemCode;
  final String itemName;
  final int expected;
  final int counted;
  final CountEntryMethod entryMethod;

  CountItem({
    String? id,
    this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.expected,
    required this.counted,
    this.entryMethod = CountEntryMethod.scanned,
  }) : id = id ?? '${itemCode}_${DateTime.now().microsecondsSinceEpoch}';

  CountItem copyWith({int? counted}) => CountItem(
        id: id,
        itemId: itemId,
        itemCode: itemCode,
        itemName: itemName,
        expected: expected,
        counted: counted ?? this.counted,
        entryMethod: entryMethod,
      );

  int get variance => counted - expected;
  bool get matched => variance == 0;

  @override
  bool operator ==(Object other) => other is CountItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
