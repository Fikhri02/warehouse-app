import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/alert.dart';
import 'package:warehouse_app/features/alerts/providers/alerts_provider.dart';
import 'package:warehouse_app/data/repositories/alerts_repository.dart';

class MockAlertsRepository extends Mock implements AlertsRepository {}

void main() {
  late MockAlertsRepository mockRepo;

  setUp(() {
    mockRepo = MockAlertsRepository();
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [alertsRepositoryProvider.overrideWithValue(mockRepo)],
    );
  }

  final sampleAlerts = [
    Alert(
      id: 'a1',
      type: AlertType.lowStock,
      title: 'Low Stock: Widget A',
      body: 'Qty dropped to 5, threshold is 10',
      createdAt: DateTime(2026, 4, 15, 9),
      isRead: false,
    ),
    Alert(
      id: 'a2',
      type: AlertType.taskAssigned,
      title: 'Task Assigned',
      body: 'Count Zone B assigned to you',
      createdAt: DateTime(2026, 4, 15, 8),
      isRead: true,
    ),
  ];

  test('loads alerts on build', () async {
    when(() => mockRepo.getAlerts()).thenAnswer((_) async => sampleAlerts);
    final container = makeContainer();
    addTearDown(container.dispose);

    await container.read(alertsProvider.future);
    final state = container.read(alertsProvider);

    expect(state.valueOrNull?.all.length, 2);
    expect(state.valueOrNull?.unreadCount, 1);
  });

  test('markAllRead calls repo and state is refreshed', () async {
    final markedAlerts = sampleAlerts.map((a) => a.copyWith(isRead: true)).toList();
    var callCount = 0;
    when(() => mockRepo.getAlerts()).thenAnswer((_) async {
      callCount++;
      return callCount == 1 ? sampleAlerts : markedAlerts;
    });
    when(() => mockRepo.markAllRead()).thenAnswer((_) async {});

    final container = makeContainer();
    addTearDown(container.dispose);

    await container.read(alertsProvider.future);
    await container.read(alertsProvider.notifier).markAllRead();
    await container.read(alertsProvider.future);

    verify(() => mockRepo.markAllRead()).called(1);
    expect(container.read(alertsProvider).valueOrNull?.unreadCount, 0);
  });

  test('filterByType returns only matching alerts', () async {
    when(() => mockRepo.getAlerts()).thenAnswer((_) async => sampleAlerts);
    final container = makeContainer();
    addTearDown(container.dispose);

    await container.read(alertsProvider.future);
    container.read(alertsProvider.notifier).setFilter(AlertFilter.stock);
    final state = container.read(alertsProvider);

    expect(state.valueOrNull?.filtered.length, 1);
    expect(state.valueOrNull?.filtered.first.type, AlertType.lowStock);
  });
}
