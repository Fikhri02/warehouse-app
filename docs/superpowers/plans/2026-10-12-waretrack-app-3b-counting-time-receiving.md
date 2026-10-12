# WareTrack App 3b — Counting Time and Receiving Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:**
- **Counting time.** An offline count is compared with stock as it was when it was counted, not when it reached the server.
- **Receiving against the server.** Purchase orders come from the server. Receipts and signatures queue on the phone and are sent in order. A receipt waiting to be sent already shows on its order, so nobody receives the same goods twice.

**Architecture:**
- **Server, counting time.** `SubmitCountRequest` gains an optional `CountedAt`. The server takes `SystemAtSubmit` from the ledger as it stood then: today's level minus every movement since. It stores `CountedAt` and returns it on count DTOs.
- **App, counting time.** Count submits carry `countedAt`, the moment the counter tapped Submit.
- **App, mirror version.** A mirror version on `sync_cursors` makes every phone re-read its change feed from the start whenever the app begins storing an entity it used to skip. 3b bumps it for purchase orders.
- **App, receiving.**
  - `ApiReceivingRepository` reads purchase orders from the Drift copy and queues `receipt.create` and `receipt.signature` commands.
  - The signature is a PNG kept in the queued command, so a retry sends the same bytes under the same key.
  - Sending: the receipt is a JSON POST; the signature is a multipart PUT.

**Tech Stack:**
- **Server:** .NET 10 minimal APIs, EF Core 10 + Npgsql, xUnit + Testcontainers.
- **App:** Flutter 3.38.6 / Dart 3.10.7, Riverpod 2.6, go_router 14, drift 2.21, http 1.6, uuid 4.6, signature 5.5, mocktail.

**Repos:**
- **Server:** `~/projects/Personal/DotNet/waretrack-server` @ `api-foundation` `a8e3220`.
- **App:** `~/projects/Personal/Flutter/warehouse_app` @ `feature/order-management` `e733a61` (3a merged).

**Spec:** `/Users/irfanfikhribiniszahar/projects/Personal/AI/memory-core-fresh/brainstorming/active/warehouse-app-backend.md`.
- §2: `Receipt` + `ReceiptLine`, optional signature PNG; `CountSession` + `CountLine`.
- §3: receipts and signature commands; idempotency; response table.
- §6: Flutter changes.
- Decisions recorded under Plan 3:
  - **2026-10-12 I3:** fold `countedAt` into 3b.
  - **Split 2026-10-12:** 3b = counting time + receiving + mirror-migration machinery; 3c = orders; 3d = tasks and alerts; 3e = push.
  - **2026-10-11:** adapt the app to the server; PO line flags are dropped in server mode.

## Global Constraints

- **Branches.**
  - Server work goes on branch `counted-at`, cut from `api-foundation`.
  - App work goes in worktree `.worktrees/receiving` on branch `receiving`, cut from `feature/order-management`.
  - Never `main`. Never touch the app's main checkout.
- **Commits:** conventional subjects. End each message with the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **Server rules (1a–1c) still hold:**
  - `-warnaserror` and Testcontainers tests.
  - Each API change refreshes `admin/openapi/v1.json` (`UPDATE_OPENAPI_SNAPSHOT=1`) and runs `npm run gen:api`; the admin typecheck must pass.
  - EF migrations: `dotnet ef migrations add <Name> -p src/WareTrack.Api -o Infrastructure/Migrations`.
- **App rules (3a) still hold:**
  - Every server write goes through `SyncQueue` with a stored `idempotencyKey`, oldest first.
  - Reads come from the Drift copy.
  - Sample mode runs exactly as before; nothing touches the network unless `useApiProvider` is true.
  - Drift row classes end in `Row`. Import `app_database.dart` with `hide CountItem, CountSession, UserSession` where the models are also imported.
  - Run `flutter pub run build_runner build --delete-conflicting-outputs` after table changes, and commit the regenerated `*.g.dart`.
- **Tooling:**
  - Flutter: `/Users/irfanfikhribiniszahar/Developer/flutter/bin/flutter` (`F` below).
  - .NET: `DOTNET_ROOT=~/.dotnet PATH=~/.dotnet:$PATH`.
- **Known failures:** 2 `welcome_screen_test` failures pre-date 3a. The redesign removed the text they look for. Leave them alone.
- **Quantities in receiving stay whole numbers in 3b,** the same as counting. Decimal entry is not in this plan; ask before adding it.
- **Server mode drops what the server can't take:**
  - PO line flags and reasons;
  - "add an item that isn't on the order";
  - receiving more than ordered (the server refuses it with 409 `po-over-receipt`).
  Sample mode keeps all three.
- **Mirror version.** `kMirrorVersion` in `server_tables.dart` is the single place that forces a full re-pull. 3b sets it to 2. Every later plan that starts storing a skipped entity bumps it.

## Review Focus

1. **A count finished offline, with stock moved before it was sent.** Approving it applies the difference against stock as it was when counted. The receipt that arrived meanwhile is kept, not wiped out. Pinned in Task 1 (`A_count_sent_later_is_compared_with_stock_as_it_was_when_counted`).
2. **A receipt waiting to be sent.** Its order already shows the received quantities, so a second worker, or the same one after a restart, doesn't receive the same goods again. Pinned in Task 4 (`a_queued_receipt_shows_on_the_order_until_the_server_has_it`).
3. **Receiving more than is left on a line.** It is stopped on the phone with how many are left, instead of queueing a receipt the server will refuse. Pinned in Task 4 (`receiving_more_than_is_left_is_stopped_before_it_is_queued`).
4. **A signature whose receipt was refused,** for example 409 `po-closed`. It is marked "not sent" with that reason, rather than sending it and getting a confusing 404. A signature retried after a network failure carries the same key and bytes. Pinned in Task 3 (`a_signature_whose_receipt_was_refused_says_why`, `a_file_retried_after_a_401_keeps_its_key_and_bytes`).
5. **A phone updated from 3a that had already synced past the purchase orders.** It re-reads its feed from the start and gets them. Pinned in Task 2 (`a_phone_on_an_older_mirror_reads_the_feed_again_from_the_start`).

---

## File Structure

```
SERVER (counted-at)
src/WareTrack.Contracts/Counts/CountContracts.cs       SubmitCountRequest.CountedAt; CountSessionDto/CountReviewDto.CountedAt
src/WareTrack.Api/Features/Counts/CountSession.cs      + CountedAt
src/WareTrack.Api/Features/Counts/CountEndpoints.cs    validate + use the level at CountedAt
src/WareTrack.Api/Features/Counts/CountChangeSource.cs, CountReviewEndpoints.cs   DTOs
src/WareTrack.Api/Features/Stock/StockLedger.cs        + LevelsAtAsync
src/WareTrack.Api/Infrastructure/Migrations/*_CountedAt.cs
tests/WareTrack.Api.Tests/CountedAtTests.cs
admin/openapi/v1.json, admin/src/api/schema.d.ts       regenerated

APP (receiving)
lib/data/local/tables/server_tables.dart               + RemotePurchaseOrders, RemotePoLines, SyncCursors.mirrorVersion, kMirrorVersion
lib/data/local/daos/server_mirror_dao.dart             PO upserts/queries, barcodesFor, version-aware cursor
lib/data/local/daos/sync_queue_dao.dart                + commandFor
lib/data/local/app_database.dart                       schema 7
lib/data/sync/change_feed_puller.dart                  + purchaseOrder
lib/data/api/api_client.dart                           request factories, putFile (multipart)
lib/data/sync/command_sender.dart, sync_service.dart, sync_provider.dart   receipt.create, receipt.signature
lib/data/api/api_stock_count_repository.dart           + countedAt
lib/data/api/api_receiving_repository.dart             new
lib/core/models/purchase_order.dart                    number, lineId, itemId, barcodes, alreadyReceived
lib/data/repositories/receiving_repository.dart        putAway locations, submit with signature + location
lib/data/sample/sample_receiving_repository.dart
lib/features/receiving/providers/receiving_provider.dart
lib/features/receiving/presentation/po_list_screen.dart, po_details_screen.dart, receive_items_screen.dart, receive_summary_screen.dart
lib/main.dart
test/… per task; test/live/api_receiving_live_test.dart
```

---

### Task 1: The server compares a count with stock as it was when counted

**Files:**
- Modify: `src/WareTrack.Contracts/Counts/CountContracts.cs`, `src/WareTrack.Api/Features/Counts/CountSession.cs`, `src/WareTrack.Api/Features/Counts/CountEndpoints.cs`, `src/WareTrack.Api/Features/Counts/CountChangeSource.cs`, `src/WareTrack.Api/Features/Counts/CountReviewEndpoints.cs`, `src/WareTrack.Api/Features/Stock/StockLedger.cs`, `admin/openapi/v1.json`, `admin/src/api/schema.d.ts`
- Create: migration `CountedAt`
- Test: `tests/WareTrack.Api.Tests/CountedAtTests.cs`

