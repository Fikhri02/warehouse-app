/// An item as counting needs it: the server's id, plus what to show.
class CatalogItemRef {
  const CatalogItemRef({required this.id, required this.sku, required this.name});

  final String id;
  final String sku;
  final String name;
}

/// Where a count happens: a bin, zone or dock of the warehouse.
class CountLocation {
  const CountLocation({required this.id, required this.code, required this.kind});

  final String id;
  final String code;
  final String kind;
}

enum CountProgress { sending, notAccepted, waitingReview, approved, rejected }

/// One count as its counter, or a supervisor, sees it in a list.
class CountSummary {
  const CountSummary({
    required this.id,
    required this.title,
    required this.lineCount,
    required this.progress,
    this.submittedAt,
    this.note,
  });

  final String id;
  final String title;
  final int lineCount;
  final CountProgress progress;
  final DateTime? submittedAt;

  /// The supervisor's reason for a rejection, or the server's reason for refusing it.
  final String? note;
}

/// A submitted count as a supervisor reviews it (live figures from the server).
class CountReview {
  const CountReview({required this.id, required this.title, required this.countedBy, required this.submittedAt, required this.status, required this.lines});

  final String id;
  final String title;
  final String countedBy;
  final DateTime submittedAt;
  final String status;
  final List<CountReviewLine> lines;

  /// Lines where stock moved since the count was submitted.
  int get movedLines => lines.where((l) => l.current != l.systemAtSubmit).length;

  /// Lines approval would change.
  int get changingLines => lines.where((l) => l.difference != 0).length;
}

class CountReviewLine {
  const CountReviewLine({
    required this.itemName,
    required this.sku,
    required this.locationCode,
    required this.counted,
    required this.systemAtSubmit,
    required this.current,
    required this.difference,
  });

  final String itemName;
  final String sku;
  final String locationCode;
  final double counted;
  final double systemAtSubmit;
  final double current;
  final double difference;
}

/// "8", "2.5", "-3": quantities without a trailing ".0".
String formatQty(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();
