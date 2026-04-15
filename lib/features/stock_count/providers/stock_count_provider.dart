import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/count_session.dart';
import '../../../data/repositories/stock_count_repository.dart';

export '../../../data/repositories/stock_count_repository.dart'
    show stockCountRepositoryProvider;

class StockCountNotifier extends Notifier<CountSession?> {
  @override
  CountSession? build() => null;

  Future<void> startSession({
    required String location,
    String? label,
  }) async {
    state = CountSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      location: location,
      label: label,
      startedAt: DateTime.now(),
      status: CountSessionStatus.inProgress,
    );
  }

  void addItem(CountItem item) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(items: [...current.items, item]);
  }

  Future<void> submitSession() async {
    final current = state;
    if (current == null) return;
    final toSubmit = current.copyWith(status: CountSessionStatus.submitted);
    await ref.read(stockCountRepositoryProvider).submitSession(toSubmit);
    state = null;
  }
}

final stockCountNotifierProvider =
    NotifierProvider<StockCountNotifier, CountSession?>(StockCountNotifier.new);