**Interfaces:**
- Produces:
  - `SubmitCountRequest(string? Label, IReadOnlyList<CountLineInput> Lines, DateTimeOffset? CountedAt = null)`.
  - `CountSessionDto` and `CountReviewDto` end with `DateTimeOffset CountedAt`.
  - `StockLedger.LevelsAtAsync(warehouseId, keys, at, ct)`.
  - `countedAt` validation: at most 5 minutes in the future, at most 30 days old.

- [ ] **Step 1: Create the branch and write the failing tests**

```bash
cd ~/projects/Personal/DotNet/waretrack-server
git switch -c counted-at api-foundation
```

`tests/WareTrack.Api.Tests/CountedAtTests.cs`:
```csharp
using System.Net;
using WareTrack.Api.Tests.Support;
using WareTrack.Contracts;
using WareTrack.Contracts.Counts;

namespace WareTrack.Api.Tests;

[Collection(ApiCollection.Name)]
public sealed class CountedAtTests(ApiFixture fx)
{
    [Fact]
    public async Task A_count_sent_later_is_compared_with_stock_as_it_was_when_counted()
    {
        var warehouse = await fx.Api.CreateWarehouseAsync();
        var bin = (await fx.Api.CreateLocationsAsync(warehouse.Id, 1))[0];
        var item = await fx.Api.CreateItemAsync();
        await fx.Api.SetStockAsync(warehouse.Id, bin.Id, item.Id, 10);
        var (_, phone) = await fx.Api.MemberAsync(warehouse.Id, WarehouseRole.Worker);
        var (_, lead) = await fx.Api.MemberAsync(warehouse.Id, WarehouseRole.Supervisor);
        var countedAt = DateTimeOffset.UtcNow;
        await Task.Delay(20);
        await fx.Api.SetStockAsync(warehouse.Id, bin.Id, item.Id, 15); // goods arrived while the phone was offline
        var session = Guid.NewGuid();

        var submitted = await (await phone.SendCommandAsync(HttpMethod.Post, $"/warehouses/{warehouse.Id}/count-sessions/{session}/submit",
            new SubmitCountRequest("Aisle A", [new CountLineInput(item.Id, bin.Id, 10)], countedAt))).ReadAsync<CountSessionDto>();
        await (await lead.SendCommandAsync(HttpMethod.Post, $"/warehouses/{warehouse.Id}/count-sessions/{session}/approve")).ReadAsync<CountSessionDto>();

        Assert.Equal(10, Assert.Single(submitted.Lines).SystemAtSubmit);
        Assert.Equal(countedAt.ToUnixTimeMilliseconds(), submitted.CountedAt.ToUnixTimeMilliseconds());
        Assert.Equal(15, await fx.Api.StockAsync(bin.Id, item.Id)); // nothing was missing when counted: the receipt stays
    }

    [Fact]
    public async Task Without_a_count_time_the_level_on_arrival_is_used()
    {
        var warehouse = await fx.Api.CreateWarehouseAsync();
        var bin = (await fx.Api.CreateLocationsAsync(warehouse.Id, 1))[0];
        var item = await fx.Api.CreateItemAsync();
        await fx.Api.SetStockAsync(warehouse.Id, bin.Id, item.Id, 10);
        var (_, phone) = await fx.Api.MemberAsync(warehouse.Id, WarehouseRole.Worker);

        var submitted = await (await phone.SendCommandAsync(HttpMethod.Post, $"/warehouses/{warehouse.Id}/count-sessions/{Guid.NewGuid()}/submit",
            new SubmitCountRequest(null, [new CountLineInput(item.Id, bin.Id, 8)]))).ReadAsync<CountSessionDto>();

        Assert.Equal(10, Assert.Single(submitted.Lines).SystemAtSubmit);
        Assert.Equal(submitted.SubmittedAt, submitted.CountedAt);
    }

    [Theory]
    [InlineData(2)]    // hours ahead: a phone clock that is wrong
    [InlineData(-745)] // hours back: more than 30 days
    public async Task A_count_time_in_the_future_or_long_ago_is_refused(int hours)
    {
        var warehouse = await fx.Api.CreateWarehouseAsync();
        var bin = (await fx.Api.CreateLocationsAsync(warehouse.Id, 1))[0];
        var item = await fx.Api.CreateItemAsync();
        var (_, phone) = await fx.Api.MemberAsync(warehouse.Id, WarehouseRole.Worker);

        var response = await phone.SendCommandAsync(HttpMethod.Post, $"/warehouses/{warehouse.Id}/count-sessions/{Guid.NewGuid()}/submit",
            new SubmitCountRequest(null, [new CountLineInput(item.Id, bin.Id, 1)], DateTimeOffset.UtcNow.AddHours(hours)));

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
        Assert.Contains("countedAt", await response.Content.ReadAsStringAsync());
    }
}
```

- [ ] **Step 2: Run them to verify they fail**

Run: `DOTNET_ROOT=~/.dotnet PATH=~/.dotnet:$PATH dotnet test WareTrack.slnx --nologo --filter CountedAtTests`
Expected: FAIL — compile errors: `SubmitCountRequest` takes no third argument, and `CountSessionDto` has no `CountedAt`.

- [ ] **Step 3: Contracts, entity and ledger**

In `src/WareTrack.Contracts/Counts/CountContracts.cs`:
- change `SubmitCountRequest` to:
```csharp
/// <summary>CountedAt: when the counter finished. A count sent later (offline) is compared with stock as it was then.</summary>
public sealed record SubmitCountRequest(string? Label, IReadOnlyList<CountLineInput> Lines, DateTimeOffset? CountedAt = null);
```
- append `, DateTimeOffset CountedAt` as the last positional parameter of both `CountSessionDto` and `CountReviewDto`.

In `src/WareTrack.Api/Features/Counts/CountSession.cs`, add after `SubmittedAt`:
```csharp
    /// <summary>When the counter finished; SystemAtSubmit is the stock level at this moment.</summary>
    public DateTimeOffset CountedAt { get; set; }
```

In `src/WareTrack.Api/Features/Stock/StockLedger.cs`, add after `LevelsAsync`:
```csharp
    /// <summary>Levels as they stood at <paramref name="at"/>: today's level minus every movement since.</summary>
    public async Task<Dictionary<(Guid LocationId, Guid ItemId), decimal>> LevelsAtAsync(
        Guid warehouseId, IEnumerable<(Guid LocationId, Guid ItemId)> keys, DateTimeOffset at, CancellationToken ct)
    {
        var wanted = keys.Distinct().ToList();
        var now = await LevelsAsync(wanted, ct);
        var locationIds = wanted.Select(k => k.LocationId).Distinct().ToList();
        var itemIds = wanted.Select(k => k.ItemId).Distinct().ToList();
        var since = await db.StockMovements.AsNoTracking()
            .Where(m => m.WarehouseId == warehouseId && itemIds.Contains(m.ItemId) && locationIds.Contains(m.LocationId) && m.CreatedAt > at)
            .GroupBy(m => new { m.LocationId, m.ItemId })
            .Select(g => new { g.Key.LocationId, g.Key.ItemId, Delta = g.Sum(m => m.Delta) })
            .ToListAsync(ct);
        return wanted.ToDictionary(
            k => k,
            k => now[k] - (since.FirstOrDefault(s => s.LocationId == k.LocationId && s.ItemId == k.ItemId)?.Delta ?? 0));
    }
```

- [ ] **Step 4: Submit uses it**

In `src/WareTrack.Api/Features/Counts/CountEndpoints.cs`:
- In `Submit`, replace `var errors = await ValidateAsync(db, warehouseId, request, ct);` with:
```csharp
        var now = clock.GetUtcNow();
        var errors = await ValidateAsync(db, warehouseId, request, now, ct);
```
  and delete the later `var now = clock.GetUtcNow();` line.
- Replace `var levels = await ledger.LevelsAsync(request.Lines.Select(l => (l.LocationId, l.ItemId)), ct);` with:
```csharp
        // A count sent later (offline) is compared with stock as it stood when it was counted, so goods that moved in
        // between are not mistaken for a counting difference.
        var countedAt = request.CountedAt ?? now;
        var levels = await ledger.LevelsAtAsync(warehouseId, request.Lines.Select(l => (l.LocationId, l.ItemId)), countedAt, ct);
```
- After `session.SubmittedAt = now;` add `session.CountedAt = countedAt;`.
- Change the signature to `ValidateAsync(WareTrackDbContext db, Guid warehouseId, SubmitCountRequest request, DateTimeOffset now, CancellationToken ct)`, and add before `return errors;`:
```csharp
        if (request.CountedAt > now.AddMinutes(5)) errors["countedAt"] = ["The count time is in the future. Check the phone's clock."];
        else if (request.CountedAt < now.AddDays(-30)) errors["countedAt"] = ["This count is more than 30 days old. Count again."];
```

