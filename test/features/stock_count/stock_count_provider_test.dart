import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/count_session.dart';
import 'package:warehouse_app/data/repositories/stock_count_repository.dart';
import 'package:warehouse_app/features/stock_count/providers/stock_count_provider.dart';

class MockStockCountRepository extends Mock implements StockCountRepository {}

void main() {
  late MockStockCountRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockStockCountRepository();
    registerFallbackValue(CountSession(
      id: 'x',
      location: 'L',
      startedAt: DateTime.now(),
      status: CountSessionStatus.inProgress,
    ));
    container = ProviderContainer(
      overrides: [stockCountRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() => container.dispose());

  group('StockCountNotifier.build', () {
    test('initial state is null (no active session)', () {
      expect(container.read(stockCountNotifierProvider), isNull);
    });
  });

  group('StockCountNotifier.startSession', () {
    test('creates session with given location and in-progress status', () async {
      await container
          .read(stockCountNotifierProvider.notifier)
          .startSession(location: 'Aisle B', label: null);

      final state = container.read(stockCountNotifierProvider);
      expect(state, isNotNull);
      expect(state!.location, equals('Aisle B'));
      expect(state.status, equals(CountSessionStatus.inProgress));
      expect(state.items, isEmpty);
    });
  });

  group('StockCountNotifier.addItem', () {
    test('appends a CountItem to the session', () async {
      await container
          .read(stockCountNotifierProvider.notifier)
          .startSession(location: 'Aisle B', label: null);

      container.read(stockCountNotifierProvider.notifier).addItem(
            CountItem(
              itemCode: 'WH-001',
              itemName: 'Test',
              expected: 10,
              counted: 8,
            ),
          );

      final state = container.read(stockCountNotifierProvider);
      expect(state!.items.length, equals(1));
      expect(state.items.first.itemCode, equals('WH-001'));
    });
  });

  group('StockCountNotifier.submitSession', () {
    test('submits session with submitted status and resets state to null', () async {
      when(() => mockRepo.submitSession(any())).thenAnswer((_) async {});

      await container
          .read(stockCountNotifierProvider.notifier)
          .startSession(location: 'Aisle B', label: null);

      await container.read(stockCountNotifierProvider.notifier).submitSession();

      verify(() => mockRepo.submitSession(
            any(
              that: predicate<CountSession>(
                (s) =>
                    s.location == 'Aisle B' &&
                    s.status == CountSessionStatus.submitted,
              ),
            ),
          )).called(1);

      expect(container.read(stockCountNotifierProvider), isNull);
    });
  });
}
