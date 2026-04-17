enum PoStatus { pending, inProgress, received }

enum PoLineItemStatus { pending, confirmed, flagged }

class PurchaseOrder {
  final String id;
  final String supplier;
  final PoStatus status;
  final List<PoLineItem> lineItems;
  final DateTime? dueDate;
  final DateTime? receivedAt;

  const PurchaseOrder({
    required this.id,
    required this.supplier,
    required this.status,
    this.lineItems = const [],
    this.dueDate,
    this.receivedAt,
  });

  bool get hasFlagged => lineItems.any((i) => i.flagged);
  int get receivedCount => lineItems.where((i) => i.received != null).length;

  List<PoLineItem> get shortItems => lineItems
      .where((i) => !i.flagged && (i.received ?? 0) < i.expected)
      .toList();

  List<PoLineItem> get extraItems => lineItems
      .where((i) => !i.flagged && (i.received ?? 0) > i.expected)
      .toList();

  bool get allFulfilled =>
      !hasFlagged && shortItems.isEmpty && extraItems.isEmpty;

  @override
  bool operator ==(Object other) => other is PurchaseOrder && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class PoLineItem {
  final String itemCode;
  final String itemName;
  final int expected;
  final int? received;
  final bool flagged;
  final String? flagReason;
  final PoLineItemStatus lineStatus;

  const PoLineItem({
    required this.itemCode,
    required this.itemName,
    required this.expected,
    this.received,
    this.flagged = false,
    this.flagReason,
    this.lineStatus = PoLineItemStatus.pending,
  });

  int get variance => (received ?? 0) - expected;

  PoLineItem copyWith({
    int? received,
    bool? flagged,
    String? flagReason,
    PoLineItemStatus? lineStatus,
  }) =>
      PoLineItem(
        itemCode: itemCode,
        itemName: itemName,
        expected: expected,
        received: received ?? this.received,
        flagged: flagged ?? this.flagged,
        flagReason: flagReason ?? this.flagReason,
        lineStatus: lineStatus ?? this.lineStatus,
      );

  @override
  bool operator ==(Object other) =>
      other is PoLineItem &&
      other.itemCode == itemCode &&
      other.received == received &&
      other.lineStatus == lineStatus;

  @override
  int get hashCode => Object.hash(itemCode, received, lineStatus);
}