In `src/WareTrack.Api/Features/Counts/CountChangeSource.cs`, add `s.CountedAt` as the last argument of `new(` in `ToDto`, after the lines list.

In `src/WareTrack.Api/Features/Counts/CountReviewEndpoints.cs`, add `s.CountedAt` as the last argument of `new CountReviewDto(` in `ToDtosAsync`.

- [ ] **Step 5: The migration**

```bash
DOTNET_ROOT=~/.dotnet PATH=~/.dotnet:$PATH dotnet ef migrations add CountedAt -p src/WareTrack.Api -o Infrastructure/Migrations
```
In the generated `*_CountedAt.cs`, add this as the last statement of `Up`:
```csharp
            // Counts made before this change were compared with stock on arrival: that is their count time.
            migrationBuilder.Sql("UPDATE count_sessions SET counted_at = submitted_at;");
```

- [ ] **Step 6: Run everything and refresh the admin client**

```bash
DOTNET_ROOT=~/.dotnet PATH=~/.dotnet:$PATH dotnet build WareTrack.slnx --nologo -warnaserror
UPDATE_OPENAPI_SNAPSHOT=1 DOTNET_ROOT=~/.dotnet PATH=~/.dotnet:$PATH dotnet test WareTrack.slnx --nologo --filter OpenApiSnapshotTests
DOTNET_ROOT=~/.dotnet PATH=~/.dotnet:$PATH dotnet test WareTrack.slnx --nologo
cd admin && npm run gen:api && npm run typecheck && npm test; cd ..
```
Expected: 0 warnings; the 4 `CountedAtTests` cases PASS and the whole suite (143 + 4) PASSES; admin typecheck clean and 88 PASS.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(counts): compare a count with stock as it was when it was counted

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: The phone sends the count time, and re-reads its feed when the copy grows

**Files:**
- Modify: `lib/data/api/api_stock_count_repository.dart`, `lib/data/local/tables/server_tables.dart`, `lib/data/local/daos/server_mirror_dao.dart`, `lib/data/local/app_database.dart`, `lib/data/sync/change_feed_puller.dart` (+ regenerated `*.g.dart`)
- Test: `test/data/api/api_stock_count_repository_test.dart` (update), `test/data/sync/change_feed_puller_test.dart` (extend)

**Interfaces:**
- Consumes: the 3a puller and DAO.
- Produces:
  - `kMirrorVersion = 2`.
  - `SyncCursors.mirrorVersion`.
  - `cursorFor(w)` returns 0 for a cursor saved by an older mirror.
  - `RemotePurchaseOrderRow` and `RemotePoLineRow`.
  - DAO methods:
    - `upsertPurchaseOrder(order, lines)`, `deletePurchaseOrder(id)`;
    - `purchaseOrders(warehouseId)` (not Closed), `poLinesFor(poId)`;
    - `barcodesFor(itemId)`.
  - The puller handles `purchaseOrder`.
  - Count submits include `countedAt` (ISO-8601 UTC).

- [ ] **Step 1: Create the worktree and write the failing tests**

