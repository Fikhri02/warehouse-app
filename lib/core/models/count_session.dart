enum CountSessionStatus { inProgress, submitted }

enum CountEntryMethod { scanned, typed }

class CountSession {
  final String id;
  final String location;
  final String? label;
  final DateTime startedAt;
  final CountSessionStatus status;
  final List<CountItem> items;

  const CountSession({
    required this.id,
    required this.location,
    this.label,
    required this.startedAt,
    required this.status,
    this.items = const [],
  });

  CountSession copyWith({
    CountSessionStatus? status,
    List<CountItem>? items,
  }) =>
      CountSession(
        id: id,
        location: location,
        label: label,
        startedAt: startedAt,
        status: status ?? this.status,
        items: items ?? this.items,
      );

  @override
  bool operator ==(Object other) => other is CountSession && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class CountItem {
  final String id;
  final String itemCode;
  final String itemName;
  final int expected;
  final int counted;
  final CountEntryMethod entryMethod;

  CountItem({
    String? id,
    required this.itemCode,
    required this.itemName,
    required this.expected,
    required this.counted,
    this.entryMethod = CountEntryMethod.scanned,
  }) : id = id ?? '${itemCode}_${DateTime.now().microsecondsSinceEpoch}';

  CountItem copyWith({int? counted}) => CountItem(
        id: id,
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
