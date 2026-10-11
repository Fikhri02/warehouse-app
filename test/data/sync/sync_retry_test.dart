import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';

void main() {
  test('a_paused_outbox_is_tried_again_while_changes_wait', () async {
    var pending = 0;
    var syncs = 0;
    final retry = SyncRetry(pending: () async => pending, sync: () async => syncs++);

    await retry.tick();
    expect(syncs, 0); // nothing waiting: no traffic

    pending = 2;
    await retry.tick();
    expect(syncs, 1);
  });
}