```bash
cd ~/projects/Personal/Flutter/warehouse_app
git worktree add .worktrees/receiving -b receiving feature/order-management
cd .worktrees/receiving
F=/Users/irfanfikhribiniszahar/Developer/flutter/bin/flutter
$F pub get >/dev/null && mkdir -p docs/superpowers/plans && cp ~/projects/Personal/DotNet/waretrack-server/docs/superpowers/plans/2026-10-12-waretrack-app-3b-counting-time-receiving.md docs/superpowers/plans/
git add docs && git commit -m "docs: add the app 3b counting time and receiving plan

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

In `test/data/api/api_stock_count_repository_test.dart`, in `a_count_listing_an_item_twice_sends_one_line_with_the_total`, replace
```dart
    expect(jsonDecode(queued.payload), {
```
with
```dart
    final payload = jsonDecode(queued.payload) as Map<String, dynamic>;
    final countedAt = DateTime.parse(payload.remove('countedAt') as String);
    expect(DateTime.now().difference(countedAt).inMinutes, 0); // stamped when the count was finished
    expect(payload, {
```

Append to `test/data/sync/change_feed_puller_test.dart`, inside `main`:
```dart
  test('purchase orders arrive with their lines, and closed ones are left out', () async {
    await (await pullerServing([
      page([
        change('purchaseOrder', 'po-1', 1, {
          'id': 'po-1', 'warehouseId': w, 'number': 'PO-SA1-001', 'supplier': 'Gula Prai Trading', 'expectedDate': '2026-10-14', 'status': 'Partial',
          'lines': [{'id': 'pl-1', 'lineNo': 1, 'itemId': item, 'ordered': 10, 'received': 4}],
        }),
        change('purchaseOrder', 'po-2', 2, {
          'id': 'po-2', 'warehouseId': w, 'number': 'PO-SA1-002', 'supplier': 'Old', 'expectedDate': null, 'status': 'Closed', 'lines': [],
        }),
      ], next: 2),
    ])).pull(w);

    final orders = await db.serverMirrorDao.purchaseOrders(w);
    expect(orders.map((o) => o.number), ['PO-SA1-001']);
    expect(orders.single.expectedDate, DateTime(2026, 10, 14));
    final line = (await db.serverMirrorDao.poLinesFor('po-1')).single;
    expect((line.ordered, line.received), (10, 4));
  });

  test('a_phone_on_an_older_mirror_reads_the_feed_again_from_the_start', () async {
    // What a 3a phone saved: cursor 40 under mirror version 1, which never stored purchase orders.
    await db.customStatement("INSERT INTO sync_cursors (warehouse_id, cursor, mirror_version) VALUES ('$w', 40, 1)");

    await (await pullerServing([page([], next: 40)])).pull(w);

    expect(cursorsAsked, ['0']);
    expect(await db.serverMirrorDao.cursorFor(w), 40); // saved again under the current version
  });
```

- [ ] **Step 2: Run them to verify they fail**

Run: `$F test test/data/api/api_stock_count_repository_test.dart test/data/sync/change_feed_puller_test.dart`
Expected: FAIL:
- `payload.remove('countedAt')` is null, so the cast throws;
- `purchaseOrders` doesn't exist;
- the `INSERT` fails because there is no `mirror_version` column.

- [ ] **Step 3: Count time on submits**

In `lib/data/api/api_stock_count_repository.dart`, in `submitSession`, add as the first entry of the `jsonEncode({...})` map:
```dart
        'countedAt': DateTime.now().toUtc().toIso8601String(), // finished now; it may reach the server much later
```

- [ ] **Step 4: Mirror version and purchase orders in the copy**

In `lib/data/local/tables/server_tables.dart`:
- add near the top:
```dart
/// Bump when the app starts storing a change-feed entity it used to skip. Every phone then reads its feed again from
/// the start, so the rows it skipped before arrive. 1 = 3a (catalogue, locations, counts); 2 = 3b (+ purchase orders).
const kMirrorVersion = 2;
```
- add to `SyncCursors`:
```dart
  /// The kMirrorVersion this cursor was saved under; an older one means "read again from the start".
  IntColumn get mirrorVersion => integer().withDefault(const Constant(1))();
```
- add the tables:
```dart
@DataClassName('RemotePurchaseOrderRow')
class RemotePurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text()();
  TextColumn get number => text()();
  TextColumn get supplier => text()();
  DateTimeColumn get expectedDate => dateTime().nullable()();
  TextColumn get status => text()(); // Open · Partial · Received · Closed

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RemotePoLineRow')
class RemotePoLines extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseOrderId => text()();
  IntColumn get lineNo => integer()();
  TextColumn get itemId => text()();
  RealColumn get ordered => real()();
  RealColumn get received => real()();

  @override
  Set<Column> get primaryKey => {id};
}
```

In `lib/data/local/daos/server_mirror_dao.dart`:
- add `RemotePurchaseOrders, RemotePoLines` to `@DriftAccessor(tables: …)`;
- replace `cursorFor` and `saveCursor` with:
```dart
  /// 0 when this phone has never read the feed, or read it under an older mirror version (see kMirrorVersion).
  Future<int> cursorFor(String warehouseId) async {
    final row = await (select(syncCursors)..where((c) => c.warehouseId.equals(warehouseId))).getSingleOrNull();
    return row == null || row.mirrorVersion < kMirrorVersion ? 0 : row.cursor;
  }

  Future<void> saveCursor(String warehouseId, int cursor) => into(syncCursors).insertOnConflictUpdate(
        SyncCursorsCompanion.insert(warehouseId: warehouseId, cursor: cursor, mirrorVersion: const Value(kMirrorVersion)),
      );
```
- add:
```dart
  /// An order arrives whole: its lines replace whatever the phone had for it.
  Future<void> upsertPurchaseOrder(RemotePurchaseOrdersCompanion order, List<RemotePoLinesCompanion> lines) async {
    await into(remotePurchaseOrders).insertOnConflictUpdate(order);
    await (delete(remotePoLines)..where((l) => l.purchaseOrderId.equals(order.id.value))).go();
    for (final line in lines) {
      await into(remotePoLines).insert(line);
    }
  }

  Future<void> deletePurchaseOrder(String id) async {
    await (delete(remotePoLines)..where((l) => l.purchaseOrderId.equals(id))).go();
    await (delete(remotePurchaseOrders)..where((o) => o.id.equals(id))).go();
  }

  /// Orders that can still be received against, or were received in full; closed ones are done with.
  Future<List<RemotePurchaseOrderRow>> purchaseOrders(String warehouseId) => (select(remotePurchaseOrders)
        ..where((o) => o.warehouseId.equals(warehouseId) & o.status.isNotIn(['Closed']))
        ..orderBy([(o) => OrderingTerm.asc(o.expectedDate), (o) => OrderingTerm.asc(o.number)]))
      .get();

  Future<List<RemotePoLineRow>> poLinesFor(String purchaseOrderId) => (select(remotePoLines)
        ..where((l) => l.purchaseOrderId.equals(purchaseOrderId))
        ..orderBy([(l) => OrderingTerm.asc(l.lineNo)]))
      .get();

  Future<List<String>> barcodesFor(String itemId) async =>
      [for (final b in await (select(catalogBarcodes)..where((b) => b.itemId.equals(itemId))).get()) b.code];
```

In `lib/data/local/app_database.dart`:
- add `RemotePurchaseOrders, RemotePoLines` to `tables:`;
- add `remotePurchaseOrders, remotePoLines` to the list in `clearServerData`;
- set `schemaVersion => 7`;
- add after the `from < 6` block:
```dart
          if (from < 7) {
            await migrator.createTable(remotePurchaseOrders);
            await migrator.createTable(remotePoLines);
            // Existing cursors get mirror version 1, older than kMirrorVersion: the next pull starts from 0 and brings
            // the purchase orders a 3a phone skipped.
            await migrator.addColumn(syncCursors, syncCursors.mirrorVersion);
          }
```

In `lib/data/sync/change_feed_puller.dart`, add before `default:`:
```dart
      case 'purchaseOrder':
        if (data == null) return dao.deletePurchaseOrder(id);
        return dao.upsertPurchaseOrder(
          RemotePurchaseOrdersCompanion.insert(
            id: id,
            warehouseId: data['warehouseId'] as String,
            number: data['number'] as String,
            supplier: data['supplier'] as String,
            expectedDate: Value(data['expectedDate'] == null ? null : DateTime.parse(data['expectedDate'] as String)),
            status: data['status'] as String,
          ),
          [
            for (final line in (data['lines'] as List).cast<Map<String, dynamic>>())
              RemotePoLinesCompanion.insert(
                id: line['id'] as String,
                purchaseOrderId: id,
                lineNo: (line['lineNo'] as num).toInt(),
                itemId: line['itemId'] as String,
                ordered: (line['ordered'] as num).toDouble(),
                received: (line['received'] as num).toDouble(),
              ),
          ],
        );
```
Change the `default:` comment to: `// Orders, tasks and alerts come in 3c and 3d, each bumping kMirrorVersion so they are pulled from the start.`

- [ ] **Step 5: Regenerate and run**

```bash
$F pub run build_runner build --delete-conflicting-outputs
$F test -r failures-only test/data && $F analyze lib test
```
Expected: the updated count test and the 2 new puller tests PASS; every other data test PASSES; analyze clean.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(sync): send the count time and copy purchase orders, re-reading the feed after an update

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Sending receipts and signatures

**Files:**
- Modify: `lib/data/api/api_client.dart`, `lib/data/local/daos/sync_queue_dao.dart`, `lib/data/sync/command_sender.dart`, `lib/data/sync/sync_service.dart`, `lib/data/sync/sync_provider.dart`
- Test: `test/data/api/api_client_test.dart` (extend), `test/data/sync/sync_service_test.dart` (extend)

**Interfaces:**
- Consumes: the 3a outbox.
- Produces:
  - `ApiClient.putFile(path, {field, filename, bytes, idempotencyKey})` → `Future<dynamic>`.
  - `SyncOps.receiptCreate` (`receipt.create`): referenceId = receiptId; payload `{purchaseOrderId, lines:[{poLineId, locationId, quantity}]}`.
  - `SyncOps.receiptSignature` (`receipt.signature`): referenceId = receiptId; payload `{png: base64}`.
  - `SyncQueueDao.commandFor(op, referenceId)`.

- [ ] **Step 1: Write the failing tests**

Append to `test/data/api/api_client_test.dart`, inside `main`:
```dart
  test('a_file_retried_after_a_401_keeps_its_key_and_bytes', () async {
    final sent = <String>[];
    final client = ApiClient(
      baseUrl: testBaseUrl,
      tokens: await signedInTokens(),
      httpClient: MockClient((r) async {
        if (r.url.path.endsWith('/auth/refresh')) return jsonResponse(tokensJson('access-2', 'refresh-2'));
        expect(r.headers['content-type'], startsWith('multipart/form-data'));
        sent.add('${r.method} ${r.headers['Idempotency-Key']} ${r.bodyBytes.length > 100 && utf8.decode(r.bodyBytes, allowMalformed: true).contains('PNG')}');
        return r.headers['Authorization'] == 'Bearer access-1' ? http.Response('', 401) : jsonResponse({'receiptId': 'r1', 'bytes': 120});
      }),
    );
    final png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, ...List.filled(112, 7)];

    await client.putFile('/warehouses/w1/receipts/r1/signature', field: 'signature', filename: 'signature.png', bytes: png, idempotencyKey: 'key-9');

    expect(sent, ['PUT key-9 true', 'PUT key-9 true']);
  });
```

Append inside the `with the server` group of `test/data/sync/sync_service_test.dart`:
```dart
    Future<void> queueReceipt(String receiptId, {bool signed = true}) async {
      await db.syncQueueDao.enqueue(
        operationType: SyncOps.receiptCreate,
        referenceId: receiptId,
        warehouseId: 'w1',
        payload: jsonEncode({'purchaseOrderId': 'po-1', 'lines': [{'poLineId': 'pl-1', 'locationId': 'bin-1', 'quantity': 4}]}),
      );
      if (signed) {
        await db.syncQueueDao.enqueue(
          operationType: SyncOps.receiptSignature,
          referenceId: receiptId,
          warehouseId: 'w1',
          payload: jsonEncode({'png': base64Encode([0x89, 0x50, 0x4E, 0x47, 1, 2, 3])}),
        );
      }
    }

    test('a receipt and then its signature go to their own endpoints', () async {
      await queueReceipt('r1');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add('${r.method} ${r.url.path}');
        if (r.method == 'POST') expect(jsonDecode(r.body), {'receiptId': 'r1', 'lines': [{'poLineId': 'pl-1', 'locationId': 'bin-1', 'quantity': 4}]});
        return jsonResponse({'id': 'r1'});
      });

      expect(await service.flushQueue(), FlushOutcome.done);

      expect(calls, ['POST /api/warehouses/w1/purchase-orders/po-1/receipts', 'PUT /api/warehouses/w1/receipts/r1/signature']);
    });

    test('a_signature_whose_receipt_was_refused_says_why', () async {
      await queueReceipt('r1');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add(r.method);
        return jsonResponse({'status': 409, 'code': 'po-closed', 'title': 'Purchase order is closed', 'detail': 'PO-SA1-001 is closed; nothing more can be received against it.'}, 409);
      });

      await service.flushQueue();

      expect(calls, ['POST']); // the signature was never sent to a receipt that doesn't exist
      final issues = await db.syncQueueDao.watchIssues().first;
      expect(issues.map((i) => i.operationType), [SyncOps.receiptSignature, SyncOps.receiptCreate]);
      expect(ApiException.fromJson(jsonDecode(issues.first.lastError!) as Map<String, dynamic>).message, contains('its receipt was not accepted'));
    });
```

- [ ] **Step 2: Run them to verify they fail**

Run: `$F test test/data/api/api_client_test.dart test/data/sync/sync_service_test.dart`
Expected: FAIL — compile errors: `putFile`, `SyncOps.receiptCreate` and `SyncOps.receiptSignature` don't exist.

- [ ] **Step 3: The client sends files**

In `lib/data/api/api_client.dart`, the requests become factories, so a 401 retry can rebuild a multipart request. Change:
- `get` → `_send(() => _json('GET', path, query: query))`;
- `post` → `_send(() => _json('POST', path, body: body, idempotencyKey: idempotencyKey), authenticated: authenticated)`;
- `_send` to `Future<dynamic> _send(http.BaseRequest Function() build, {bool authenticated = true})`, calling `_raw(build, authenticated)` in both places;
- in `_refresh`, call `_raw(() => _json('POST', '/auth/refresh', body: {'refreshToken': refreshToken}), false)`;
- replace `_raw` with the request-building helpers below.
```dart
  /// One file as multipart/form-data (a receipt's signature). The server fingerprints the form's fields and file bytes,
  /// not the multipart boundary, so a retry with the same key and the same bytes counts as the same request.
  Future<dynamic> putFile(String path, {required String field, required String filename, required List<int> bytes, String? idempotencyKey}) =>
      _send(() {
        final request = http.MultipartRequest('PUT', _uri(path, null))
          ..files.add(http.MultipartFile.fromBytes(field, bytes, filename: filename));
        if (idempotencyKey != null) request.headers['Idempotency-Key'] = idempotencyKey;
        return request;
      });

  Uri _uri(String path, Map<String, String>? query) => Uri.parse('$_base$path').replace(queryParameters: query);

  http.Request _json(String method, String path, {Map<String, String>? query, Object? body, String? idempotencyKey}) {
    final request = http.Request(method, _uri(path, query));
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    if (idempotencyKey != null) request.headers['Idempotency-Key'] = idempotencyKey;
    return request;
  }

  Future<http.Response> _raw(http.BaseRequest Function() build, bool authenticated) async {
    final request = build()..headers['Accept'] = 'application/json';
    final token = _tokens.accessToken;
    if (authenticated && token != null) request.headers['Authorization'] = 'Bearer $token';
    try {
      final streamed = await _http.send(request).timeout(timeout);
      return await http.Response.fromStream(streamed).timeout(timeout);
    } on IOException catch (e) {
      // Sockets, TLS handshakes, HTTP protocol errors: the server was not properly reached.
      throw ApiOfflineException(e);
    } on TimeoutException catch (e) {
      throw ApiOfflineException(e);
    } on http.ClientException catch (e) {
      throw ApiOfflineException(e);
    }
  }
```

- [ ] **Step 4: The receipt commands**

In `lib/data/sync/command_sender.dart`:
- add to `SyncOps`:
```dart
  static const receiptCreate = 'receipt.create';
  static const receiptSignature = 'receipt.signature';
```
- add before `default:`:
```dart
      case SyncOps.receiptCreate:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.post(
          '/warehouses/${item.warehouseId}/purchase-orders/${payload['purchaseOrderId']}/receipts',
          body: {'receiptId': item.referenceId, 'lines': payload['lines']},
          idempotencyKey: key,
        );
      case SyncOps.receiptSignature:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.putFile(
          '/warehouses/${item.warehouseId}/receipts/${item.referenceId}/signature',
          field: 'signature',
          filename: 'signature.png',
          bytes: base64Decode(payload['png'] as String),
          idempotencyKey: key,
        );
```

In `lib/data/local/daos/sync_queue_dao.dart`, add:
```dart
  /// The latest queued command of [operationType] for [referenceId], in any state.
  Future<SyncQueueData?> commandFor(String operationType, String referenceId) => (select(syncQueue)
        ..where((q) => q.operationType.equals(operationType) & q.referenceId.equals(referenceId))
        ..orderBy([(q) => OrderingTerm.desc(q.id)])
        ..limit(1))
      .getSingleOrNull();
```

In `lib/data/sync/sync_service.dart`, in `_flush`, right after `await dao.recordAttempt(item.id);`, add:
```dart
      if (item.operationType == SyncOps.receiptSignature) {
        // A signature belongs to a receipt. If the server refused the receipt, sending the signature would only fail
        // with "receipt not found"; say why instead.
        final receipt = await dao.commandFor(SyncOps.receiptCreate, item.referenceId);
        if (receipt != null && (receipt.status == 'conflicted' || receipt.status == 'failed')) {
          await dao.markFailed(item.id, const ApiException(status: 0, title: 'Signature not sent: its receipt was not accepted.'));
          continue;
        }
      }
```

In `lib/data/sync/sync_provider.dart`, add these two lines to the `title:` switch in `syncIssuesProvider`:
```dart
              SyncOps.receiptCreate => 'Receipt not accepted',
              SyncOps.receiptSignature => 'Signature not sent',
```

- [ ] **Step 5: Run every check**

Run: `$F test -r failures-only test/data && $F analyze lib test`
Expected: the new client test and the 2 new sync tests PASS; the 3a client and sync tests still PASS; analyze clean.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(sync): send receipts and their signatures, holding a signature whose receipt was refused

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: Purchase orders and receipts from the server

**Files:**
- Create: `lib/data/api/api_receiving_repository.dart`
- Modify: `lib/core/models/purchase_order.dart`, `lib/data/repositories/receiving_repository.dart`, `lib/data/sample/sample_receiving_repository.dart`, `lib/features/receiving/providers/receiving_provider.dart`, `lib/main.dart`
- Test: `test/data/api/api_receiving_repository_test.dart`, `test/features/receiving/receiving_provider_test.dart` (extend)

**Interfaces:**
- Consumes: the PO copy and `barcodesFor` (Task 2); `SyncOps.receiptCreate` and `receiptSignature` (Task 3); `CountLocation` (3a).
- Produces:
  - `PurchaseOrder.number` and `displayNumber`.
  - `PoLineItem` gains `lineId`, `itemId`, `barcodes`, `alreadyReceived`, `matches(code)` and `receivingNow`.
  - `ReceivingRepository.getPutAwayLocations()` and `submitReceive(order, {signature, locationId})`.
  - `putAwayLocationsProvider`.
  - `ApiReceivingRepository(db:, session:, onQueued:)`.
  - `ActiveReceiveNotifier.submitReceive({signature, locationId})`.

- [ ] **Step 1: Write the failing tests**

`test/data/api/api_receiving_repository_test.dart`:
```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_receiving_repository.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide CountItem, CountSession, UserSession;
import 'package:warehouse_app/data/sync/command_sender.dart';

const w = '22222222-2222-4222-8222-222222222222';
const beras = 'aaaaaaaa-0000-4000-8000-000000000001';
const dock = 'dddddddd-0000-4000-8000-000000000001';

UserSession worker() => const UserSession(
      userId: 'u1',
      name: 'Arjun Nair',
      email: 'arjun@waretrack.local',
      site: 'Shah Alam DC',
      role: UserRole.worker,
      token: 't',
      warehouseId: w,
      warehouses: [WarehouseMembership(warehouseId: w, code: 'SA1', name: 'Shah Alam DC', role: UserRole.worker)],
    );

void main() {
  late AppDatabase db;
  late ApiReceivingRepository repo;
  late int kicks;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    kicks = 0;
    repo = ApiReceivingRepository(db: db, session: worker, onQueued: () => kicks++);
    final dao = db.serverMirrorDao;
    await dao.upsertItem(CatalogItemsCompanion.insert(id: beras, sku: 'WT-0001', name: 'Beras Wangi 10kg', uom: 'BAG', isActive: true));
    await dao.upsertBarcode(CatalogBarcodesCompanion.insert(id: 'bc1', itemId: beras, code: '9556001000011'));
    await dao.upsertLocation(WarehouseLocationsCompanion.insert(id: 'bin-1', warehouseId: w, code: 'A-01-01', type: 'Bin'));
    await dao.upsertLocation(WarehouseLocationsCompanion.insert(id: dock, warehouseId: w, code: 'DOCK-1', type: 'Dock'));
    await dao.upsertPurchaseOrder(
      RemotePurchaseOrdersCompanion.insert(id: 'po-1', warehouseId: w, number: 'PO-SA1-001', supplier: 'Gula Prai Trading', status: 'Partial', expectedDate: Value(DateTime(2026, 10, 14))),
      [RemotePoLinesCompanion.insert(id: 'pl-1', purchaseOrderId: 'po-1', lineNo: 1, itemId: beras, ordered: 10, received: 4)],
    );
  });
  tearDown(() => db.close());

  test('orders come from the phone copy with item names, barcodes and what is already received', () async {
    final order = (await repo.getPurchaseOrders()).single;

    expect(order.displayNumber, 'PO-SA1-001');
    expect(order.status, PoStatus.inProgress);
    final line = order.lineItems.single;
    expect((line.itemName, line.itemCode, line.expected, line.received, line.alreadyReceived), ('Beras Wangi 10kg', 'WT-0001', 10, 4, 4));
    expect(line.matches('9556001000011'), isTrue);
  });

  test('a receipt sends only what was added now, to the chosen location, then its signature', () async {
    final order = (await repo.getPurchaseOrders()).single;
    final receiving = order.copyWithLines([order.lineItems.single.copyWith(received: 7)]);

    await repo.submitReceive(receiving, signature: Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]), locationId: dock);

    final queued = await db.syncQueueDao.getPendingItems();
    expect(queued.map((q) => q.operationType), [SyncOps.receiptCreate, SyncOps.receiptSignature]);
    expect(queued[0].referenceId, queued[1].referenceId);
    expect(jsonDecode(queued[0].payload), {
      'purchaseOrderId': 'po-1',
      'lines': [{'poLineId': 'pl-1', 'locationId': dock, 'quantity': 3}],
    });
    expect(base64Decode((jsonDecode(queued[1].payload) as Map)['png'] as String), [0x89, 0x50, 0x4E, 0x47]);
    expect(kicks, 1);
  });

  test('a_queued_receipt_shows_on_the_order_until_the_server_has_it', () async {
    final order = (await repo.getPurchaseOrders()).single;
    await repo.submitReceive(order.copyWithLines([order.lineItems.single.copyWith(received: 10)]), locationId: dock);

    final again = (await repo.getPurchaseOrders()).single;

    expect(again.lineItems.single.received, 10);
    expect(again.lineItems.single.alreadyReceived, 10); // nothing more to receive here until the server says otherwise
    expect(again.status, PoStatus.received);
  });

  test('receiving_more_than_is_left_is_stopped_before_it_is_queued', () async {
    final order = (await repo.getPurchaseOrders()).single;

    await expectLater(
      repo.submitReceive(order.copyWithLines([order.lineItems.single.copyWith(received: 12)]), locationId: dock),
      throwsA(isA<StateError>().having((e) => e.message, 'message', contains('only 6 more'))),
    );
    expect(await db.syncQueueDao.countPending(), 0);
  });

  test('put-away locations list docks first', () async {
    expect((await repo.getPutAwayLocations()).map((l) => l.code), ['DOCK-1', 'A-01-01']);
  });
}
```

Append to `test/features/receiving/receiving_provider_test.dart`, inside the `ActiveReceiveNotifier.scanItem` group:
```dart
    test('a barcode of an order line counts for that line', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(activeReceiveNotifierProvider.notifier);
      notifier.startReceive(const PurchaseOrder(
        id: 'po-1',
        number: 'PO-SA1-001',
        supplier: 'Gula Prai Trading',
        status: PoStatus.inProgress,
        lineItems: [PoLineItem(itemCode: 'WT-0001', itemName: 'Beras Wangi 10kg', expected: 10, barcodes: ['9556001000011'])],
      ));

      expect(notifier.scanItem('9556001000011'), isTrue);
      expect(container.read(activeReceiveNotifierProvider)!.lineItems.single.received, 1);
      expect(container.read(activeReceiveNotifierProvider)!.displayNumber, 'PO-SA1-001');
    });
```

- [ ] **Step 2: Run them to verify they fail**

Run: `$F test test/data/api/api_receiving_repository_test.dart test/features/receiving`
Expected: FAIL — compile errors: `ApiReceivingRepository`, `displayNumber`, `copyWithLines` and the `barcodes`, `number` and `matches` members don't exist.

- [ ] **Step 3: The models**

In `lib/core/models/purchase_order.dart`:
- in `PurchaseOrder`:
  - add `final String? number;` with the doc comment `/// The order number to show; Sample orders use their id.`;
  - add the constructor parameter `this.number,`;
  - add the members below.
```dart
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
```
- in `PoLineItem`:
  - add the fields below, with the constructor parameters `this.lineId, this.itemId, this.barcodes = const [], this.alreadyReceived = 0,`;
  - pass `lineId: lineId, itemId: itemId, barcodes: barcodes, alreadyReceived: alreadyReceived,` through `copyWith`;
  - add the members below.
```dart
  /// The server's order line and item; null for Sample orders and for items added that are not on the order.
  final String? lineId;
  final String? itemId;

  /// Barcodes of the item, so a scan finds its line.
  final List<String> barcodes;

  /// Received before this session (the server's figure plus receipts still waiting to be sent).
  final int alreadyReceived;
```
```dart
  bool matches(String code) => itemCode == code || barcodes.contains(code);

  /// What this session adds on top of what was already received.
  int get receivingNow => (received ?? 0) - alreadyReceived;
```

- [ ] **Step 4: The repository contract, Sample and API**

Replace `lib/data/repositories/receiving_repository.dart` with:
```dart
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';

abstract class ReceivingRepository {
  Future<List<PurchaseOrder>> getPurchaseOrders();

  /// Where received goods can be put away (server mode). Empty in Sample mode, which doesn't ask.
  Future<List<CountLocation>> getPutAwayLocations();

  /// Hands a finished receipt over for sending: what this session added, where it was put away, and the signature.
  Future<void> submitReceive(PurchaseOrder order, {Uint8List? signature, String? locationId});
}

final receivingRepositoryProvider = Provider<ReceivingRepository>((ref) {
  throw UnimplementedError('receivingRepositoryProvider not overridden');
});

final putAwayLocationsProvider = FutureProvider.autoDispose<List<CountLocation>>(
  (ref) => ref.watch(receivingRepositoryProvider).getPutAwayLocations(),
);
```

In `lib/data/sample/sample_receiving_repository.dart`:
- add `import 'dart:typed_data';` and `import 'package:warehouse_app/core/models/count_records.dart';`;
- add:
```dart
  @override
  Future<List<CountLocation>> getPutAwayLocations() async => const [];
```
- change the `submitReceive` signature to `Future<void> submitReceive(PurchaseOrder order, {Uint8List? signature, String? locationId}) async {`, keeping its body.

`lib/data/api/api_receiving_repository.dart`:
```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide CountItem, CountSession, UserSession;
import 'package:warehouse_app/data/repositories/receiving_repository.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

/// Receiving against the server. Orders come from the phone's copy, with receipts still waiting to be sent already
/// counted in, so the same goods are not received twice. Finished receipts and signatures go through the outbox.
class ApiReceivingRepository implements ReceivingRepository {
  ApiReceivingRepository({required AppDatabase db, required UserSession? Function() session, required void Function() onQueued})
      : _db = db,
        _session = session,
        _onQueued = onQueued;

  final AppDatabase _db;
  final UserSession? Function() _session;
  final void Function() _onQueued;

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final dao = _db.serverMirrorDao;
    final waiting = await _waitingToSend(warehouseId);
    final orders = <PurchaseOrder>[];
    for (final order in await dao.purchaseOrders(warehouseId)) {
      final lines = <PoLineItem>[];
      for (final line in await dao.poLinesFor(order.id)) {
        final item = await dao.itemById(line.itemId);
        final received = line.received.round() + (waiting[line.id] ?? 0);
        lines.add(PoLineItem(
          lineId: line.id,
          itemId: line.itemId,
          itemCode: item?.sku ?? 'Unknown item',
          itemName: item?.name ?? 'Item no longer in the catalogue',
          expected: line.ordered.round(),
          received: received == 0 ? null : received,
          alreadyReceived: received,
          barcodes: await dao.barcodesFor(line.itemId),
          lineStatus: received > 0 ? PoLineItemStatus.confirmed : PoLineItemStatus.pending,
        ));
      }
      orders.add(PurchaseOrder(
        id: order.id,
        number: order.number,
        supplier: order.supplier,
        status: _status(lines),
        dueDate: order.expectedDate,
        lineItems: lines,
      ));
    }
    return orders;
  }

  @override
  Future<List<CountLocation>> getPutAwayLocations() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final locations = [
      for (final l in await _db.serverMirrorDao.locationsFor(warehouseId)) CountLocation(id: l.id, code: l.code, kind: l.type),
    ];
    locations.sort((a, b) => (a.kind == 'Dock' ? 0 : 1).compareTo(b.kind == 'Dock' ? 0 : 1)); // stable: codes stay in order
    return locations;
  }

  @override
  Future<void> submitReceive(PurchaseOrder order, {Uint8List? signature, String? locationId}) async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) throw StateError('No warehouse chosen.');
    if (locationId == null) throw StateError('Choose where the goods are put away.');
    final lines = <Map<String, Object?>>[];
    for (final line in order.lineItems) {
      if (line.lineId == null) continue; // the server only takes lines of the order
      final adding = line.receivingNow;
      if (adding <= 0) continue;
      final left = line.expected - line.alreadyReceived;
      if (adding > left) throw StateError('${line.itemName}: only $left more can be received on ${order.displayNumber}.');
      lines.add({'poLineId': line.lineId, 'locationId': locationId, 'quantity': adding});
    }
    if (lines.isEmpty) throw StateError('Nothing new to receive.');

    final receiptId = const Uuid().v4();
    final queue = _db.syncQueueDao;
    await queue.enqueue(
      operationType: SyncOps.receiptCreate,
      referenceId: receiptId,
      warehouseId: warehouseId,
      payload: jsonEncode({'purchaseOrderId': order.id, 'lines': lines}),
    );
    if (signature != null) {
      // The PNG travels in the command, so a retry sends exactly the same bytes under the same key.
      await queue.enqueue(
        operationType: SyncOps.receiptSignature,
        referenceId: receiptId,
        warehouseId: warehouseId,
        payload: jsonEncode({'png': base64Encode(signature)}),
      );
    }
    _onQueued();
  }

  /// Quantities in receipts the server doesn't have yet, by order line.
  Future<Map<String, int>> _waitingToSend(String warehouseId) async {
    final totals = <String, int>{};
    for (final item in await _db.syncQueueDao.itemsFor(SyncOps.receiptCreate, warehouseId: warehouseId)) {
      if (item.status != 'pending') continue;
      final payload = jsonDecode(item.payload) as Map<String, dynamic>;
      for (final line in (payload['lines'] as List).cast<Map<String, dynamic>>()) {
        final id = line['poLineId'] as String;
        totals[id] = (totals[id] ?? 0) + (line['quantity'] as num).round();
      }
    }
    return totals;
  }

  PoStatus _status(List<PoLineItem> lines) {
    if (lines.isNotEmpty && lines.every((l) => l.alreadyReceived >= l.expected)) return PoStatus.received;
    return lines.any((l) => l.alreadyReceived > 0) ? PoStatus.inProgress : PoStatus.pending;
  }
}
```

- [ ] **Step 5: The session matches barcodes and passes the signature on**

In `lib/features/receiving/providers/receiving_provider.dart`:
- in `scanItem`, change the line lookup to `state!.lineItems.indexWhere((i) => i.matches(barcode))`;
- in `confirmItem` and `flagItemWithReason`, use `indexWhere((i) => i.matches(itemCode))`;
- in `addUnknownItem` and `_withUpdatedItem`, add `number: state!.number,` to the `PurchaseOrder(` constructor;
- replace `submitReceive` with:
```dart
  Future<void> submitReceive({Uint8List? signature, String? locationId}) async {
    if (state == null) return;
    await ref.read(receivingRepositoryProvider).submitReceive(state!, signature: signature, locationId: locationId);
    await ref.read(purchaseOrdersNotifierProvider.notifier).refresh();
    state = null;
  }
```

In `lib/main.dart`, replace the `receivingRepositoryProvider.overrideWith((_) => SampleReceivingRepository()),` line with the block below, and import `api_receiving_repository.dart`:
```dart
        receivingRepositoryProvider.overrideWith(
          (ref) => client == null
              ? SampleReceivingRepository()
              : ApiReceivingRepository(
                  db: database,
                  session: () => ref.read(authNotifierProvider).valueOrNull,
                  onQueued: () => unawaited(ref.read(syncCoordinatorProvider).syncNow()),
                ),
        ),
```

- [ ] **Step 6: Run every check**

Run: `$F test -r failures-only && $F analyze lib test`
Expected: the 5 repository tests and the new provider test PASS; the existing receiving tests still PASS; the full suite shows only the 2 known welcome failures; analyze clean.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(receiving): receive against the server's purchase orders and queue receipts with their signature

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: The receiving screens in server mode

**Files:**
- Modify: `lib/features/receiving/presentation/po_list_screen.dart`, `po_details_screen.dart`, `receive_items_screen.dart`, `receive_summary_screen.dart`
- Test: `test/features/receiving/receive_summary_screen_test.dart`

**Interfaces:**
- Consumes: `useApiProvider` (3a), `putAwayLocationsProvider`, `PurchaseOrder.displayNumber`, `PoLineItem` members and `ActiveReceiveNotifier.submitReceive({signature, locationId})` (Task 4).
- Produces:
  - `putAwayLocationProvider` (`StateProvider.autoDispose<String?>`) and `defaultPutAway(locations)`.
  - In server mode:
    - no flag control;
    - an item that isn't on the order is refused;
    - receiving more than ordered is stopped before the summary;
    - the summary asks where the goods are put away.

- [ ] **Step 1: Write the failing test**

`test/features/receiving/receive_summary_screen_test.dart`:
```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/config/app_config.dart';
import 'package:warehouse_app/core/models/count_records.dart';
import 'package:warehouse_app/core/models/purchase_order.dart';
import 'package:warehouse_app/core/router/app_routes.dart';
import 'package:warehouse_app/core/theme/app_theme.dart';
import 'package:warehouse_app/data/repositories/receiving_repository.dart';
import 'package:warehouse_app/features/receiving/presentation/receive_summary_screen.dart';
import 'package:warehouse_app/features/receiving/providers/receiving_provider.dart';

class MockReceivingRepository extends Mock implements ReceivingRepository {}

const order = PurchaseOrder(
  id: 'po-1',
  number: 'PO-SA1-001',
  supplier: 'Gula Prai Trading',
  status: PoStatus.inProgress,
  lineItems: [PoLineItem(lineId: 'pl-1', itemId: 'i1', itemCode: 'WT-0001', itemName: 'Beras Wangi 10kg', expected: 10, received: 7, alreadyReceived: 4)],
);

void main() {
  setUpAll(() => registerFallbackValue(order));

  testWidgets('the receipt goes to the dock unless another place is chosen, with the signature', (tester) async {
    final repo = MockReceivingRepository();
    when(() => repo.getPurchaseOrders()).thenAnswer((_) async => const [order]);
    when(() => repo.getPutAwayLocations()).thenAnswer((_) async => const [
          CountLocation(id: 'dock-1', code: 'DOCK-1', kind: 'Dock'),
          CountLocation(id: 'bin-1', code: 'A-01-01', kind: 'Bin'),
        ]);
    when(() => repo.submitReceive(any(), signature: any(named: 'signature'), locationId: any(named: 'locationId'))).thenAnswer((_) async {});
    final container = ProviderContainer(overrides: [
      useApiProvider.overrideWithValue(true),
      receivingRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
    container.read(activeReceiveNotifierProvider.notifier).startReceive(order);
    final router = GoRouter(initialLocation: '/summary', routes: [
      GoRoute(path: AppRoutes.receiving, builder: (_, __) => const Text('Orders')),
      GoRoute(path: '/summary', builder: (_, __) => const ReceiveSummaryScreen()),
      GoRoute(path: AppRoutes.receivingSignature, builder: (context, _) => TextButton(
            onPressed: () => context.pop(Uint8List.fromList([0x89, 0x50])),
            child: const Text('Sign'),
          )),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: MaterialApp.router(theme: AppTheme.light, routerConfig: router)));
    await tester.pumpAndSettle();

    expect(find.text('PO-SA1-001'), findsWidgets);
    expect(find.text('DOCK-1 · Dock'), findsOneWidget); // the default put-away place

    await tester.tap(find.text('Sign & Submit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign'));
    await tester.pumpAndSettle();

    verify(() => repo.submitReceive(any(), signature: any(named: 'signature', that: isNotNull), locationId: 'dock-1')).called(1);
    expect(find.text('Orders'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it to verify it fails**

Run: `$F test test/features/receiving/receive_summary_screen_test.dart`
Expected: FAIL — `Unable to find a widget with text "DOCK-1 · Dock"`, because the summary has no put-away picker yet.

- [ ] **Step 3: Order numbers, not ids**

Replace the five on-screen `order.id,` texts with `order.displayNumber,`:
- `po_list_screen.dart`, around line 273;
- `receive_summary_screen.dart`, around line 167;
- `receive_items_screen.dart`, around line 242;
- `po_details_screen.dart`, around lines 104 and 131.

In `po_list_screen.dart`'s search filter, change `order.id` to `order.displayNumber`. Leave `extra: order.id` (navigation) alone.

- [ ] **Step 4: The scanning screen in server mode**

In `lib/features/receiving/presentation/receive_items_screen.dart` (import `../../../core/config/app_config.dart`):

At the start of `_showUnknownItemDialog`, add:
```dart
    if (ref.read(useApiProvider)) {
      // The server only takes lines of the order: there is nothing to add an unknown item to.
      final number = ref.read(activeReceiveNotifierProvider)?.displayNumber ?? 'this order';
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Not on This Order'),
          content: Text("$barcode isn't on $number. Only items on the order can be received against it."),
          actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );
      _processingBarcode = false;
      return;
    }
```

In `_showManualEntryDialog`, replace the `if (!found) { … addUnknownItem … }` branch's body with:
```dart
      if (ref.read(useApiProvider)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('That item is not on this order.')));
        return;
      }
      ref.read(activeReceiveNotifierProvider.notifier).addUnknownItem(
            itemCode: result.code,
            itemName: result.code,
            qty: result.qty,
          );
