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

  test('while the app is open and online it checks for news every 5 minutes, counted from the last sync', () async {
    var syncs = 0;
    var now = DateTime(2026, 10, 14, 9);
    final retry = SyncRetry(pending: () async => 0, sync: () async => syncs++, canPull: () => true, now: () => now);

    retry.pulled(); // the sync at sign-in
    now = now.add(const Duration(minutes: 4));
    await retry.tick();
    expect(syncs, 0);

    now = now.add(const Duration(minutes: 1));
    await retry.tick();
    expect(syncs, 1);
  });

  test('in the background or offline it never syncs just to check for news', () async {
    var syncs = 0;
    var now = DateTime(2026, 10, 14, 9);
    final retry = SyncRetry(pending: () async => 0, sync: () async => syncs++, canPull: () => false, now: () => now);

    retry.pulled();
    now = now.add(const Duration(minutes: 30));
    await retry.tick();

    expect(syncs, 0);
  });

  test('the 5 minutes count from when the check started, so it runs every 5 minutes, not every 6', () async {
    var syncs = 0;
    var now = DateTime(2026, 10, 14, 9);
    late SyncRetry retry;
    retry = SyncRetry(
      pending: () async => 0,
      sync: () async {
        syncs++;
        now = now.add(const Duration(seconds: 3)); // the pull takes a moment
        retry.pulled();
      },
      canPull: () => true,
      now: () => now,
    );

    await retry.tick(); // first check: never pulled yet
    expect(syncs, 1);
    now = DateTime(2026, 10, 14, 9, 5); // the 5th tick after it
    await retry.tick();

    expect(syncs, 2);
  });

  test('a check that could not reach the server waits 5 minutes before trying again, not 1', () async {
    var syncs = 0;
    var now = DateTime(2026, 10, 14, 9);
    final retry = SyncRetry(pending: () async => 0, sync: () async => syncs++, canPull: () => true, now: () => now);

    await retry.tick(); // starts a sync whose pull never completes
    now = now.add(const Duration(minutes: 1));
    await retry.tick();
    expect(syncs, 1);

    now = now.add(const Duration(minutes: 4));
    await retry.tick();
    expect(syncs, 2);
  });
}
