import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/local/app_database.dart';
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/sync_coordinator.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

import '../../support/api_fakes.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<SyncCoordinator> coordinator(Future<http.Response> Function(http.Request) answer, void Function() onPulled) async {
    final client = ApiClient(baseUrl: testBaseUrl, tokens: await signedInTokens(), httpClient: MockClient(answer));
    return SyncCoordinator(
      outbox: SyncService(db: db),
      puller: ChangeFeedPuller(client: client, db: db),
      warehouseId: () => 'w1',
      onPulled: onPulled,
    );
  }

  test('a finished pull is announced, so open lists reload', () async {
    var pulled = 0;
    final sync = await coordinator((_) async => jsonResponse({'nextCursor': 0, 'hasMore': false, 'changes': []}), () => pulled++);

    await sync.syncNow();

    expect(pulled, 1);
  });

  test('a pull that could not reach the server is not announced', () async {
    var pulled = 0;
    final sync = await coordinator((_) async => throw http.ClientException('offline'), () => pulled++);

    await sync.syncNow();

    expect(pulled, 0);
  });
}