```

At the start of `_onProceed`, add:
```dart
    if (ref.read(useApiProvider) && order.extraItems.isNotEmpty) {
      // The server refuses a receipt that takes a line past what was ordered.
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('More Than Ordered'),
          content: Text([
            for (final item in order.extraItems) '${item.itemName}: ordered ${item.expected}, receiving ${item.received}',
            '',
            'Reduce these to what was ordered. Extra goods need a new purchase order.',
          ].join('\n')),
          actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );
      return;
    }
```

PO line flags are dropped in server mode:
- in `_ItemRow`, make the field `final VoidCallback? onFlag;`;
- in its flag slot, change `child: IconButton(` to `child: onFlag == null ? null : IconButton(`;
- where `_ItemRow(` is built, pass `onFlag: ref.read(useApiProvider) ? null : () => _showFlagDialog(item),`.

- [ ] **Step 5: The summary asks where the goods go**

In `lib/features/receiving/presentation/receive_summary_screen.dart`:
- import `../../../core/config/app_config.dart`, `../../../core/models/count_records.dart`, `../../../core/providers/connectivity_provider.dart` and `../../../data/repositories/receiving_repository.dart`;
- add at file level:
```dart
/// Where this receipt's goods are put away (server mode). Null: the default below.
final putAwayLocationProvider = StateProvider.autoDispose<String?>((_) => null);

/// Goods usually land at a dock first; without one, the first location.
String? defaultPutAway(List<CountLocation> locations) {
  for (final l in locations) {
    if (l.kind == 'Dock') return l.id;
  }
  return locations.isEmpty ? null : locations.first.id;
}

class _PutAwayPicker extends ConsumerWidget {
  const _PutAwayPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(putAwayLocationsProvider).valueOrNull ?? const <CountLocation>[];
    if (locations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('No locations on this phone yet. Pull down on the orders list to refresh.'),
      );
    }
    final chosen = ref.watch(putAwayLocationProvider) ?? defaultPutAway(locations);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
      child: DropdownButtonFormField<String>(
        initialValue: chosen,
        decoration: const InputDecoration(labelText: 'Put away in'),
        items: [for (final l in locations) DropdownMenuItem(value: l.id, child: Text('${l.code} · ${l.kind}'))],
        onChanged: (value) => ref.read(putAwayLocationProvider.notifier).state = value,
      ),
    );
  }
}
```
- in the `ListView`'s children, before `_ItemsTable(order: order),`, add `if (ref.watch(useApiProvider)) const _PutAwayPicker(),`;
- replace `onSignAndSubmit` with:
```dart
    Future<void> onSignAndSubmit() async {
      final useApi = ref.read(useApiProvider);
      final locationId = useApi
          ? ref.read(putAwayLocationProvider) ?? defaultPutAway(ref.read(putAwayLocationsProvider).valueOrNull ?? const [])
          : null;
      if (useApi && locationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose where the goods are put away.')));
        return;
      }
      try {
        final bytes = await context.push<Uint8List?>(AppRoutes.receivingSignature);
        if (!context.mounted) return;
        await ref.read(activeReceiveNotifierProvider.notifier).submitReceive(signature: bytes, locationId: locationId);
        if (!context.mounted) return;
        if (useApi) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ref.read(isOnlineProvider) ? 'Receipt sent.' : "Receipt saved. It will be sent when you're back online."),
          ));
        }
        context.go(AppRoutes.receiving);
      } on StateError catch (error) {
        // Something the person can fix: more than is left, nothing new, no location.
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit — please try again')));
        }
        debugPrint('submitReceive failed: $error');
      }
    }
