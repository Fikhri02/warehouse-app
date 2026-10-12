enum PoStatus { pending, inProgress, received }

enum PoLineItemStatus { pending, confirmed, flagged }

class PurchaseOrder {
  final String id;

  /// The order number to show; Sample orders use their id.
  final String? number;
  final String supplier;
  final PoStatus status;
  final List<PoLineItem> lineItems;
  final DateTime? dueDate;
  final DateTime? receivedAt;

  const PurchaseOrder({
    required this.id,
    this.number,
    required this.supplier,
    required this.status,
    this.lineItems = const [],
    this.dueDate,
    this.receivedAt,
  });

  String get displayNumber => number ?? id;

  /// The same order with these lines (a receiving session in progress).
  PurchaseOrder copyWithLines(List<PoLineItem> lines) => PurchaseOrder(
        id: id,
        number: number,
        supplier: supplier,
        status: status,
        lineItems: lines,
        dueDate: dueDate,
        receivedAt: receivedAt,
      );

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

  /// The server's order line and item; null for Sample orders and for items added that are not on the order.
  final String? lineId;
  final String? itemId;

  /// Barcodes of the item, so a scan finds its line.
  final List<String> barcodes;

  /// Received before this session (the server's figure plus receipts still waiting to be sent).
  final int alreadyReceived;

  const PoLineItem({
    required this.itemCode,
    required this.itemName,
    required this.expected,
    this.received,
    this.flagged = false,
    this.flagReason,
    this.lineStatus = PoLineItemStatus.pending,
    this.lineId,
    this.itemId,
    this.barcodes = const [],
    this.alreadyReceived = 0,
  });

  int get variance => (received ?? 0) - expected;

  bool matches(String code) => itemCode == code || barcodes.contains(code);

  /// What this session adds on top of what was already received.
  int get receivingNow => (received ?? 0) - alreadyReceived;

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
        lineId: lineId,
        itemId: itemId,
        barcodes: barcodes,
        alreadyReceived: alreadyReceived,
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