```

- [ ] **Step 6: Run every check**

Run: `$F test -r failures-only && $F analyze lib test`
Expected: the summary test PASSES; everything else PASSES except the 2 known welcome failures; analyze clean.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(receiving): server-mode receiving screens with order numbers, put-away place and the server's limits

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: End to end — receive with a signature, and count with the count time

**Files:**
- Create: `test/live/api_receiving_live_test.dart`
- Re-run: `test/live/api_counts_live_test.dart` (counting still works against the server with `countedAt`)

**Interfaces:**
- Consumes: everything above; the seeded SA1 purchase orders (some Open, some Partial); worker `arjun`.
- Produces: live test "a worker receives against a purchase order with a signature, and the order shows it".

- [ ] **Step 1: Write the test**

`test/live/api_receiving_live_test.dart`:
```dart
@Tags(['live'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_receiving_repository.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide CountItem, CountSession, UserSession;
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final api = Platform.environment['WARETRACK_API'];
final password = Platform.environment['WARETRACK_SEED_PASSWORD'] ?? 'Waretrack#2026';

/// The smallest valid PNG: one transparent pixel.
final png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  test('a worker receives against a purchase order with a signature, and the order shows it', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final client = ApiClient(baseUrl: api!, httpClient: http.Client(), tokens: TokenStore(MemoryKeyValueStore()));
    final auth = ApiAuthRepository(client: client, db: db);
    var session = await auth.login('arjun@waretrack.local', password);
    if (session.warehouseId == null) {
      session = await auth.selectWarehouse(session, session.warehouses.firstWhere((w) => w.code == 'SA1').warehouseId);
    }
    final UserSession current = session;
    final puller = ChangeFeedPuller(client: client, db: db);
    final outbox = SyncService(db: db, sender: CommandSender(client));
    final receiving = ApiReceivingRepository(db: db, session: () => current, onQueued: () {});
    await puller.pull(current.warehouseId!);

    final orders = await receiving.getPurchaseOrders();
    final order = orders.firstWhere((o) => o.lineItems.any((l) => l.alreadyReceived < l.expected));
    final line = order.lineItems.firstWhere((l) => l.alreadyReceived < l.expected);
    final dock = (await receiving.getPutAwayLocations()).first;
    await receiving.submitReceive(
      order.copyWithLines([for (final l in order.lineItems) l.lineId == line.lineId ? l.copyWith(received: l.alreadyReceived + 1) : l]),
      signature: png,
      locationId: dock.id,
    );

    expect(await outbox.flushQueue(), FlushOutcome.done);
    expect(await db.syncQueueDao.watchIssues().first, isEmpty); // the receipt and the signature were both accepted
    await puller.pull(current.warehouseId!);

    final after = (await receiving.getPurchaseOrders()).firstWhere((o) => o.id == order.id);
    expect(after.lineItems.firstWhere((l) => l.lineId == line.lineId).alreadyReceived, line.alreadyReceived + 1);
  }, skip: api == null ? 'Set WARETRACK_API=http://localhost:5050 (with the server running) to run this.' : false);
}
```

- [ ] **Step 2: Run against the local stack on the `counted-at` server branch**

```bash
cd ~/projects/Personal/DotNet/waretrack-server   # on counted-at (Task 1)
docker compose -f deploy/docker-compose.dev.yml up -d
(DOTNET_ROOT=~/.dotnet PATH=~/.dotnet:$PATH dotnet run --project src/WareTrack.Api --launch-profile http > /tmp/waretrack-api.log 2>&1 &)
until curl -fsS http://localhost:5050/health >/dev/null; do sleep 2; done
cd ~/projects/Personal/Flutter/warehouse_app/.worktrees/receiving
WARETRACK_API=http://localhost:5050 $F test test/live
$F test -r failures-only
pkill -f "WareTrack.Api"; docker compose -f ~/projects/Personal/DotNet/waretrack-server/deploy/docker-compose.dev.yml stop
```
Expected:
- both live tests PASS (receiving, and counting with the count time);
- the plain run skips them, and everything else PASSES except the 2 known welcome failures.

The live tests sign in 3 times, under the limit of 10 per minute. Do not run them twice within a minute.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "test: prove a phone receipt with a signature reaching the server

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

## Self-Review Notes

- **Decisions covered:**
  - I3 counting time → Tasks 1–2.
  - Receiving with signatures (spec §2 Receipt, §3 commands) → Tasks 3–5.
  - Mirror-migration machinery (3a minor: the cursor reset was only a note) → Task 2, enforced by `kMirrorVersion` with a test.
- **Consistency:**
  - `SyncOps.receiptCreate`/`receiptSignature` (Task 3) are queued by `ApiReceivingRepository` (Task 4).
  - `commandFor` (Task 3) is used by `SyncService` (Task 3).
  - `purchaseOrders`, `poLinesFor` and `barcodesFor` (Task 2) are used by the repository (Task 4).
  - `putAwayLocationsProvider` (Task 4) is used by the summary (Task 5).
  - `displayNumber` and `copyWithLines` (Task 4) are used by Task 5 and the live test.
- **Server compatibility:**
  - `CountedAt` is optional, so 3a phones and the admin keep working.
  - The admin only regenerates its types.
- **Not in 3b:**
  - decimal quantity entry (ask before adding);
  - delivery and sales orders (3c);
  - tasks and alerts (3d);
  - push (3e);
  - the 3a deferred minors.
