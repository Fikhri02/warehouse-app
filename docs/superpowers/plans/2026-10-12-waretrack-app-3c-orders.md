# WareTrack App 3c — Delivery and Sales Orders Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Delivery and sales orders on the phone work against the WareTrack server: they come from the change feed into the phone's copy, are created and edited offline, move through their statuses through the outbox, and show who did what.

**Architecture:** The server gains the names of whoever created or moved an order, and a status change carries the time it was made on the phone (so a dispatch made offline takes stock out at the right moment, like 3b's receipts). The app's order model moves to the server's shape (GUID string ids, a destination text for deliveries, a pick bin on every line). Orders mirror into two new Drift tables. Saves and status changes are outbox commands. `ApiOrdersRepository` reads the copy and lays the commands not yet in it on top, the same way 3b's receiving does. Sample mode keeps working through `SampleOrdersRepository`.

**Tech Stack:** Server: ASP.NET Core 10 minimal APIs, EF Core + Npgsql, xUnit + Testcontainers. App: Flutter 3.38.6 / Dart 3.10.7 (package language version 3.3), Riverpod 2.6, go_router 14, Drift 2.21 + build_runner, http 1.6 (MockClient), uuid 4.6, mocktail.

**Spec:** `/Users/irfanfikhribiniszahar/projects/Personal/AI/memory-core-fresh/brainstorming/active/warehouse-app-backend.md`. Read §3 (Commands, Responses and app behaviour) and the Plan 3 decisions in its Task List.

## Global Constraints

- Server: `~/projects/Personal/DotNet/waretrack-server`. Task 1 is on a new branch `order-names` from `api-foundation` (`e11670a`). Never work on `main`.
- App: `~/projects/Personal/Flutter/warehouse_app`. Tasks 2–7 go in the worktree `.worktrees/orders` on a new branch `orders` from `feature/order-management` (`60ac5d5`).
- .NET commands need `export DOTNET_ROOT=$HOME/.dotnet PATH=$HOME/.dotnet:$HOME/.dotnet/tools:$PATH` (the SDK in `/usr/local/share/dotnet` is too old).
- Flutter: `F=/Users/irfanfikhribiniszahar/Developer/flutter/bin/flutter`. Dart: `/Users/irfanfikhribiniszahar/Developer/flutter/bin/dart`. Run tests with `-r failures-only`.
- The package's language version is 3.3, so null-aware collection elements (`'key': ?value`) do not compile. Use `if (value != null) 'key': value`.
- **Adapt the app to the server.** IDs are GUID strings. A delivery has a destination text, not a "to" location. Each order line has a pick bin. Quantities stay `int` on the phone (3b ruling: decimals are rounded).
- **Sample repositories stay**, chosen at build time with `--dart-define=WARETRACK_API=…`.
- Every write goes through the outbox with its own Idempotency-Key. Responses: 409 means conflicted (show the reason, continue); any other 4xx means failed; 5xx, offline or 401 means stop and retry later.
- Drift generates row classes that can clash with model names. If an import becomes ambiguous, add the name to `hide` on the `app_database.dart` import, as 3b did.
- No emojis anywhere in the UI.
- Every commit message ends with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Two `welcome_screen_test` failures predate this plan and stay out of scope. The baseline is 138 pass / 2 live skipped / 2 welcome failures.

## Review Focus

1. **Editing an order whose lines use different bins** (made on another phone or in the admin): the phone keeps each line's own bin unless the person changes "Pick From". Pinned in Task 2, "loading an order keeps each line's own bin".
2. **A worker taps Approve:** the phone must say it cannot, rather than queue a command the server will refuse with 403. Pinned in Task 5, "only a supervisor can approve", and in Task 6, where workers do not see the buttons.
3. **A dispatch refused for lack of stock (409 `insufficient-stock`):** the order goes back to the status the server has, and Sync Issues explains why. Pinned in Task 5, "a dispatch the server refused leaves the order as the server has it", and by the title in Task 4.
4. **Two status changes made offline in a row (Packed, then In Transit):** they go out in order, the order shows the latest one, and once the server's copy arrives the history is not doubled. Pinned in Task 5, "two status changes made offline…".
5. **Switching warehouse or user:** the order lists and the detail screen reload for the new warehouse. Pinned in Task 6, "the delivery list follows the chosen warehouse".

---

### Task 1: Server — names on orders, and status changes keep their time

**Files:**
- Modify: `src/WareTrack.Contracts/Orders/OrderContracts.cs`
- Modify: `src/WareTrack.Api/Features/Orders/Order.cs`
- Modify: `src/WareTrack.Api/Features/Orders/OrderMapper.cs`
- Modify: `src/WareTrack.Api/Features/Orders/OrderEndpoints.cs`
- Modify: `src/WareTrack.Api/Features/Orders/OrderStatusEndpoints.cs`
- Create: `src/WareTrack.Api/Infrastructure/Migrations/<timestamp>_OrderNames.cs` (generated, then edited)
- Modify: `tests/WareTrack.Api.Tests/OrderStatusTests.cs`
- Modify: `admin/openapi/v1.json`, `admin/src/api/schema.d.ts` (regenerated), `admin/src/orders/orders.test.tsx`

**Interfaces:**
- Produces (the JSON the app's Tasks 3 and 4 rely on):
  - `OrderDto` gains `createdByName` (string), as the last field.
  - `OrderStatusChangeDto` gains `changedByName` (string), as the last field.
  - `ChangeOrderStatusRequest` is `{ status, changedAt? }`. Enum values are PascalCase strings: `Draft`, `PendingApproval`, `Submitted`, `Packed`, `InTransit`, `Shipped`; kind is `Delivery` or `Sales`.
- Consumes: `ClientTime.ToServer(HttpContext, DateTimeOffset?, DateTimeOffset)` and `StockSource(…, DateTimeOffset? OccurredAt)` from 3b.

- [ ] **Step 1: Create the branch**

```bash
cd ~/projects/Personal/DotNet/waretrack-server && git checkout -b order-names api-foundation
```

- [ ] **Step 2: Write the failing tests**

In `tests/WareTrack.Api.Tests/OrderStatusTests.cs`:
- Add `using WareTrack.Contracts.Counts;`.
- Extend the `Floor` record and `FloorAsync` with the two names.
- Give `MoveAsync` an optional time.

```csharp
    sealed record Floor(Guid WarehouseId, Guid Bin, Guid ItemId, Guid LeadId, HttpClient Lead, Guid WorkerId, HttpClient Worker,
        string LeadName, string WorkerName);

    async Task<Floor> FloorAsync(decimal stock)
    {
        var warehouse = await fx.Api.CreateWarehouseAsync();
        var bin = (await fx.Api.CreateLocationsAsync(warehouse.Id, 1))[0];
        var item = await fx.Api.CreateItemAsync();
        await fx.Api.SetStockAsync(warehouse.Id, bin.Id, item.Id, stock);
        var (lead, leadClient) = await fx.Api.MemberAsync(warehouse.Id, WarehouseRole.Supervisor);
        var (worker, workerClient) = await fx.Api.MemberAsync(warehouse.Id, WarehouseRole.Worker);
        return new Floor(warehouse.Id, bin.Id, item.Id, lead.Id, leadClient, worker.Id, workerClient, lead.DisplayName, worker.DisplayName);
    }

    static Task<HttpResponseMessage> MoveAsync(HttpClient client, Floor f, OrderDto order, OrderStatus to, DateTimeOffset? changedAt = null) =>
        client.SendCommandAsync(HttpMethod.Post,
            $"/warehouses/{f.WarehouseId}/{(order.Kind == OrderKind.Delivery ? "delivery" : "sales")}-orders/{order.Id}/status",
            new ChangeOrderStatusRequest(to, changedAt));
```

Then add these three tests to the class:

```csharp
    [Fact]
    public async Task The_order_and_each_status_change_name_who_made_them()
    {
        var f = await FloorAsync(stock: 10);
        var order = await f.Worker.CreateOrderAsync(f.WarehouseId, f.Bin, f.ItemId, 4, requiresApproval: true);
        await (await MoveAsync(f.Worker, f, order, OrderStatus.PendingApproval)).ReadAsync<OrderDto>();

        var approved = await (await MoveAsync(f.Lead, f, order, OrderStatus.Submitted)).ReadAsync<OrderDto>();

        Assert.Equal(f.WorkerName, approved.CreatedByName);
        Assert.Equal(new[] { f.WorkerName, f.WorkerName, f.LeadName }, approved.StatusHistory.Select(h => h.ChangedByName));
    }

    [Fact]
    public async Task A_dispatch_made_offline_counts_from_when_the_goods_left()
    {
        var f = await FloorAsync(stock: 10);
        var order = await f.Worker.CreateOrderAsync(f.WarehouseId, f.Bin, f.ItemId, 4);
        await (await MoveAsync(f.Worker, f, order, OrderStatus.Submitted)).ReadAsync<OrderDto>();
        await (await MoveAsync(f.Worker, f, order, OrderStatus.Packed)).ReadAsync<OrderDto>();
        var leftAt = DateTimeOffset.UtcNow;    // the goods leave while the phone is offline...
        await Task.Delay(20);
        var countedAt = DateTimeOffset.UtcNow; // ...then the bin is counted: 6 left
        await Task.Delay(20);
        await (await MoveAsync(f.Worker, f, order, OrderStatus.InTransit, leftAt)).ReadAsync<OrderDto>();
        var session = Guid.NewGuid();
        await (await f.Worker.SendCommandAsync(HttpMethod.Post, $"/warehouses/{f.WarehouseId}/count-sessions/{session}/submit",
            new SubmitCountRequest(null, [new CountLineInput(f.ItemId, f.Bin, 6)], countedAt))).ReadAsync<CountSessionDto>();

        await (await f.Lead.SendCommandAsync(HttpMethod.Post, $"/warehouses/{f.WarehouseId}/count-sessions/{session}/approve")).ReadAsync<CountSessionDto>();

        Assert.Equal(6, await fx.Api.StockAsync(f.Bin, f.ItemId)); // the dispatch is not taken off a second time
    }

    [Fact]
    public async Task A_change_stamped_by_a_slow_phone_clock_never_lands_before_the_last_change()
    {
        var f = await FloorAsync(stock: 10);
        var order = await f.Worker.CreateOrderAsync(f.WarehouseId, f.Bin, f.ItemId, 4);
        var submitted = await (await MoveAsync(f.Worker, f, order, OrderStatus.Submitted)).ReadAsync<OrderDto>();

        var packed = await (await MoveAsync(f.Worker, f, order, OrderStatus.Packed, DateTimeOffset.UtcNow.AddHours(-1))).ReadAsync<OrderDto>();

        Assert.True(packed.StatusHistory[^1].ChangedAt >= submitted.StatusHistory[^1].ChangedAt);
    }
```

- [ ] **Step 3: Run the tests to watch them fail**

Run: `dotnet test tests/WareTrack.Api.Tests --filter "FullyQualifiedName~OrderStatusTests"`
Expected: build FAILS with CS1061 / CS1739 errors naming `CreatedByName`, `ChangedByName`, and the second argument of `ChangeOrderStatusRequest`.

- [ ] **Step 4: Add the contract fields**

In `src/WareTrack.Contracts/Orders/OrderContracts.cs` replace the three records:

```csharp
/// <param name="ChangedAt">When the change was made on the phone, if it was made offline.</param>
public sealed record ChangeOrderStatusRequest(OrderStatus Status, DateTimeOffset? ChangedAt = null);

public sealed record OrderStatusChangeDto(OrderStatus Status, Guid ChangedByUserId, DateTimeOffset ChangedAt, string ChangedByName);

public sealed record OrderDto(
    Guid Id, Guid WarehouseId, OrderKind Kind, string Number, string? Destination, string? CustomerName, DateOnly Date,
    OrderStatus Status, bool RequiresApproval, string? Notes, Guid CreatedByUserId, DateTimeOffset CreatedAt,
    IReadOnlyList<OrderLineDto> Lines, IReadOnlyList<OrderStatusChangeDto> StatusHistory, string CreatedByName);
```

- [ ] **Step 5: Store the names**

In `Order.cs`:
- Add to `Order`, after `CreatedByUserId`:
  ```csharp
      /// <summary>The creator's display name when the order was made, so phones can show it without a user list.</summary>
      public string CreatedByName { get; set; } = "";
  ```
- Add to `OrderStatusChange`, after `ChangedByUserId`:
  ```csharp
      public string ChangedByName { get; set; } = "";
  ```
- In `OrderConfiguration.Configure` add `b.Property(o => o.CreatedByName).HasMaxLength(200);`.
- In `OrderStatusChangeConfiguration.Configure` add `b.Property(h => h.ChangedByName).HasMaxLength(200);`.

In `OrderMapper.ToDto` pass the names:

```csharp
    public static OrderDto ToDto(Order o) => new(
        o.Id, o.WarehouseId, o.Kind, o.Number, o.Destination, o.CustomerName, o.Date, o.Status, o.RequiresApproval, o.Notes,
        o.CreatedByUserId, o.CreatedAt,
        o.Lines.Select(l => new OrderLineDto(l.Id, l.ItemId, l.LocationId, l.Quantity)).ToList(),
        o.StatusHistory.OrderBy(h => h.ChangedAt).Select(h => new OrderStatusChangeDto(h.Status, h.ChangedByUserId, h.ChangedAt, h.ChangedByName)).ToList(),
        o.CreatedByName);
```

In `OrderEndpoints.UpsertAsync`, replace the `if (order is null) { … }` block with:

```csharp
        if (order is null)
        {
            var userName = await db.Users.Where(u => u.Id == userId).Select(u => u.DisplayName).SingleAsync(ct);
            order = new Order
            {
                Id = orderId, WarehouseId = warehouseId, Kind = kind, Number = f.Number.Trim(), Status = OrderStatus.Draft,
                CreatedByUserId = userId, CreatedByName = userName, CreatedAt = now,
            };
            order.StatusHistory.Add(new OrderStatusChange
            {
                Id = Guid.NewGuid(), Status = OrderStatus.Draft, ChangedByUserId = userId, ChangedByName = userName, ChangedAt = now,
            });
            orders.Add(order);
        }
```

- [ ] **Step 6: Status changes keep their time and name**

In `OrderStatusEndpoints.cs`:
- Change both lambdas in `MapOrderStatus` to pass the whole request (`r`) instead of `r.Status`.
- Replace `ChangeAsync` with:

```csharp
    static async Task<IResult> ChangeAsync(OrderKind kind, Guid warehouseId, Guid orderId, ChangeOrderStatusRequest request, HttpContext http,
        WareTrackDbContext db, IOrderSource orders, StockLedger ledger, Conflicts conflicts, TimeProvider clock, CancellationToken ct)
    {
        var to = request.Status;
        var order = await orders.LoadAsync(warehouseId, orderId, ct);
        if (order is null || order.Kind != kind) return Problems.Of(StatusCodes.Status404NotFound, "order-not-found", "Order not found");
        if (order.Status == to) return TypedResults.Ok(OrderMapper.ToDto(order));

        var from = order.Status;
        if (!Allowed[from].Contains(to))
            return await conflicts.RejectAsync(http.User, warehouseId, "invalid-status-transition", "Order status changed",
                $"{order.Number} is {from}; it cannot move to {to}.", ct);
        if (from == OrderStatus.Draft && to == OrderStatus.Submitted && order.RequiresApproval)
            return await conflicts.RejectAsync(http.User, warehouseId, "approval-required", "Approval required",
                $"{order.Number} needs a supervisor's approval before it is submitted.", ct);
        if (from == OrderStatus.PendingApproval && to == OrderStatus.Submitted
            && (WarehouseRole)http.Items[WarehouseAccess.RoleKey]! != WarehouseRole.Supervisor)
            return Problems.Of(StatusCodes.Status403Forbidden, "approval-requires-supervisor", "Only a supervisor can approve this order");

        var userId = http.User.UserId();
        var now = clock.GetUtcNow();
        // A change made offline keeps the time it was made, corrected for the phone's clock, but never lands before the
        // order's last change.
        var at = ClientTime.ToServer(http, request.ChangedAt, now) ?? now;
        var last = order.StatusHistory.Select(h => h.ChangedAt).DefaultIfEmpty(at).Max();
        if (at < last) at = last;

        if (to == OrderStatus.InTransit)
        {
            // The goods leave the building: take them out of their pick bins, all or nothing, at the time they left.
            var reason = kind == OrderKind.Delivery ? MovementReason.DeliveryOut : MovementReason.SalesOut;
            var shortfalls = await ledger.ApplyAsync(warehouseId,
                order.Lines.Select(l => new StockChange(l.LocationId, l.ItemId, -l.Quantity)).ToList(),
                new StockSource(reason, "order", order.Id, userId, at), ct);
            if (shortfalls.Count > 0)
            {
                var detail = string.Join("; ", shortfalls.Select(s => $"bin holds {s.Available:0.###}, order needs {s.Requested:0.###}"));
                return await conflicts.RejectAsync(http.User, warehouseId, "insufficient-stock", "Not enough stock to dispatch",
                    $"{order.Number}: {detail}.", ct);
            }
        }

        var userName = await db.Users.Where(u => u.Id == userId).Select(u => u.DisplayName).SingleAsync(ct);
        order.Status = to;
        order.StatusHistory.Add(new OrderStatusChange { Id = Guid.NewGuid(), Status = to, ChangedByUserId = userId, ChangedByName = userName, ChangedAt = at });
        order.UpdatedAt = now;
        await orders.OnStatusChangedAsync(order, from, ct);
        await db.SaveChangesAsync(ct);
        return TypedResults.Ok(OrderMapper.ToDto(order));
    }
```

Add `using Microsoft.EntityFrameworkCore;` to `OrderStatusEndpoints.cs` if it is missing (`SingleAsync`).

- [ ] **Step 7: Migration with backfill**

Run: `dotnet ef migrations add OrderNames -p src/WareTrack.Api -o Infrastructure/Migrations`
Expected: `Done.` The new `Up` adds `created_by_name` to `orders` and `changed_by_name` to `order_status_changes`.

In the generated `Up`, after the two `AddColumn` calls, add:

```csharp
            // Orders so far get the names their users have now.
            migrationBuilder.Sql("""
                UPDATE orders o SET created_by_name = u.display_name FROM "AspNetUsers" u WHERE u.id = o.created_by_user_id;
                UPDATE order_status_changes h SET changed_by_name = u.display_name FROM "AspNetUsers" u WHERE u.id = h.changed_by_user_id;
                """);
```

- [ ] **Step 8: Run the tests to watch them pass**

Run: `dotnet test tests/WareTrack.Api.Tests --filter "FullyQualifiedName~OrderStatusTests|FullyQualifiedName~OrderTests"`
Expected: PASS, including the 3 new tests.

- [ ] **Step 9: Refresh the OpenAPI snapshot and the admin client**

```bash
UPDATE_OPENAPI_SNAPSHOT=1 dotnet test tests/WareTrack.Api.Tests --filter "FullyQualifiedName~OpenApiSnapshot"
cd admin && npm run gen:api && npx tsc -b
```

Expected: `tsc` fails in `src/orders/orders.test.tsx`, because the fixture lacks `createdByName` / `changedByName`. Fix the fixture:
- Add `createdByName: 'Arjun Nair',` beside `createdByUserId: WORKER.userId,`.
- Add `changedByName: 'Arjun Nair'` to the two history rows with `WORKER.userId`.
- Add `changedByName: 'Hafiz Rahman'` to the `crypto.randomUUID()` row.

Run `npx tsc -b` again. Expected: exit 0. Then delete the build info file `tsc -b` leaves behind: `rm -f tsconfig.tsbuildinfo`.

- [ ] **Step 10: Full suites**

Run: `dotnet test` (repo root), then `cd admin && npx vitest run`
Expected: all server tests pass (151 + 3 = 154), and the admin's 88 pass.

- [ ] **Step 11: Commit**

```bash
git add -A src tests admin/openapi admin/src
git commit -m "feat(orders): name who made each order change, and keep offline change times

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: App — the order model takes the server's shape (Sample mode)

**Files:**
- Create the worktree: `.worktrees/orders` (branch `orders`)
- Modify: `lib/core/models/order.dart`
- Modify: `lib/data/repositories/orders_repository.dart` (interface, sample, providers)
- Modify: `lib/data/sample/sample_order_locations.dart`
- Modify: `lib/core/widgets/item_picker_sheet.dart`
- Modify: `lib/features/delivery_orders/providers/create_delivery_order_notifier.dart`, `delivery_orders_provider.dart`
- Modify: `lib/features/sales_orders/providers/create_sales_order_notifier.dart`, `sales_orders_provider.dart`
- Modify: `lib/features/delivery_orders/presentation/*.dart`, `lib/features/delivery_orders/presentation/widgets/delivery_order_card.dart`
- Modify: `lib/features/sales_orders/presentation/*.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/features/orders/create_delivery_order_notifier_test.dart`, `test/features/orders/create_sales_order_notifier_test.dart`

**Interfaces:**
- Produces:
  - `enum OrderKind { delivery, sales }` with `String get serverName` (`'Delivery'`, `'Sales'`).
  - `OrderStatus.fromServer(String)` and `String get serverName` (`'Draft'`, `'PendingApproval'`, `'Submitted'`, `'Packed'`, `'InTransit'`, `'Shipped'`).
  - `OrderLocation` with `==`/`hashCode` by `id`.
  - `OrderItem({itemId, itemName, itemSku, quantity, String? locationId, String? locationCode})`.
  - `DeliveryOrder({required String id, orderNumber, required String destination, deliveryDate, status, requiresApproval, notes, createdBy, createdAt, items, statusHistory})`.
  - `SalesOrder({required String id, …})`.
  - `abstract class OrdersRepository`:
    - `getDeliveryOrders({required bool active})`, `getSalesOrders({required bool active})`
    - `getDeliveryOrderById(String id)`, `getSalesOrderById(String id)`
    - `saveDeliveryOrder(DeliveryOrder)`, `saveSalesOrder(SalesOrder)`: create or update by id. An empty `orderNumber` means "give it one". `status` is where the order should end up: draft, pendingApproval or submitted.
    - `updateOrderStatus({required OrderKind kind, required String id, required OrderStatus status})`
    - `getPickLocations()` → `List<OrderLocation>`
    - `searchItems(String term)` → `List<CatalogItem>`
    - `findItem(String code)` → `CatalogItem?`
  - Providers in `orders_repository.dart`: `ordersRepositoryProvider`, `pickLocationsProvider` (`FutureProvider<List<OrderLocation>>`), `orderCatalogSearchProvider` (`FutureProvider.autoDispose.family<List<CatalogItem>, String>`).
  - Notifiers: `setPickFrom(OrderLocation?)`, `setDestination(String)` (delivery), `setItems(List<OrderItem>)`, which stamps lines without a bin with the Pick From bin. `submit({required bool asDraft})` returns the saved order.

- [ ] **Step 1: Create the worktree**

```bash
cd ~/projects/Personal/Flutter/warehouse_app && git worktree add .worktrees/orders -b orders feature/order-management
cd .worktrees/orders && $F pub get
```

All app paths below are relative to `.worktrees/orders`.

- [ ] **Step 2: Write the failing notifier tests**

`test/features/orders/create_delivery_order_notifier_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/features/delivery_orders/providers/create_delivery_order_notifier.dart';

const binA = OrderLocation(id: 'bin-a', name: 'A-01-01', type: 'Bin');
const binB = OrderLocation(id: 'bin-b', name: 'B-01-01', type: 'Bin');
const beras = OrderItem(itemId: 'C-001', itemName: 'Beras 5kg', itemSku: 'SKU-BERAS-5KG', quantity: 3);

void main() {
  late SampleOrdersRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = SampleOrdersRepository();
    container = ProviderContainer(overrides: [ordersRepositoryProvider.overrideWithValue(repo)]);
  });
  tearDown(() => container.dispose());

  CreateDeliveryOrderNotifier notifier() => container.read(createDeliveryOrderNotifierProvider.notifier);
  CreateDeliveryOrderState state() => container.read(createDeliveryOrderNotifierProvider);

  test('a delivery needs a destination and a bin to pick from', () {
    expect(notifier().validateStep1(), isFalse);
    expect(state().errors.keys, containsAll(['destination', 'pickFrom']));
  });

  test('items are picked from the chosen bin, and changing the bin moves every line', () {
    notifier()
      ..setPickFrom(binA)
      ..setItems([beras]);
    expect(state().items.single.locationId, 'bin-a');

    notifier().setPickFrom(binB);

    final line = state().items.single;
    expect((line.locationId, line.locationCode), ('bin-b', 'B-01-01'));
  });

  test('loading an order keeps each line\'s own bin', () {
    notifier().loadFromOrder(DeliveryOrder(
      id: 'do-x',
      orderNumber: 'DO-X',
      destination: 'Outlet Subang',
      deliveryDate: DateTime(2026, 10, 14),
      status: OrderStatus.draft,
      requiresApproval: false,
      createdBy: 'Hafiz Rahman',
      createdAt: DateTime(2026, 10, 12),
      items: [
        beras.copyWith(locationId: 'bin-a', locationCode: 'A-01-01'),
        const OrderItem(itemId: 'C-002', itemName: 'Minyak', itemSku: 'SKU-MINYAK-5L', locationId: 'bin-b', locationCode: 'B-01-01'),
      ],
    ));

    notifier().setItems([...state().items, const OrderItem(itemId: 'C-003', itemName: 'Gula', itemSku: 'SKU-GULA-1KG')]);

    expect(state().items.map((i) => i.locationId), ['bin-a', 'bin-b', 'bin-a']); // the new line takes Pick From (the first line's bin)
  });

  test('a new order needing approval is saved under its own id and waits for approval', () async {
    notifier()
      ..setPickFrom(binA)
      ..setDestination('Outlet Damansara')
      ..toggleApproval(true)
      ..setItems([beras]);

    final saved = await notifier().submit(asDraft: false);

    expect(saved.id, hasLength(36));
    expect(saved.status, OrderStatus.pendingApproval);
    final stored = await repo.getDeliveryOrderById(saved.id);
    expect((stored!.destination, stored.items.single.locationId, stored.orderNumber.isNotEmpty), ('Outlet Damansara', 'bin-a', true));
  });

  test('editing an order keeps its id and number', () async {
    final existing = (await repo.getDeliveryOrders(active: true)).first;
    notifier().loadFromOrder(existing);
    notifier().setDestination('Outlet Ampang');

    final saved = await notifier().submit(asDraft: true);

    expect((saved.id, saved.orderNumber, saved.destination), (existing.id, existing.orderNumber, 'Outlet Ampang'));
  });
}
```

`test/features/orders/create_sales_order_notifier_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/features/sales_orders/providers/create_sales_order_notifier.dart';

const binA = OrderLocation(id: 'bin-a', name: 'A-01-01', type: 'Bin');

void main() {
  late SampleOrdersRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = SampleOrdersRepository();
    container = ProviderContainer(overrides: [ordersRepositoryProvider.overrideWithValue(repo)]);
  });
  tearDown(() => container.dispose());

  test('a sales order needs a customer and a bin to pick from', () {
    final notifier = container.read(createSalesOrderNotifierProvider.notifier);

    expect(notifier.validateStep1(), isFalse);
    expect(container.read(createSalesOrderNotifierProvider).errors.keys, containsAll(['customerName', 'pickFrom']));
  });

  test('a sales order is saved with its lines picked from the chosen bin', () async {
    final notifier = container.read(createSalesOrderNotifierProvider.notifier)
      ..setPickFrom(binA)
      ..setCustomerName('Kedai Maju Jaya')
      ..setItems([const OrderItem(itemId: 'C-005', itemName: 'Susu Pekat 500g', itemSku: 'SKU-SUSU-500G', quantity: 6)]);

    final saved = await notifier.submit(asDraft: false);

    final stored = await repo.getSalesOrderById(saved.id);
    expect((stored!.customerName, stored.status, stored.items.single.locationCode), ('Kedai Maju Jaya', OrderStatus.submitted, 'A-01-01'));
  });
}
```

- [ ] **Step 3: Run them to watch them fail**

Run: `$F test test/features/orders -r failures-only`
Expected: compilation FAILS: `setPickFrom`, `setDestination`, `locationId`, `destination`, and `SampleOrdersRepository` with a String id are not defined.

- [ ] **Step 4: The model**

In `lib/core/models/order.dart`:

1. Add, right after the `OrderStatus` enum's `nextActionLabel` getter (inside the enum):

```dart
  /// The server's name for this status (spec §3).
  String get serverName => switch (this) {
        OrderStatus.draft => 'Draft',
        OrderStatus.pendingApproval => 'PendingApproval',
        OrderStatus.submitted => 'Submitted',
        OrderStatus.packed => 'Packed',
        OrderStatus.inTransit => 'InTransit',
        OrderStatus.shipped => 'Shipped',
      };

  static OrderStatus fromServer(String value) => OrderStatus.values.firstWhere(
        (s) => s.serverName == value,
        orElse: () => throw ArgumentError('Unsupported order status: $value'),
      );
```

2. Add above `class OrderLocation`:

```dart
enum OrderKind {
  delivery,
  sales;

  String get serverName => this == OrderKind.delivery ? 'Delivery' : 'Sales';
}
```

3. In `OrderLocation`, add after the constructor:

```dart
  @override
  bool operator ==(Object other) => other is OrderLocation && other.id == id;

  @override
  int get hashCode => id.hashCode;
```

4. Replace `OrderItem` with:

```dart
class OrderItem {
  final String itemId;
  final String itemName;
  final String itemSku;
  final int quantity;

  /// The bin the goods are picked from, and its code.
  final String? locationId;
  final String? locationCode;

  const OrderItem({
    required this.itemId,
    required this.itemName,
    required this.itemSku,
    this.quantity = 1,
    this.locationId,
    this.locationCode,
  });

  OrderItem copyWith({
    String? itemId,
    String? itemName,
    String? itemSku,
    int? quantity,
    String? locationId,
    String? locationCode,
  }) {
    return OrderItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemSku: itemSku ?? this.itemSku,
      quantity: quantity ?? this.quantity,
      locationId: locationId ?? this.locationId,
      locationCode: locationCode ?? this.locationCode,
    );
  }
}
```

5. In `DeliveryOrder`:
   - `final int id;` becomes `final String id;`.
   - Remove `fromLocation` and `toLocation` (field, constructor and `copyWith`), and add `final String destination;` (`required this.destination` in the constructor; `String? destination` in `copyWith`, `destination: destination ?? this.destination`).
   - In `copyWith`, `int? id` becomes `String? id`.
6. In `SalesOrder`: `final int id;` becomes `final String id;`, and `int? id` becomes `String? id` in `copyWith`.

- [ ] **Step 5: The repository interface, the sample and the providers**

Replace `lib/data/sample/sample_order_locations.dart` with:

```dart
import 'package:warehouse_app/core/models/order.dart';

/// Bins to pick from in Sample mode.
const sampleOrderLocations = <OrderLocation>[
  OrderLocation(id: 'bin-a0101', name: 'A-01-01', type: 'Bin'),
  OrderLocation(id: 'bin-a0102', name: 'A-01-02', type: 'Bin'),
  OrderLocation(id: 'bin-b0101', name: 'B-01-01', type: 'Bin'),
  OrderLocation(id: 'dock-1', name: 'DOCK-1', type: 'Dock'),
];
```

Replace `lib/data/repositories/orders_repository.dart` with the version below. The sample orders keep their names, quantities and histories; only their ids, destinations and bins change.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/data/sample/sample_order_catalog.dart';
import 'package:warehouse_app/data/sample/sample_order_locations.dart';

abstract class OrdersRepository {
  Future<List<DeliveryOrder>> getDeliveryOrders({required bool active});
  Future<List<SalesOrder>> getSalesOrders({required bool active});
  Future<DeliveryOrder?> getDeliveryOrderById(String id);
  Future<SalesOrder?> getSalesOrderById(String id);

  /// Creates or updates the order with this id. An empty number means "give it one". [DeliveryOrder.status] is where the
  /// order should end up: draft, pendingApproval or submitted.
  Future<DeliveryOrder> saveDeliveryOrder(DeliveryOrder order);
  Future<SalesOrder> saveSalesOrder(SalesOrder order);
  Future<void> updateOrderStatus({required OrderKind kind, required String id, required OrderStatus status});

  /// Where goods can be picked from: bins first.
  Future<List<OrderLocation>> getPickLocations();
  Future<List<CatalogItem>> searchItems(String term);

  /// The item with this barcode or SKU.
  Future<CatalogItem?> findItem(String code);
}

class SampleOrdersRepository implements OrdersRepository {
  SampleOrdersRepository({this.userName = 'Hasan'});

  final String userName;
  final List<OrderLocation> _bins = List.unmodifiable(sampleOrderLocations);

  OrderItem _line(String id, String name, String sku, int quantity, int bin) => OrderItem(
        itemId: id,
        itemName: name,
        itemSku: sku,
        quantity: quantity,
        locationId: _bins[bin].id,
        locationCode: _bins[bin].name,
      );

  late final List<DeliveryOrder> _deliveryOrders = [
    DeliveryOrder(
      id: 'do-1',
      orderNumber: 'DO-2026-0001',
      destination: 'Outlet Damansara',
      deliveryDate: DateTime(2026, 4, 20),
      status: OrderStatus.submitted,
      requiresApproval: false,
      notes: 'Urgent outlet restock',
      createdBy: 'Aisyah',
      createdAt: DateTime(2026, 4, 18, 9, 0),
      items: [
        _line('C-001', 'Beras 5kg', 'SKU-BERAS-5KG', 8, 0),
        _line('C-002', 'Minyak Masak 5L', 'SKU-MINYAK-5L', 4, 0),
      ],
      statusHistory: [
        OrderStatusHistory(id: 'h-1', status: OrderStatus.submitted, changedBy: 'Aisyah', changedAt: DateTime(2026, 4, 18, 9, 0)),
      ],
    ),
    DeliveryOrder(
      id: 'do-2',
      orderNumber: 'DO-2026-0002',
      destination: 'Outlet Cheras',
      deliveryDate: DateTime(2026, 4, 21),
      status: OrderStatus.pendingApproval,
      requiresApproval: true,
      notes: 'Large transfer for promo weekend',
      createdBy: 'Irfan',
      createdAt: DateTime(2026, 4, 18, 11, 20),
      items: [
        _line('C-003', 'Gula Putih 1kg', 'SKU-GULA-1KG', 12, 1),
        _line('C-004', 'Tepung Gandum 1kg', 'SKU-TEPUNG-1KG', 10, 1),
      ],
      statusHistory: [
        OrderStatusHistory(id: 'h-2', status: OrderStatus.pendingApproval, changedBy: 'Irfan', changedAt: DateTime(2026, 4, 18, 11, 20)),
      ],
    ),
    DeliveryOrder(
      id: 'do-3',
      orderNumber: 'DO-2026-0003',
      destination: 'Outlet Subang',
      deliveryDate: DateTime(2026, 4, 17),
      status: OrderStatus.shipped,
      requiresApproval: false,
      createdBy: 'Hakim',
      createdAt: DateTime(2026, 4, 16, 14, 30),
      items: [_line('C-006', 'Mi Segera Kari', 'SKU-MI-KARI', 20, 2)],
      statusHistory: [
        OrderStatusHistory(id: 'h-3a', status: OrderStatus.submitted, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 16, 14, 30)),
        OrderStatusHistory(id: 'h-3b', status: OrderStatus.packed, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 16, 16, 0)),
        OrderStatusHistory(id: 'h-3c', status: OrderStatus.inTransit, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 17, 9, 10)),
        OrderStatusHistory(id: 'h-3d', status: OrderStatus.shipped, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 17, 13, 45)),
      ],
    ),
  ];

  late final List<SalesOrder> _salesOrders = [
    SalesOrder(
      id: 'so-1',
      orderNumber: 'SO-2026-0001',
      customerName: 'Kedai Maju Jaya',
      orderDate: DateTime(2026, 4, 19),
      status: OrderStatus.draft,
      requiresApproval: false,
      notes: 'Waiting for final confirmation',
      createdBy: 'Aisyah',
      createdAt: DateTime(2026, 4, 19, 8, 30),
      items: [_line('C-005', 'Susu Pekat 500g', 'SKU-SUSU-500G', 6, 0)],
      statusHistory: [
        OrderStatusHistory(id: 's-1', status: OrderStatus.draft, changedBy: 'Aisyah', changedAt: DateTime(2026, 4, 19, 8, 30)),
      ],
    ),
    SalesOrder(
      id: 'so-2',
      orderNumber: 'SO-2026-0002',
      customerName: 'Restoran Seri Damai',
      orderDate: DateTime(2026, 4, 18),
      status: OrderStatus.packed,
      requiresApproval: false,
      notes: 'Deliver before noon',
      createdBy: 'Hakim',
      createdAt: DateTime(2026, 4, 18, 10, 15),
      items: [
        _line('C-007', 'Air Mineral 1.5L', 'SKU-AIR-15L', 15, 1),
        _line('C-010', 'Biskut Kraker 300g', 'SKU-BISKUT-300G', 10, 1),
      ],
      statusHistory: [
        OrderStatusHistory(id: 's-2a', status: OrderStatus.submitted, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 18, 10, 15)),
        OrderStatusHistory(id: 's-2b', status: OrderStatus.packed, changedBy: 'Hakim', changedAt: DateTime(2026, 4, 18, 12, 40)),
      ],
    ),
    SalesOrder(
      id: 'so-3',
      orderNumber: 'SO-2026-0003',
      customerName: 'Cafe Sentral',
      orderDate: DateTime(2026, 4, 16),
      status: OrderStatus.shipped,
      requiresApproval: true,
      createdBy: 'Irfan',
      createdAt: DateTime(2026, 4, 16, 9, 5),
      items: [
        _line('C-008', 'Sardin Tin 425g', 'SKU-SARDIN-425G', 18, 2),
        _line('C-009', 'Kopi O 200g', 'SKU-KOPI-200G', 8, 2),
      ],
      statusHistory: [
        OrderStatusHistory(id: 's-3a', status: OrderStatus.pendingApproval, changedBy: 'Irfan', changedAt: DateTime(2026, 4, 16, 9, 5)),
        OrderStatusHistory(id: 's-3b', status: OrderStatus.submitted, changedBy: 'Nadia', changedAt: DateTime(2026, 4, 16, 9, 45)),
        OrderStatusHistory(id: 's-3c', status: OrderStatus.packed, changedBy: 'Nadia', changedAt: DateTime(2026, 4, 16, 11, 15)),
        OrderStatusHistory(id: 's-3d', status: OrderStatus.inTransit, changedBy: 'Nadia', changedAt: DateTime(2026, 4, 16, 12, 30)),
        OrderStatusHistory(id: 's-3e', status: OrderStatus.shipped, changedBy: 'Nadia', changedAt: DateTime(2026, 4, 16, 15, 0)),
      ],
    ),
  ];

  @override
  Future<List<DeliveryOrder>> getDeliveryOrders({required bool active}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _deliveryOrders.where((o) => o.status.isActive == active).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<SalesOrder>> getSalesOrders({required bool active}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _salesOrders.where((o) => o.status.isActive == active).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<DeliveryOrder?> getDeliveryOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    for (final order in _deliveryOrders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<SalesOrder?> getSalesOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    for (final order in _salesOrders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<DeliveryOrder> saveDeliveryOrder(DeliveryOrder order) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _deliveryOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      final current = _deliveryOrders[index];
      final saved = order.copyWith(
        orderNumber: current.orderNumber,
        createdBy: current.createdBy,
        createdAt: current.createdAt,
        statusHistory: _moved(current.statusHistory, current.status, order.status),
      );
      _deliveryOrders[index] = saved;
      return saved;
    }
    final now = DateTime.now();
    final saved = order.copyWith(
      orderNumber: 'DO-${now.year}-${(_deliveryOrders.length + 1).toString().padLeft(4, '0')}',
      createdBy: userName,
      createdAt: now,
      statusHistory: [OrderStatusHistory(id: '${order.id}-0', status: order.status, changedBy: userName, changedAt: now)],
    );
    _deliveryOrders.insert(0, saved);
    return saved;
  }

  @override
  Future<SalesOrder> saveSalesOrder(SalesOrder order) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _salesOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      final current = _salesOrders[index];
      final saved = order.copyWith(
        orderNumber: current.orderNumber,
        createdBy: current.createdBy,
        createdAt: current.createdAt,
        statusHistory: _moved(current.statusHistory, current.status, order.status),
      );
      _salesOrders[index] = saved;
      return saved;
    }
    final now = DateTime.now();
    final saved = order.copyWith(
      orderNumber: 'SO-${now.year}-${(_salesOrders.length + 1).toString().padLeft(4, '0')}',
      createdBy: userName,
      createdAt: now,
      statusHistory: [OrderStatusHistory(id: '${order.id}-0', status: order.status, changedBy: userName, changedAt: now)],
    );
    _salesOrders.insert(0, saved);
    return saved;
  }

  @override
  Future<void> updateOrderStatus({required OrderKind kind, required String id, required OrderStatus status}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (kind == OrderKind.delivery) {
      final index = _deliveryOrders.indexWhere((o) => o.id == id);
      if (index == -1) return;
      final current = _deliveryOrders[index];
      _deliveryOrders[index] = current.copyWith(status: status, statusHistory: _moved(current.statusHistory, current.status, status));
      return;
    }
    final index = _salesOrders.indexWhere((o) => o.id == id);
    if (index == -1) return;
    final current = _salesOrders[index];
    _salesOrders[index] = current.copyWith(status: status, statusHistory: _moved(current.statusHistory, current.status, status));
  }

  List<OrderStatusHistory> _moved(List<OrderStatusHistory> history, OrderStatus from, OrderStatus to) => from == to
      ? history
      : [
          ...history,
          OrderStatusHistory(id: 'h-${DateTime.now().microsecondsSinceEpoch}', status: to, changedBy: userName, changedAt: DateTime.now()),
        ];

  @override
  Future<List<OrderLocation>> getPickLocations() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _bins;
  }

  @override
  Future<List<CatalogItem>> searchItems(String term) async {
    final query = term.trim().toLowerCase();
    return [
      for (final item in sampleOrderCatalog)
        if (query.isEmpty || item.name.toLowerCase().contains(query) || item.sku.toLowerCase().contains(query)) item,
    ];
  }

  @override
  Future<CatalogItem?> findItem(String code) async {
    for (final item in sampleOrderCatalog) {
      if (item.sku == code.trim()) return item;
    }
    return null;
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  throw UnimplementedError('ordersRepositoryProvider not overridden');
});

final pickLocationsProvider = FutureProvider<List<OrderLocation>>((ref) => ref.watch(ordersRepositoryProvider).getPickLocations());

final orderCatalogSearchProvider = FutureProvider.autoDispose.family<List<CatalogItem>, String>(
  (ref, term) => ref.watch(ordersRepositoryProvider).searchItems(term),
);
```

Update the order providers:
- In `lib/features/delivery_orders/providers/delivery_orders_provider.dart`, delete `locationsProvider`, and change `deliveryOrderDetailProvider` to `FutureProvider.family<DeliveryOrder?, String>`.
- In `lib/features/sales_orders/providers/sales_orders_provider.dart`, change `salesOrderDetailProvider` to `FutureProvider.family<SalesOrder?, String>`.

- [ ] **Step 6: The notifiers**

Replace `lib/features/delivery_orders/providers/create_delivery_order_notifier.dart` with:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/features/delivery_orders/providers/delivery_orders_provider.dart';

class CreateDeliveryOrderState {
  final String? editingOrderId;
  final String? editingOrderNumber;

  /// The bin new lines are picked from.
  final OrderLocation? pickFrom;
  final String destination;
  final DateTime? deliveryDate;
  final bool requiresApproval;
  final String notes;
  final List<OrderItem> items;
  final Map<String, String> errors;
  final bool isSubmitting;

  const CreateDeliveryOrderState({
    this.editingOrderId,
    this.editingOrderNumber,
    this.pickFrom,
    this.destination = '',
    this.deliveryDate,
    this.requiresApproval = false,
    this.notes = '',
    this.items = const [],
    this.errors = const {},
    this.isSubmitting = false,
  });

  CreateDeliveryOrderState copyWith({
    Object? pickFrom = _sentinel,
    String? destination,
    Object? deliveryDate = _sentinel,
    bool? requiresApproval,
    String? notes,
    List<OrderItem>? items,
    Map<String, String>? errors,
    bool? isSubmitting,
  }) {
    return CreateDeliveryOrderState(
      editingOrderId: editingOrderId,
      editingOrderNumber: editingOrderNumber,
      pickFrom: pickFrom == _sentinel ? this.pickFrom : pickFrom as OrderLocation?,
      destination: destination ?? this.destination,
      deliveryDate: deliveryDate == _sentinel ? this.deliveryDate : deliveryDate as DateTime?,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class CreateDeliveryOrderNotifier extends Notifier<CreateDeliveryOrderState> {
  @override
  CreateDeliveryOrderState build() => CreateDeliveryOrderState(deliveryDate: DateTime.now());

  void loadFromOrder(DeliveryOrder order) {
    final first = order.items.where((i) => i.locationId != null).firstOrNull;
    state = CreateDeliveryOrderState(
      editingOrderId: order.id,
      editingOrderNumber: order.orderNumber,
      pickFrom: first == null ? null : OrderLocation(id: first.locationId!, name: first.locationCode ?? '', type: 'Bin'),
      destination: order.destination,
      deliveryDate: order.deliveryDate,
      requiresApproval: order.requiresApproval,
      notes: order.notes ?? '',
      items: order.items,
    );
  }

  /// Every line is picked from [value] from now on.
  void setPickFrom(OrderLocation? value) {
    state = state.copyWith(
      pickFrom: value,
      items: value == null ? null : [for (final item in state.items) item.copyWith(locationId: value.id, locationCode: value.name)],
      errors: {...state.errors}..remove('pickFrom'),
    );
  }

  void setDestination(String value) {
    state = state.copyWith(destination: value, errors: {...state.errors}..remove('destination'));
  }

  void setDate(DateTime? value) {
    state = state.copyWith(deliveryDate: value, errors: {...state.errors}..remove('deliveryDate'));
  }

  void toggleApproval(bool value) => state = state.copyWith(requiresApproval: value);

  void setNotes(String value) => state = state.copyWith(notes: value);

  /// Lines without a bin are picked from Pick From.
  void setItems(List<OrderItem> items) {
    final bin = state.pickFrom;
    state = state.copyWith(
      items: [
        for (final item in items)
          if (item.locationId == null && bin != null) item.copyWith(locationId: bin.id, locationCode: bin.name) else item,
      ],
      errors: {...state.errors}..remove('items'),
    );
  }

  bool validateStep1() {
    final errors = <String, String>{};
    if (state.pickFrom == null) errors['pickFrom'] = 'Choose the bin to pick from';
    final destination = state.destination.trim();
    if (destination.isEmpty) {
      errors['destination'] = 'Destination is required';
    } else if (destination.length > 200) {
      errors['destination'] = 'Destination must be at most 200 characters';
    }
    if (state.deliveryDate == null) errors['deliveryDate'] = 'Delivery date is required';
    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }

  bool validateStep2() {
    final errors = {...state.errors};
    if (state.items.isEmpty) {
      errors['items'] = 'Add at least one item';
    } else {
      errors.remove('items');
    }
    state = state.copyWith(errors: errors);
    return !errors.containsKey('items');
  }

  Future<DeliveryOrder> submit({required bool asDraft}) async {
    final repository = ref.read(ordersRepositoryProvider);
    state = state.copyWith(isSubmitting: true);
    try {
      final status = asDraft ? OrderStatus.draft : (state.requiresApproval ? OrderStatus.pendingApproval : OrderStatus.submitted);
      final saved = await repository.saveDeliveryOrder(DeliveryOrder(
        id: state.editingOrderId ?? const Uuid().v4(),
        orderNumber: state.editingOrderNumber ?? '',
        destination: state.destination.trim(),
        deliveryDate: state.deliveryDate ?? DateTime.now(),
        status: status,
        requiresApproval: state.requiresApproval,
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        createdBy: '',
        createdAt: DateTime.now(),
        items: state.items,
      ));
      ref.invalidate(deliveryOrdersProvider(true));
      ref.invalidate(deliveryOrdersProvider(false));
      ref.invalidate(deliveryOrderDetailProvider(saved.id));
      return saved;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final createDeliveryOrderNotifierProvider = NotifierProvider<CreateDeliveryOrderNotifier, CreateDeliveryOrderState>(
  CreateDeliveryOrderNotifier.new,
);

const Object _sentinel = Object();
```

If `firstOrNull` does not resolve, add `import 'package:collection/collection.dart';` (the package is already a transitive dependency of Flutter). Otherwise replace it with a loop.

Rewrite `lib/features/sales_orders/providers/create_sales_order_notifier.dart` the same way. These are its differences from the delivery notifier:
- Fields:
  - `editingOrderId` and `editingOrderNumber` become `String?`.
  - Add `pickFrom`.
  - Keep `customerName` (String, default `''`) and `orderDate`.
  - Drop `destination` and `deliveryDate`.
- Methods:
  - Keep `setCustomerName(String)` and `setDate(DateTime?)`, which sets `orderDate` and removes the `'orderDate'` error.
  - Add `setPickFrom` and `setItems` exactly as in the delivery notifier.
  - `loadFromOrder(SalesOrder order)` sets `pickFrom` from the first line's bin, like the delivery one.
- `validateStep1`:
  - `'pickFrom'`: 'Choose the bin to pick from'.
  - `'customerName'`: 'Customer name is required' when the trimmed value is empty; 'Customer name must be at most 200 characters' when it is over 200.
  - `'orderDate'`: 'Order date is required'.
- `submit`:
  - Calls `repository.saveSalesOrder(SalesOrder(id: state.editingOrderId ?? const Uuid().v4(), orderNumber: state.editingOrderNumber ?? '', customerName: state.customerName.trim(), orderDate: state.orderDate ?? DateTime.now(), …))`.
  - Then invalidates `salesOrdersProvider(true)`, `salesOrdersProvider(false)` and `salesOrderDetailProvider(saved.id)`.
- Delete `addItem`, `removeItem` and `updateQty` from both notifiers if `grep -rn "addItem\|removeItem\|updateQty" lib/features` finds no caller. If there is a caller, keep the method and make new lines take `pickFrom` the same way `setItems` does.

- [ ] **Step 7: The item picker reads the repository**

In `lib/core/widgets/item_picker_sheet.dart`:
- Make `ItemPickerSheet` a `ConsumerStatefulWidget` (state: `ConsumerState<ItemPickerSheet>`).
- Import `package:flutter_riverpod/flutter_riverpod.dart` and `package:warehouse_app/data/repositories/orders_repository.dart`.
- Drop the `sample_order_catalog.dart` import.
- In `build`, replace the `filteredCatalog` computation and the catalog `Card` with:

```dart
    final catalog = ref.watch(orderCatalogSearchProvider(_search));
```

```dart
        catalog.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('Could not load items: $error'),
          data: (items) => Card(
            child: Column(
              children: [
                for (int index = 0; index < items.length; index++) ...[
                  _CatalogRow(item: items[index], onAdd: () => _addCatalogItem(items[index])),
                  if (index < items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
```

Replace `_handleScanSubmit` with:

```dart
  Future<void> _handleScanSubmit(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _scanController.clear();
    final item = await ref.read(ordersRepositoryProvider).findItem(trimmed);
    if (!mounted) return;
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item not found in catalog')));
      return;
    }
    _addCatalogItem(item);
  }
```

In `_SelectedItemRow`, show the bin next to the SKU: the caption `Text(item.itemSku, …)` becomes `Text(item.locationCode == null ? item.itemSku : '${item.itemSku} · ${item.locationCode}', …)`.

- [ ] **Step 8: The screens and routes**

`lib/core/router/app_router.dart`:
- `DeliveryOrderDetailScreen(id: state.extra as int)` becomes `DeliveryOrderDetailScreen(id: state.extra as String)`.
- Make the same change for `SalesOrderDetailScreen`.

`delivery_order_create_screen.dart`:
- Import `package:warehouse_app/data/repositories/orders_repository.dart`.
- `ref.watch(locationsProvider)` becomes `ref.watch(pickLocationsProvider)`.
- In `_BasicInfoStep`, replace the "From" and "To" blocks (label, gap, dropdown) with:

```dart
            const _RequiredLabel('Pick From'),
            const SizedBox(height: 6),
            DropdownButtonFormField<OrderLocation>(
              initialValue: data.contains(state.pickFrom) ? state.pickFrom : null,
              items: [for (final bin in data) DropdownMenuItem(value: bin, child: Text(bin.name))],
              onChanged: (value) => ref.read(createDeliveryOrderNotifierProvider.notifier).setPickFrom(value),
              decoration: InputDecoration(errorText: state.errors['pickFrom']),
            ),
            const SizedBox(height: 16),
            const _RequiredLabel('Destination'),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: state.destination,
              onChanged: (value) => ref.read(createDeliveryOrderNotifierProvider.notifier).setDestination(value),
              decoration: InputDecoration(hintText: 'Outlet, store or address', errorText: state.errors['destination']),
            ),
```

- In `_ReviewStep`, replace the `'From'` and `'To'` rows with `_ReviewRow('Pick From', state.pickFrom?.name ?? '-'),` and `_ReviewRow('Destination', state.destination.trim().isEmpty ? '-' : state.destination.trim()),`.

`delivery_order_detail_screen.dart`:
- `final int id;` becomes `final String id;`.
- The `'Route'` row becomes `('Destination', order.destination),`.
- In `_ItemsCard`, the `Text(items[index].itemSku, …)` becomes `Text(items[index].locationCode == null ? items[index].itemSku : '${items[index].itemSku} · ${items[index].locationCode}', …)`.
- `_updateStatus` calls `ref.read(ordersRepositoryProvider).updateOrderStatus(kind: OrderKind.delivery, id: order.id, status: status)`.

`widgets/delivery_order_card.dart`: `'${order.fromLocation.name} → ${order.toLocation.name}'` becomes `order.destination`.

`sales_order_create_screen.dart`:
- Import `orders_repository.dart`.
- In `_BasicInfoStep.build`, add `final bins = ref.watch(pickLocationsProvider);`. Above `_RequiredLabel('Customer Name')`, insert:

```dart
        const _RequiredLabel('Pick From'),
        const SizedBox(height: 6),
        bins.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('Failed to load bins: $error'),
          data: (data) => DropdownButtonFormField<OrderLocation>(
            initialValue: data.contains(state.pickFrom) ? state.pickFrom : null,
            items: [for (final bin in data) DropdownMenuItem(value: bin, child: Text(bin.name))],
            onChanged: (value) => ref.read(createSalesOrderNotifierProvider.notifier).setPickFrom(value),
            decoration: InputDecoration(errorText: state.errors['pickFrom']),
          ),
        ),
        const SizedBox(height: 16),
```

- In `_ReviewStep`, add `_ReviewRow('Pick From', state.pickFrom?.name ?? '-'),` after the `'Customer'` row.

`sales_order_detail_screen.dart`:
- `final int id;` becomes `final String id;`.
- Apply the same `_ItemsCard` SKU-and-bin text change.
- `_updateStatus` calls `updateOrderStatus(kind: OrderKind.sales, id: order.id, status: status)`.

Run `$F analyze`. Expected: `No issues found!`. Fix any remaining `int` id, `fromLocation`/`toLocation`, `locationsProvider`, `createDeliveryOrder`/`createSalesOrder` or `changedBy:` references the analyzer names, by applying the same mapping.

- [ ] **Step 9: Run the tests to watch them pass**

Run: `$F test test/features/orders -r failures-only`
Expected: `All tests passed!` (7 tests).

- [ ] **Step 10: Full suite and commit**

Run: `$F test -r failures-only`
Expected: 145 pass / 2 skipped / only the 2 `welcome_screen_test` failures.

```bash
git add -A lib test
git commit -m "feat(orders): orders take the server's shape: GUID ids, destination, a pick bin per line

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: App — orders in the phone's copy

**Files:**
- Modify: `lib/data/local/tables/server_tables.dart`
- Modify: `lib/data/local/app_database.dart`
- Modify: `lib/data/local/daos/server_mirror_dao.dart`
- Modify: `lib/data/sync/change_feed_puller.dart`
- Test: `test/data/sync/change_feed_puller_test.dart`, `test/data/local/app_database_migration_test.dart`

**Interfaces:**
- Consumes: the `deliveryOrder` / `salesOrder` feed entries from Task 1 (`OrderDto` JSON).
- Produces:
  - Drift tables `RemoteOrders` (row `RemoteOrderRow`) and `RemoteOrderLines` (row `RemoteOrderLineRow`).
  - `kMirrorVersion = 3`; schema 8.
  - `ServerMirrorDao` methods:
    - `upsertOrder(RemoteOrdersCompanion, List<RemoteOrderLinesCompanion>)`
    - `deleteOrder(String id)`
    - `orders(String warehouseId, {required String kind})` → `List<RemoteOrderRow>`, newest first
    - `orderLinesFor(String orderId)` → `List<RemoteOrderLineRow>`
  - `RemoteOrderRow.statusHistory` is a JSON array of `{status, changedByName, changedAt}`, oldest first.

- [ ] **Step 1: Write the failing tests**

In `test/data/sync/change_feed_puller_test.dart`, add a helper above `void main()` and two tests inside it. `w`, `item`, `bin`, `page`, `change` and `pullerServing` already exist in the file; add `import 'dart:convert';` if it is missing.

```dart
Map<String, dynamic> orderJson(String id, String kind, {String? destination, String? customerName}) => {
      'id': id, 'warehouseId': w, 'kind': kind, 'number': '${kind == 'Delivery' ? 'DO' : 'SO'}-1',
      'destination': destination, 'customerName': customerName, 'date': '2026-10-13', 'status': 'Draft',
      'requiresApproval': false, 'notes': null, 'createdByUserId': 'u1', 'createdAt': '2026-10-12T01:00:00Z',
      'lines': [{'id': '$id-l1', 'itemId': item, 'locationId': bin, 'quantity': 4}],
      'statusHistory': [{'status': 'Draft', 'changedByUserId': 'u1', 'changedAt': '2026-10-12T01:00:00Z', 'changedByName': 'Arjun Nair'}],
      'createdByName': 'Arjun Nair',
    };
```

```dart
  test('delivery and sales orders arrive with their lines and who moved them', () async {
    final puller = await pullerServing([
      page([
        change('deliveryOrder', 'do-1', 1, orderJson('do-1', 'Delivery', destination: 'Outlet Damansara')),
        change('salesOrder', 'so-1', 2, orderJson('so-1', 'Sales', customerName: 'Kedai Maju Jaya')),
      ], next: 2),
    ]);

    await puller.pull(w);

    final delivery = (await db.serverMirrorDao.orders(w, kind: 'Delivery')).single;
    expect((delivery.number, delivery.destination, delivery.createdByName), ('DO-1', 'Outlet Damansara', 'Arjun Nair'));
    expect(jsonDecode(delivery.statusHistory), [
      {'status': 'Draft', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T01:00:00Z'},
    ]);
    expect((await db.serverMirrorDao.orderLinesFor('do-1')).single.quantity, 4);
    expect((await db.serverMirrorDao.orders(w, kind: 'Sales')).single.customerName, 'Kedai Maju Jaya');
  });

  test('a deleted order leaves the copy, and signing out clears orders too', () async {
    final puller = await pullerServing([
      page([change('deliveryOrder', 'do-1', 1, orderJson('do-1', 'Delivery', destination: 'Outlet'))], next: 1),
      page([change('deliveryOrder', 'do-2', 2, orderJson('do-2', 'Delivery', destination: 'Outlet')), change('deliveryOrder', 'do-1', 3)], next: 3),
    ]);
    await puller.pull(w);
    await puller.pull(w);
    expect((await db.serverMirrorDao.orders(w, kind: 'Delivery')).map((o) => o.id), ['do-2']);
    expect(await db.serverMirrorDao.orderLinesFor('do-1'), isEmpty);

    await db.clearServerData();

    expect(await db.serverMirrorDao.orders(w, kind: 'Delivery'), isEmpty);
    expect(await db.serverMirrorDao.orderLinesFor('do-2'), isEmpty);
  });
```

`change(entity, id, seq)` without data is a deletion, as in the existing "deleted rows leave the copy" test.

In `test/data/local/app_database_migration_test.dart`, add `'remote_orders', 'remote_order_lines'` to the `DROP TABLE` list in `schema5Database()`, and add:

```dart
  test('a phone on schema 7 gains the order tables and pulls from the start', () async {
    final file = File('${dir.path}/app7.db');
    final old = AppDatabase.forTesting(NativeDatabase(file));
    await old.serverMirrorDao.saveCursor('w1', 40);
    await old.customStatement('DROP TABLE remote_orders');
    await old.customStatement('DROP TABLE remote_order_lines');
    await old.customStatement('UPDATE sync_cursors SET mirror_version = 2');
    await old.customStatement('PRAGMA user_version = 7');
    await old.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    expect(await db.serverMirrorDao.orders('w1', kind: 'Delivery'), isEmpty);
    expect(await db.serverMirrorDao.cursorFor('w1'), 0); // the 3b copy never kept orders: read the feed again
  });
```

- [ ] **Step 2: Run them to watch them fail**

Run: `$F test test/data/sync/change_feed_puller_test.dart test/data/local -r failures-only`
Expected: compilation FAILS: `orders`, `orderLinesFor`, `statusHistory` are not defined.

- [ ] **Step 3: Tables, schema 8, mirror version 3**

In `server_tables.dart`, set `const kMirrorVersion = 3;` and append:

```dart
/// Delivery and sales orders as the server has them. Kind is Delivery or Sales.
@DataClassName('RemoteOrderRow')
class RemoteOrders extends Table {
  TextColumn get id => text()();
  TextColumn get warehouseId => text()();
  TextColumn get kind => text()();
  TextColumn get number => text()();
  TextColumn get destination => text().nullable()();
  TextColumn get customerName => text().nullable()();
  DateTimeColumn get orderDate => dateTime()();
  TextColumn get status => text()(); // Draft · PendingApproval · Submitted · Packed · InTransit · Shipped
  BoolColumn get requiresApproval => boolean()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdByName => text()();
  DateTimeColumn get createdAt => dateTime()();

  /// JSON: [{status, changedByName, changedAt}], oldest first.
  TextColumn get statusHistory => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RemoteOrderLineRow')
class RemoteOrderLines extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get itemId => text()();
  TextColumn get locationId => text()();
  RealColumn get quantity => real()();

  @override
  Set<Column> get primaryKey => {id};
}
```

In `app_database.dart`:
- Add `RemoteOrders, RemoteOrderLines` to the `@DriftDatabase(tables: …)` list.
- Set `schemaVersion => 8`.
- After the `if (from < 7) { … }` block in `onUpgrade`, add:

```dart
          if (from < 8) {
            // kMirrorVersion 3 makes the next pull start from 0 and bring the orders a 3b phone skipped.
            await migrator.createTable(remoteOrders);
            await migrator.createTable(remoteOrderLines);
          }
```

- Add `remoteOrderLines, remoteOrders` to the table list in `clearServerData()`.

- [ ] **Step 4: DAO**

In `server_mirror_dao.dart`, add `RemoteOrders, RemoteOrderLines` to `@DriftAccessor(tables: […])` and append:

```dart
  Future<void> upsertOrder(RemoteOrdersCompanion order, List<RemoteOrderLinesCompanion> lines) async {
    await into(remoteOrders).insertOnConflictUpdate(order);
    await (delete(remoteOrderLines)..where((l) => l.orderId.equals(order.id.value))).go();
    for (final line in lines) {
      await into(remoteOrderLines).insertOnConflictUpdate(line);
    }
  }

  Future<void> deleteOrder(String id) async {
    await (delete(remoteOrderLines)..where((l) => l.orderId.equals(id))).go();
    await (delete(remoteOrders)..where((o) => o.id.equals(id))).go();
  }

  /// [kind] is Delivery or Sales. Newest first.
  Future<List<RemoteOrderRow>> orders(String warehouseId, {required String kind}) => (select(remoteOrders)
        ..where((o) => o.warehouseId.equals(warehouseId) & o.kind.equals(kind))
        ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
      .get();

  Future<List<RemoteOrderLineRow>> orderLinesFor(String orderId) =>
      (select(remoteOrderLines)..where((l) => l.orderId.equals(orderId))).get();
```

- [ ] **Step 5: Puller**

In `change_feed_puller.dart`, add `import 'dart:convert';` if it is missing. Replace the `default:` comment block with the order cases, followed by the default:

```dart
      case 'deliveryOrder':
      case 'salesOrder':
        if (data == null) return dao.deleteOrder(id);
        return dao.upsertOrder(
          RemoteOrdersCompanion.insert(
            id: id,
            warehouseId: data['warehouseId'] as String,
            kind: data['kind'] as String,
            number: data['number'] as String,
            destination: Value(data['destination'] as String?),
            customerName: Value(data['customerName'] as String?),
            orderDate: DateTime.parse(data['date'] as String),
            status: data['status'] as String,
            requiresApproval: data['requiresApproval'] as bool,
            notes: Value(data['notes'] as String?),
            createdByName: data['createdByName'] as String,
            createdAt: DateTime.parse(data['createdAt'] as String),
            statusHistory: jsonEncode([
              for (final h in (data['statusHistory'] as List).cast<Map<String, dynamic>>())
                {'status': h['status'], 'changedByName': h['changedByName'], 'changedAt': h['changedAt']},
            ]),
          ),
          [
            for (final line in (data['lines'] as List).cast<Map<String, dynamic>>())
              RemoteOrderLinesCompanion.insert(
                id: line['id'] as String,
                orderId: id,
                itemId: line['itemId'] as String,
                locationId: line['locationId'] as String,
                quantity: (line['quantity'] as num).toDouble(),
              ),
          ],
        );
      default:
        // Tasks and alerts come in 3d, bumping kMirrorVersion so they are pulled from the start.
        return;
```

- [ ] **Step 6: Generate and run**

```bash
$DART run build_runner build --delete-conflicting-outputs
$F test test/data -r failures-only
```

Expected: build_runner writes outputs; tests `All tests passed!` (the earlier schema-5 test also passes with the new tables).

- [ ] **Step 7: Commit**

```bash
git add -A lib test
git commit -m "feat(sync): delivery and sales orders in the phone's copy (schema 8, mirror version 3)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: App — order commands

**Files:**
- Modify: `lib/data/api/api_client.dart`
- Modify: `lib/data/sync/command_sender.dart`
- Modify: `lib/data/sync/sync_service.dart`
- Modify: `lib/data/local/daos/sync_queue_dao.dart`
- Modify: `lib/data/sync/sync_provider.dart`
- Test: `test/data/sync/sync_service_test.dart`

**Interfaces:**
- Consumes: the order endpoints from spec §3. `PUT /warehouses/{w}/{delivery|sales}-orders/{id}` takes `UpsertDeliveryOrderRequest` / `UpsertSalesOrderRequest`. `POST …/{id}/status` takes `{status, changedAt}` (Task 1).
- Produces:
  - `SyncOps.orderSave = 'order.save'`, with payload `{kind: 'Delivery'|'Sales', body: {…the upsert request…}}`.
  - `SyncOps.orderStatus = 'order.status'`, with payload `{kind, status: <server name>, changedAt: <ISO UTC>}`.
  - `ApiClient.put(path, {body, idempotencyKey, headers})`.
  - `SyncQueueDao.previousCommand(op, referenceId, {required int before})`.

- [ ] **Step 1: Write the failing tests**

In `test/data/sync/sync_service_test.dart`, inside `group('with the server', …)`, add:

```dart
    Future<void> queueOrder(String id, {String kind = 'Delivery', String status = 'Submitted'}) async {
      await db.syncQueueDao.enqueue(
        operationType: SyncOps.orderSave,
        referenceId: id,
        warehouseId: 'w1',
        payload: jsonEncode({
          'kind': kind,
          'body': {'number': 'DO-1', 'destination': 'Outlet', 'deliveryDate': '2026-10-13', 'requiresApproval': false, 'notes': null, 'lines': []},
        }),
      );
      await db.syncQueueDao.enqueue(
        operationType: SyncOps.orderStatus,
        referenceId: id,
        warehouseId: 'w1',
        payload: jsonEncode({'kind': kind, 'status': status, 'changedAt': '2026-10-12T02:00:00.000Z'}),
      );
    }

    test('an order is saved and then moved on, each at its own endpoint', () async {
      await queueOrder('o1');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add('${r.method} ${r.url.path}');
        if (r.method == 'PUT') expect((jsonDecode(r.body) as Map)['destination'], 'Outlet');
        if (r.method == 'POST') expect(jsonDecode(r.body), {'status': 'Submitted', 'changedAt': '2026-10-12T02:00:00.000Z'});
        return jsonResponse({'id': 'o1'});
      });

      expect(await service.flushQueue(), FlushOutcome.done);

      expect(calls, ['PUT /api/warehouses/w1/delivery-orders/o1', 'POST /api/warehouses/w1/delivery-orders/o1/status']);
    });

    test('a sales order goes to the sales endpoints', () async {
      await queueOrder('o2', kind: 'Sales');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add('${r.method} ${r.url.path}');
        return jsonResponse({'id': 'o2'});
      });

      await service.flushQueue();

      expect(calls, ['PUT /api/warehouses/w1/sales-orders/o2', 'POST /api/warehouses/w1/sales-orders/o2/status']);
    });

    test('a status change for an order the server refused says why', () async {
      await queueOrder('o1');
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add(r.method);
        return jsonResponse({'status': 422, 'title': 'One or more validation errors occurred.'}, 422);
      });

      await service.flushQueue();

      expect(calls, ['PUT']);
      final issues = await db.syncQueueDao.watchIssues().first;
      expect(issues.map((i) => i.operationType), [SyncOps.orderStatus, SyncOps.orderSave]);
      expect(ApiException.fromJson(jsonDecode(issues.first.lastError!) as Map<String, dynamic>).message, contains('the order was not saved'));
    });

    test('a status change goes once a later save of its order went through', () async {
      await queueOrder('o1');
      final firstSave = (await db.syncQueueDao.getPendingItems()).first;
      await db.syncQueueDao.markFailed(firstSave.id, const ApiException(status: 422, title: 'Bad number'));
      await queueOrder('o1'); // the person fixed the order: a second save, then the status change again
      final calls = <String>[];
      final service = await serviceAnswering((r) async {
        calls.add(r.method);
        return jsonResponse({'id': 'o1'});
      });

      await service.flushQueue();

      // The first status change looks at the save queued just before it (refused) and is held with a reason; the
      // second save and its status change go.
      expect(calls, ['PUT', 'POST']);
      final issues = await db.syncQueueDao.watchIssues().first;
      expect(issues.map((i) => i.operationType), [SyncOps.orderStatus, SyncOps.orderSave]);
    });
```

- [ ] **Step 2: Run them to watch them fail**

Run: `$F test test/data/sync/sync_service_test.dart -r failures-only`
Expected: compilation FAILS: `SyncOps.orderSave` / `SyncOps.orderStatus` are not defined.

- [ ] **Step 3: `put` on the client**

In `api_client.dart`, after `post`:

```dart
  Future<dynamic> put(String path, {Object? body, String? idempotencyKey, Map<String, String>? headers}) =>
      _send(() => _json('PUT', path, body: body, idempotencyKey: idempotencyKey)..headers.addAll(headers ?? const {}));
```

- [ ] **Step 4: Sender**

In `command_sender.dart`:
- Add to `SyncOps`:

```dart
  static const orderSave = 'order.save';
  static const orderStatus = 'order.status';
```

- Update the class comment's "3b adds…" sentence to "3d adds tasks and alerts."
- Add these cases before `default:`:

```dart
      case SyncOps.orderSave:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.put(_orderPath(item, payload), body: payload['body'], idempotencyKey: key, headers: clock);
      case SyncOps.orderStatus:
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        await _client.post(
          '${_orderPath(item, payload)}/status',
          body: {'status': payload['status'], 'changedAt': payload['changedAt']},
          idempotencyKey: key,
          headers: clock,
        );
```

- Add this method to `CommandSender`:

```dart
  String _orderPath(SyncQueueData item, Map<String, dynamic> payload) =>
      '/warehouses/${item.warehouseId}/${payload['kind'] == 'Sales' ? 'sales' : 'delivery'}-orders/${item.referenceId}';
```

- [ ] **Step 5: Dependent commands wait on the right command**

In `sync_queue_dao.dart`, after `commandFor`:

```dart
  /// The newest [operationType] command for [referenceId] queued before command [before].
  Future<SyncQueueData?> previousCommand(String operationType, String referenceId, {required int before}) => (select(syncQueue)
        ..where((q) => q.operationType.equals(operationType) & q.referenceId.equals(referenceId) & q.id.isSmallerThanValue(before))
        ..orderBy([(q) => OrderingTerm.desc(q.id)])
        ..limit(1))
      .getSingleOrNull();
```

In `sync_service.dart`, add to `SyncService`:

```dart
  /// Commands that only make sense if an earlier command for the same record went through, and what to say if it didn't.
  static const _dependsOn = {
    SyncOps.receiptSignature: (SyncOps.receiptCreate, 'Signature not sent: its receipt was not accepted.'),
    SyncOps.orderStatus: (SyncOps.orderSave, 'Status not sent: the order was not saved.'),
  };
```

Replace the `if (item.operationType == SyncOps.receiptSignature) { … }` block with:

```dart
      final dependency = _dependsOn[item.operationType];
      if (dependency != null) {
        // Sending it would only fail with "not found"; say why instead.
        final parent = await dao.previousCommand(dependency.$1, item.referenceId, before: item.id);
        if (parent != null && (parent.status == 'conflicted' || parent.status == 'failed')) {
          await dao.markFailed(item.id, ApiException(status: 0, title: dependency.$2));
          continue;
        }
      }
```

If `commandFor` now has no callers (`grep -rn commandFor lib test`), delete it.

- [ ] **Step 6: Issue titles**

In `sync_provider.dart` `syncIssuesProvider`, add to the `switch`:

```dart
              SyncOps.orderSave => 'Order not saved',
              SyncOps.orderStatus => 'Status change not accepted',
```

- [ ] **Step 7: Run and commit**

Run: `$F test test/data -r failures-only`
Expected: `All tests passed!` (3b's signature tests still pass on `previousCommand`).

```bash
git add -A lib test
git commit -m "feat(sync): order save and status commands; a status waits on its order's save

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: App — `ApiOrdersRepository`

**Files:**
- Create: `lib/data/api/api_orders_repository.dart`
- Modify: `lib/main.dart`
- Test: `test/data/api/api_orders_repository_test.dart`

**Interfaces:**
- Consumes:
  - Task 2's `OrdersRepository`.
  - Task 3's DAO methods: `orders`, `orderLinesFor`, `itemById`, `locationById`, `locationsFor`, `searchItems`, `itemByBarcode`, `caughtUpThrough`.
  - Task 4's `SyncOps.orderSave` / `orderStatus` payloads.
  - 3b's `SyncQueueDao.notYetInCopy(op, {warehouseId, caughtUpThrough})`.
- Produces: `ApiOrdersRepository({required AppDatabase db, required UserSession? Function() session, required void Function() onQueued})`.

- [ ] **Step 1: Write the failing tests**

`test/data/api/api_orders_repository_test.dart`:

```dart
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_exception.dart';
import 'package:warehouse_app/data/api/api_orders_repository.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/sync/command_sender.dart';

const w = '22222222-2222-4222-8222-222222222222';
const beras = 'aaaaaaaa-0000-4000-8000-000000000001';
const newId = '9f3c0000-0000-4000-8000-000000000001';

UserSession member(UserRole role) => UserSession(
      userId: 'u1',
      name: role == UserRole.worker ? 'Arjun Nair' : 'Hafiz Rahman',
      email: 'u1@waretrack.local',
      site: 'Shah Alam DC',
      role: role,
      token: 't',
      warehouseId: w,
      warehouses: [WarehouseMembership(warehouseId: w, code: 'SA1', name: 'Shah Alam DC', role: role)],
    );

RemoteOrdersCompanion order(String id, String status, {List<Map<String, String>>? history}) => RemoteOrdersCompanion.insert(
      id: id,
      warehouseId: w,
      kind: 'Delivery',
      number: 'DO-SA1-001',
      destination: const Value('Outlet Damansara'),
      orderDate: DateTime(2026, 10, 14),
      status: status,
      requiresApproval: status == 'PendingApproval',
      createdByName: 'Arjun Nair',
      createdAt: DateTime.utc(2026, 10, 12, 1),
      statusHistory: jsonEncode(history ??
          [
            {'status': 'Draft', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T01:00:00Z'},
            {'status': status, 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T01:05:00Z'},
          ]),
    );

void main() {
  late AppDatabase db;
  late UserSession session;
  late ApiOrdersRepository repo;
  late int kicks;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    session = member(UserRole.worker);
    kicks = 0;
    repo = ApiOrdersRepository(db: db, session: () => session, onQueued: () => kicks++);
    final dao = db.serverMirrorDao;
    await dao.upsertItem(CatalogItemsCompanion.insert(id: beras, sku: 'WT-0001', name: 'Beras Wangi 10kg', uom: 'BAG', isActive: true));
    await dao.upsertBarcode(CatalogBarcodesCompanion.insert(id: 'bc1', itemId: beras, code: '9556001000011'));
    await dao.upsertLocation(WarehouseLocationsCompanion.insert(id: 'dock-1', warehouseId: w, code: 'DOCK-1', type: 'Dock'));
    await dao.upsertLocation(WarehouseLocationsCompanion.insert(id: 'bin-1', warehouseId: w, code: 'A-01-01', type: 'Bin'));
    await dao.upsertOrder(order('do-1', 'Submitted'), [
      RemoteOrderLinesCompanion.insert(id: 'l1', orderId: 'do-1', itemId: beras, locationId: 'bin-1', quantity: 4),
    ]);
  });
  tearDown(() => db.close());

  test('orders come from the copy with item names, bins and who moved them', () async {
    final o = (await repo.getDeliveryOrders(active: true)).single;

    expect((o.orderNumber, o.destination, o.createdBy, o.status), ('DO-SA1-001', 'Outlet Damansara', 'Arjun Nair', OrderStatus.submitted));
    final line = o.items.single;
    expect((line.itemName, line.itemSku, line.quantity, line.locationCode), ('Beras Wangi 10kg', 'WT-0001', 4, 'A-01-01'));
    expect(o.statusHistory.map((h) => h.status), [OrderStatus.draft, OrderStatus.submitted]);
  });

  test('a new delivery needing approval is queued as a save and then a request for approval, and shows at once', () async {
    await repo.saveDeliveryOrder(DeliveryOrder(
      id: newId,
      orderNumber: '',
      destination: 'Outlet Cheras',
      deliveryDate: DateTime(2026, 10, 14),
      status: OrderStatus.pendingApproval,
      requiresApproval: true,
      createdBy: '',
      createdAt: DateTime.now(),
      items: const [OrderItem(itemId: beras, itemName: 'Beras Wangi 10kg', itemSku: 'WT-0001', quantity: 2, locationId: 'bin-1', locationCode: 'A-01-01')],
    ));

    final queued = await db.syncQueueDao.getPendingItems();
    expect(queued.map((q) => q.operationType), [SyncOps.orderSave, SyncOps.orderStatus]);
    final save = jsonDecode(queued[0].payload) as Map<String, dynamic>;
    final body = save['body'] as Map<String, dynamic>;
    expect(save['kind'], 'Delivery');
    expect(body['number'], matches(RegExp(r'^DO-\d{6}-9F3C$')));
    expect(body..remove('number'), {
      'destination': 'Outlet Cheras',
      'deliveryDate': '2026-10-14',
      'requiresApproval': true,
      'notes': null,
      'lines': [{'itemId': beras, 'locationId': 'bin-1', 'quantity': 2}],
    });
    expect((jsonDecode(queued[1].payload) as Map)['status'], 'PendingApproval');
    final shown = (await repo.getDeliveryOrderById(newId))!;
    expect((shown.status, shown.createdBy, shown.destination), (OrderStatus.pendingApproval, 'Arjun Nair', 'Outlet Cheras'));
    expect(kicks, 1);
  });

  test('two status changes made offline go in order, and the history is not doubled once the server has them', () async {
    await repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-1', status: OrderStatus.packed);
    await repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-1', status: OrderStatus.inTransit);

    var o = (await repo.getDeliveryOrderById('do-1'))!;
    expect(o.status, OrderStatus.inTransit);
    expect(o.statusHistory.map((h) => h.status), [OrderStatus.draft, OrderStatus.submitted, OrderStatus.packed, OrderStatus.inTransit]);

    final sent = await db.syncQueueDao.getPendingItems();
    for (final command in sent) {
      await db.syncQueueDao.markSynced(command.id);
    }
    await db.serverMirrorDao.upsertOrder(order('do-1', 'InTransit', history: [
      {'status': 'Draft', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T01:00:00Z'},
      {'status': 'Submitted', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T01:05:00Z'},
      {'status': 'Packed', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T02:00:00Z'},
      {'status': 'InTransit', 'changedByName': 'Arjun Nair', 'changedAt': '2026-10-12T02:10:00Z'},
    ]), [RemoteOrderLinesCompanion.insert(id: 'l1', orderId: 'do-1', itemId: beras, locationId: 'bin-1', quantity: 4)]);
    await db.serverMirrorDao.saveCursor(w, 9);
    await db.serverMirrorDao.markCaughtUp(w, through: sent.last.id);

    o = (await repo.getDeliveryOrderById('do-1'))!;
    expect(o.statusHistory, hasLength(4));
  });

  test('a dispatch the server refused leaves the order as the server has it', () async {
    await db.serverMirrorDao.upsertOrder(order('do-3', 'Packed'), [
      RemoteOrderLinesCompanion.insert(id: 'l3', orderId: 'do-3', itemId: beras, locationId: 'bin-1', quantity: 400),
    ]);
    await repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-3', status: OrderStatus.inTransit);
    expect((await repo.getDeliveryOrderById('do-3'))!.status, OrderStatus.inTransit);
    final command = (await db.syncQueueDao.getPendingItems()).single;

    await db.syncQueueDao.markConflicted(command.id, const ApiException(status: 409, title: 'Not enough stock to dispatch'));

    expect((await repo.getDeliveryOrderById('do-3'))!.status, OrderStatus.packed);
  });

  test('only a supervisor can approve', () async {
    await db.serverMirrorDao.upsertOrder(order('do-2', 'PendingApproval'), [
      RemoteOrderLinesCompanion.insert(id: 'l2', orderId: 'do-2', itemId: beras, locationId: 'bin-1', quantity: 1),
    ]);

    await expectLater(
      repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-2', status: OrderStatus.submitted),
      throwsA(isA<StateError>()),
    );
    expect(await db.syncQueueDao.getPendingItems(), isEmpty);

    session = member(UserRole.supervisor);
    await repo.updateOrderStatus(kind: OrderKind.delivery, id: 'do-2', status: OrderStatus.submitted);
    expect((await repo.getDeliveryOrderById('do-2'))!.status, OrderStatus.submitted);
  });

  test('a line without a bin is not queued', () async {
    await expectLater(
      repo.saveDeliveryOrder(DeliveryOrder(
        id: newId,
        orderNumber: '',
        destination: 'Outlet',
        deliveryDate: DateTime(2026, 10, 14),
        status: OrderStatus.draft,
        requiresApproval: false,
        createdBy: '',
        createdAt: DateTime.now(),
        items: const [OrderItem(itemId: beras, itemName: 'Beras Wangi 10kg', itemSku: 'WT-0001')],
      )),
      throwsA(isA<StateError>()),
    );
    expect(await db.syncQueueDao.getPendingItems(), isEmpty);
  });

  test('items are found by barcode or SKU, and bins come before docks', () async {
    expect((await repo.findItem('9556001000011'))?.id, beras);
    expect((await repo.findItem('wt-0001'))?.id, beras);
    expect(await repo.findItem('NOPE'), isNull);
    expect((await repo.getPickLocations()).map((l) => l.name), ['A-01-01', 'DOCK-1']);
  });
}
```

- [ ] **Step 2: Run them to watch them fail**

Run: `$F test test/data/api/api_orders_repository_test.dart -r failures-only`
Expected: compilation FAILS: `api_orders_repository.dart` does not exist.

- [ ] **Step 3: Implement**

`lib/data/api/api_orders_repository.dart`:

```dart
import 'dart:convert';

import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';

/// Delivery and sales orders against the server. Orders come from the phone's copy, with this phone's saves and status
/// changes that the copy doesn't show yet laid on top, oldest first. Saves and status changes go through the outbox.
class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository({required AppDatabase db, required UserSession? Function() session, required void Function() onQueued})
      : _db = db,
        _session = session,
        _onQueued = onQueued;

  final AppDatabase _db;
  final UserSession? Function() _session;
  final void Function() _onQueued;

  @override
  Future<List<DeliveryOrder>> getDeliveryOrders({required bool active}) async => [
        for (final o in await _orders(OrderKind.delivery))
          if (o.status.isActive == active) _delivery(o),
      ];

  @override
  Future<List<SalesOrder>> getSalesOrders({required bool active}) async => [
        for (final o in await _orders(OrderKind.sales))
          if (o.status.isActive == active) _sales(o),
      ];

  @override
  Future<DeliveryOrder?> getDeliveryOrderById(String id) async {
    final o = _find(await _orders(OrderKind.delivery), id);
    return o == null ? null : _delivery(o);
  }

  @override
  Future<SalesOrder?> getSalesOrderById(String id) async {
    final o = _find(await _orders(OrderKind.sales), id);
    return o == null ? null : _sales(o);
  }

  @override
  Future<DeliveryOrder> saveDeliveryOrder(DeliveryOrder order) async {
    await _save(OrderKind.delivery, order.id, order.status, {
      'number': order.orderNumber.isEmpty ? _number('DO', order.id) : order.orderNumber,
      'destination': order.destination.trim(),
      'deliveryDate': _day(order.deliveryDate),
      'requiresApproval': order.requiresApproval,
      'notes': order.notes,
      'lines': _lines(order.items),
    });
    return (await getDeliveryOrderById(order.id))!;
  }

  @override
  Future<SalesOrder> saveSalesOrder(SalesOrder order) async {
    await _save(OrderKind.sales, order.id, order.status, {
      'number': order.orderNumber.isEmpty ? _number('SO', order.id) : order.orderNumber,
      'customerName': order.customerName.trim(),
      'orderDate': _day(order.orderDate),
      'requiresApproval': order.requiresApproval,
      'notes': order.notes,
      'lines': _lines(order.items),
    });
    return (await getSalesOrderById(order.id))!;
  }

  @override
  Future<void> updateOrderStatus({required OrderKind kind, required String id, required OrderStatus status}) async {
    final session = _session();
    final warehouseId = session?.warehouseId;
    if (session == null || warehouseId == null) throw StateError('No warehouse chosen.');
    final current = _find(await _orders(kind), id);
    if (current == null) throw StateError('This order is no longer on the phone.');
    if (current.status == OrderStatus.pendingApproval && status == OrderStatus.submitted && session.role != UserRole.supervisor) {
      throw StateError('Only a supervisor can approve this order.');
    }
    await _queueStatus(kind, id, warehouseId, status);
    _onQueued();
  }

  @override
  Future<List<OrderLocation>> getPickLocations() async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) return const [];
    final locations = [
      for (final l in await _db.serverMirrorDao.locationsFor(warehouseId)) OrderLocation(id: l.id, name: l.code, type: l.type),
    ];
    locations.sort((a, b) => (a.type == 'Bin' ? 0 : 1).compareTo(b.type == 'Bin' ? 0 : 1)); // stable: codes stay in order
    return locations;
  }

  @override
  Future<List<CatalogItem>> searchItems(String term) async => [
        for (final i in await _db.serverMirrorDao.searchItems(term)) CatalogItem(id: i.id, name: i.name, sku: i.sku),
      ];

  @override
  Future<CatalogItem?> findItem(String code) async {
    final dao = _db.serverMirrorDao;
    final trimmed = code.trim();
    var row = await dao.itemByBarcode(trimmed);
    if (row == null) {
      for (final candidate in await dao.searchItems(trimmed)) {
        if (candidate.sku.toLowerCase() == trimmed.toLowerCase()) row = candidate;
      }
    }
    return row == null ? null : CatalogItem(id: row.id, name: row.name, sku: row.sku);
  }

  Future<void> _save(OrderKind kind, String id, OrderStatus target, Map<String, Object?> body) async {
    final warehouseId = _session()?.warehouseId;
    if (warehouseId == null) throw StateError('No warehouse chosen.');
    final current = _find(await _orders(kind), id);
    if (current != null && current.status != OrderStatus.draft) throw StateError('Only a draft order can be changed.');
    await _db.syncQueueDao.enqueue(
      operationType: SyncOps.orderSave,
      referenceId: id,
      warehouseId: warehouseId,
      payload: jsonEncode({'kind': kind.serverName, 'body': body}),
    );
    if (target != OrderStatus.draft) await _queueStatus(kind, id, warehouseId, target);
    _onQueued();
  }

  Future<void> _queueStatus(OrderKind kind, String id, String warehouseId, OrderStatus status) => _db.syncQueueDao.enqueue(
        operationType: SyncOps.orderStatus,
        referenceId: id,
        warehouseId: warehouseId,
        payload: jsonEncode({'kind': kind.serverName, 'status': status.serverName, 'changedAt': DateTime.now().toUtc().toIso8601String()}),
      );

  List<Map<String, Object?>> _lines(List<OrderItem> items) {
    final lines = <Map<String, Object?>>[];
    for (final item in items) {
      if (item.locationId == null) throw StateError('${item.itemName}: choose the bin to pick it from.');
      if (item.quantity <= 0) throw StateError('${item.itemName}: the quantity must be more than 0.');
      lines.add({'itemId': item.itemId, 'locationId': item.locationId, 'quantity': item.quantity});
    }
    if (lines.isEmpty) throw StateError('Add at least one item.');
    return lines;
  }

  /// The server's copy, with this phone's changes it doesn't show yet laid on top in the order they were made.
  Future<List<_Order>> _orders(OrderKind kind) async {
    final session = _session();
    final warehouseId = session?.warehouseId;
    if (session == null || warehouseId == null) return const [];
    final dao = _db.serverMirrorDao;
    final byId = <String, _Order>{};
    for (final row in await dao.orders(warehouseId, kind: kind.serverName)) {
      byId[row.id] = _Order(
        id: row.id,
        number: row.number,
        destination: row.destination,
        customerName: row.customerName,
        date: row.orderDate,
        status: OrderStatus.fromServer(row.status),
        requiresApproval: row.requiresApproval,
        notes: row.notes,
        createdBy: row.createdByName,
        createdAt: row.createdAt,
        items: [for (final l in await dao.orderLinesFor(row.id)) await _item(l.itemId, l.locationId, l.quantity.round())],
        history: [
          for (final h in (jsonDecode(row.statusHistory) as List).cast<Map<String, dynamic>>())
            OrderStatusHistory(
              id: '${row.id}-${h['changedAt']}',
              status: OrderStatus.fromServer(h['status'] as String),
              changedBy: h['changedByName'] as String,
              changedAt: DateTime.parse(h['changedAt'] as String).toLocal(),
            ),
        ],
      );
    }

    final queue = _db.syncQueueDao;
    final caughtUp = await dao.caughtUpThrough(warehouseId);
    final waiting = [
      ...await queue.notYetInCopy(SyncOps.orderSave, warehouseId: warehouseId, caughtUpThrough: caughtUp),
      ...await queue.notYetInCopy(SyncOps.orderStatus, warehouseId: warehouseId, caughtUpThrough: caughtUp),
    ]..sort((a, b) => a.id.compareTo(b.id));
    for (final command in waiting) {
      final payload = jsonDecode(command.payload) as Map<String, dynamic>;
      if (payload['kind'] != kind.serverName) continue;
      if (command.operationType == SyncOps.orderSave) {
        final body = payload['body'] as Map<String, dynamic>;
        final items = [
          for (final l in (body['lines'] as List).cast<Map<String, dynamic>>())
            await _item(l['itemId'] as String, l['locationId'] as String, (l['quantity'] as num).round()),
        ];
        final existing = byId[command.referenceId];
        final saved = _Order(
          id: command.referenceId,
          number: body['number'] as String,
          destination: body['destination'] as String?,
          customerName: body['customerName'] as String?,
          date: DateTime.parse((body['deliveryDate'] ?? body['orderDate']) as String),
          status: existing?.status ?? OrderStatus.draft,
          requiresApproval: body['requiresApproval'] as bool,
          notes: body['notes'] as String?,
          createdBy: existing?.createdBy ?? session.name,
          createdAt: existing?.createdAt ?? command.queuedAt,
          items: items,
          history: existing?.history ??
              [OrderStatusHistory(id: 'q${command.id}', status: OrderStatus.draft, changedBy: session.name, changedAt: command.queuedAt)],
        );
        byId[command.referenceId] = saved;
      } else {
        final o = byId[command.referenceId];
        final status = OrderStatus.fromServer(payload['status'] as String);
        if (o == null || o.status == status) continue; // already in the copy
        o.status = status;
        o.history.add(OrderStatusHistory(
          id: 'q${command.id}',
          status: status,
          changedBy: session.name,
          changedAt: DateTime.parse(payload['changedAt'] as String).toLocal(),
        ));
      }
    }
    return byId.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<OrderItem> _item(String itemId, String locationId, int quantity) async {
    final dao = _db.serverMirrorDao;
    final item = await dao.itemById(itemId);
    final bin = await dao.locationById(locationId);
    return OrderItem(
      itemId: itemId,
      itemName: item?.name ?? 'Item no longer in the catalogue',
      itemSku: item?.sku ?? 'Unknown item',
      quantity: quantity,
      locationId: locationId,
      locationCode: bin?.code ?? 'Unknown bin',
    );
  }

  static _Order? _find(List<_Order> orders, String id) {
    for (final o in orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _day(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  /// DO-yyMMdd-XXXX: the date and the start of the order's own id, so two phones don't pick the same number.
  static String _number(String prefix, String id) {
    final d = DateTime.now();
    return '$prefix-${_two(d.year % 100)}${_two(d.month)}${_two(d.day)}-${id.substring(0, 4).toUpperCase()}';
  }

  static DeliveryOrder _delivery(_Order o) => DeliveryOrder(
        id: o.id,
        orderNumber: o.number,
        destination: o.destination ?? '',
        deliveryDate: o.date,
        status: o.status,
        requiresApproval: o.requiresApproval,
        notes: o.notes,
        createdBy: o.createdBy,
        createdAt: o.createdAt,
        items: o.items,
        statusHistory: List.unmodifiable(o.history),
      );

  static SalesOrder _sales(_Order o) => SalesOrder(
        id: o.id,
        orderNumber: o.number,
        customerName: o.customerName ?? '',
        orderDate: o.date,
        status: o.status,
        requiresApproval: o.requiresApproval,
        notes: o.notes,
        createdBy: o.createdBy,
        createdAt: o.createdAt,
        items: o.items,
        statusHistory: List.unmodifiable(o.history),
      );
}

/// One order while the copy and the waiting commands are combined.
class _Order {
  _Order({
    required this.id,
    required this.number,
    required this.destination,
    required this.customerName,
    required this.date,
    required this.status,
    required this.requiresApproval,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.items,
    required this.history,
  });

  final String id;
  final String number;
  final String? destination;
  final String? customerName;
  final DateTime date;
  OrderStatus status;
  final bool requiresApproval;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<OrderStatusHistory> history;
}
```

If `hide UserSession` is not enough (the analyzer reports an ambiguous name), add that name to the `hide` list.

- [ ] **Step 4: Wire it in**

In `lib/main.dart`, add `import 'package:warehouse_app/data/api/api_orders_repository.dart';` and replace the `ordersRepositoryProvider` override with:

```dart
        ordersRepositoryProvider.overrideWith(
          (ref) => client == null
              ? SampleOrdersRepository()
              : ApiOrdersRepository(
                  db: database,
                  session: () => ref.read(authNotifierProvider).valueOrNull,
                  onQueued: () => unawaited(ref.read(syncCoordinatorProvider).syncNow()),
                ),
        ),
```

- [ ] **Step 5: Run and commit**

Run: `$F test test/data -r failures-only && $F analyze`
Expected: `All tests passed!`; `No issues found!`

```bash
git add -A lib test
git commit -m "feat(orders): orders against the server, with this phone's waiting changes shown at once

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: App — order screens in server mode

**Files:**
- Modify: `lib/features/delivery_orders/providers/delivery_orders_provider.dart`, `lib/features/sales_orders/providers/sales_orders_provider.dart`
- Modify: `lib/features/delivery_orders/presentation/delivery_orders_list_screen.dart`, `lib/features/sales_orders/presentation/sales_orders_list_screen.dart`
- Modify: `lib/features/delivery_orders/presentation/delivery_order_detail_screen.dart`, `lib/features/sales_orders/presentation/sales_order_detail_screen.dart`
- Test: `test/features/orders/order_screens_test.dart`

**Interfaces:**
- Consumes: `authNotifierProvider` (`UserSession.role`, `warehouseId`, `userId`), `syncCoordinatorProvider.syncNow()`, and `OrdersRepository.updateOrderStatus` (throws `StateError` with a reason).

- [ ] **Step 1: Write the failing tests**

`test/features/orders/order_screens_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/providers/auth_provider.dart';
import 'package:warehouse_app/data/repositories/auth_repository.dart';
import 'package:warehouse_app/data/repositories/orders_repository.dart';
import 'package:warehouse_app/data/sync/sync_coordinator.dart';
import 'package:warehouse_app/data/sync/sync_provider.dart';
import 'package:warehouse_app/features/delivery_orders/presentation/delivery_order_detail_screen.dart';
import 'package:warehouse_app/features/delivery_orders/presentation/delivery_orders_list_screen.dart';
import 'package:warehouse_app/features/delivery_orders/providers/delivery_orders_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOrdersRepository extends Mock implements OrdersRepository {}

class MockSyncCoordinator extends Mock implements SyncCoordinator {}

UserSession member(UserRole role, {String warehouseId = 'wa'}) => UserSession(
      userId: 'u1', name: 'Hafiz', email: 'h@w', site: 'A', role: role, token: 't', warehouseId: warehouseId);

void main() {
  late MockAuthRepository auth;

  setUp(() {
    auth = MockAuthRepository();
    registerFallbackValue(member(UserRole.worker));
    registerFallbackValue(OrderKind.delivery);
    registerFallbackValue(OrderStatus.draft);
  });

  Widget app(UserSession session, Widget home, {List<Override> overrides = const []}) => ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          authBootstrapStateProvider.overrideWithValue(AuthBootstrapState.hydrated(session)),
          ...overrides,
        ],
        child: MaterialApp(home: home),
      );

  testWidgets('a worker sees that an order waits for a supervisor, not the approve buttons', (tester) async {
    await tester.pumpWidget(app(member(UserRole.worker), const DeliveryOrderDetailScreen(id: 'do-2'),
        overrides: [ordersRepositoryProvider.overrideWithValue(SampleOrdersRepository())]));
    await tester.pumpAndSettle();

    expect(find.text('Approve'), findsNothing);
    expect(find.text('Waiting for a supervisor to approve'), findsOneWidget);
  });

  testWidgets('a supervisor can approve or reject', (tester) async {
    await tester.pumpWidget(app(member(UserRole.supervisor), const DeliveryOrderDetailScreen(id: 'do-2'),
        overrides: [ordersRepositoryProvider.overrideWithValue(SampleOrdersRepository())]));
    await tester.pumpAndSettle();

    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  testWidgets('a refused status change says why', (tester) async {
    final repo = MockOrdersRepository();
    final sample = SampleOrdersRepository();
    when(() => repo.getDeliveryOrderById('do-1')).thenAnswer((_) => sample.getDeliveryOrderById('do-1'));
    when(() => repo.updateOrderStatus(kind: any(named: 'kind'), id: any(named: 'id'), status: any(named: 'status')))
        .thenThrow(StateError('This order is no longer on the phone.'));
    await tester.pumpWidget(app(member(UserRole.worker), const DeliveryOrderDetailScreen(id: 'do-1'),
        overrides: [ordersRepositoryProvider.overrideWithValue(repo)]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as Packed'));
    await tester.pumpAndSettle();

    expect(find.text('This order is no longer on the phone.'), findsOneWidget);
  });

  test('the delivery list follows the chosen warehouse', () async {
    final repo = MockOrdersRepository();
    const a = UserSession(userId: 'u1', name: 'Hafiz', email: 'h@w', site: 'A', role: UserRole.worker, token: 't', warehouseId: 'wa');
    when(() => repo.getDeliveryOrders(active: true)).thenAnswer((_) async => const []);
    when(() => auth.selectWarehouse(any(), 'wb')).thenAnswer((_) async => a.copyWith(warehouseId: 'wb', site: 'B'));
    final container = ProviderContainer(overrides: [
      ordersRepositoryProvider.overrideWithValue(repo),
      authRepositoryProvider.overrideWithValue(auth),
      authBootstrapStateProvider.overrideWithValue(const AuthBootstrapState.hydrated(a)),
    ]);
    addTearDown(container.dispose);
    container.listen(deliveryOrdersProvider(true), (_, __) {});

    await container.read(deliveryOrdersProvider(true).future);
    await container.read(authNotifierProvider.notifier).selectWarehouse('wb');
    await container.read(deliveryOrdersProvider(true).future);

    verify(() => repo.getDeliveryOrders(active: true)).called(2);
  });

  testWidgets('pulling the delivery list down sends and fetches first', (tester) async {
    final repo = MockOrdersRepository();
    final sync = MockSyncCoordinator();
    when(() => repo.getDeliveryOrders(active: any(named: 'active'))).thenAnswer((_) async => const []);
    when(() => sync.syncNow()).thenAnswer((_) async {});
    await tester.pumpWidget(app(member(UserRole.worker), const DeliveryOrdersListScreen(), overrides: [
      ordersRepositoryProvider.overrideWithValue(repo),
      syncCoordinatorProvider.overrideWithValue(sync),
    ]));
    await tester.pumpAndSettle();

    await tester.fling(find.text('No delivery orders yet'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => sync.syncNow()).called(1);
  });
}
```

If `DeliveryOrdersListScreen` needs a GoRouter or the app scaffold's drawer to build, wrap `home` the way the existing `test/features/receiving/po_list_screen_test.dart` does, or pump only the `_OrdersTab` content through the public screen. Ledger a ruling if the harness differs.

- [ ] **Step 2: Run them to watch them fail**

Run: `$F test test/features/orders/order_screens_test.dart -r failures-only`
Expected: FAIL. "Waiting for a supervisor to approve" is not found; a worker still sees Approve; the StateError is not shown; the list provider is called once; `syncNow` is never called.

- [ ] **Step 3: Providers follow the warehouse**

In both order provider files, import `package:warehouse_app/core/providers/auth_provider.dart`. As the first line of each `FutureProvider` body (both list families and both detail families), add:

```dart
  // Another warehouse or another person: another list.
  ref.watch(authNotifierProvider.select((auth) => (auth.valueOrNull?.userId, auth.valueOrNull?.warehouseId)));
```

- [ ] **Step 4: Pull to refresh sends and fetches first**

In both list screens' `_OrdersTab`, replace `onRefresh: () => ref.refresh(deliveryOrdersProvider(active).future),` (sales: `salesOrdersProvider`) with:

```dart
      onRefresh: () async {
        await ref.read(syncCoordinatorProvider).syncNow();
        return ref.refresh(deliveryOrdersProvider(active).future);
      },
```

Import `package:warehouse_app/data/sync/sync_provider.dart`.

- [ ] **Step 5: Approval belongs to supervisors; refusals are shown**

In both detail screens' `_ActionBar.build`:
- Read the role: `final isSupervisor = ref.watch(authNotifierProvider.select((a) => a.valueOrNull?.role)) == UserRole.supervisor;` (import `auth_provider.dart` and `user_session.dart`).
- Replace the `pendingApproval` branch with:

```dart
    } else if (order.status == OrderStatus.pendingApproval) {
      child = !isSupervisor
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Waiting for a supervisor to approve', textAlign: TextAlign.center),
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(context, ref, OrderStatus.draft),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(context, ref, OrderStatus.submitted),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            );
```

- Pass `context` in the other `_updateStatus` call, and replace `_updateStatus` with (sales: `OrderKind.sales` and the sales providers):

```dart
  Future<void> _updateStatus(BuildContext context, WidgetRef ref, OrderStatus status) async {
    try {
      await ref.read(ordersRepositoryProvider).updateOrderStatus(kind: OrderKind.delivery, id: order.id, status: status);
    } on StateError catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    ref.invalidate(deliveryOrdersProvider(true));
    ref.invalidate(deliveryOrdersProvider(false));
    ref.invalidate(deliveryOrderDetailProvider(order.id));
  }
```

- [ ] **Step 6: Run and commit**

Run: `$F test test/features -r failures-only && $F analyze`
Expected: all pass except the 2 pre-existing `welcome_screen_test` failures; `No issues found!`

```bash
git add -A lib test
git commit -m "feat(orders): order screens follow the warehouse, refresh from the server, and keep approval to supervisors

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: App — live order test

**Files:**
- Create: `test/live/api_orders_live_test.dart`

**Interfaces:**
- Consumes:
  - the running API on the `order-names` branch (`WARETRACK_API=http://localhost:5050`);
  - the seed: `arjun@waretrack.local` (worker) and `hafiz@waretrack.local` (supervisor) of SA1. Item WT-0001 starts with 50 units in bin A-01-01; the seed puts item *i* in bin *i mod 20*, in code order.

- [ ] **Step 1: Write the live test**

```dart
@Tags(['live'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/order.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/data/api/api_auth_repository.dart';
import 'package:warehouse_app/data/api/api_client.dart';
import 'package:warehouse_app/data/api/api_orders_repository.dart';
import 'package:warehouse_app/data/api/key_value_store.dart';
import 'package:warehouse_app/data/api/token_store.dart';
import 'package:warehouse_app/data/local/app_database.dart' hide UserSession;
import 'package:warehouse_app/data/sync/change_feed_puller.dart';
import 'package:warehouse_app/data/sync/command_sender.dart';
import 'package:warehouse_app/data/sync/sync_service.dart';

final api = Platform.environment['WARETRACK_API'];
final password = Platform.environment['WARETRACK_SEED_PASSWORD'] ?? 'Waretrack#2026';

/// One person's phone: its own copy, outbox and orders.
class Phone {
  Phone._(this.db, this.session, this.puller, this.outbox, this.orders);

  final AppDatabase db;
  final UserSession session;
  final ChangeFeedPuller puller;
  final SyncService outbox;
  final ApiOrdersRepository orders;

  static Future<Phone> signIn(String login) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final client = ApiClient(baseUrl: api!, httpClient: http.Client(), tokens: TokenStore(MemoryKeyValueStore()));
    final auth = ApiAuthRepository(client: client, db: db);
    var session = await auth.login('$login@waretrack.local', password);
    if (session.warehouseId == null) {
      session = await auth.selectWarehouse(session, session.warehouses.firstWhere((w) => w.code == 'SA1').warehouseId);
    }
    final UserSession current = session;
    final phone = Phone._(db, current, ChangeFeedPuller(client: client, db: db), SyncService(db: db, sender: CommandSender(client)),
        ApiOrdersRepository(db: db, session: () => current, onQueued: () {}));
    await phone.sync();
    return phone;
  }

  Future<void> sync() async {
    expect(await outbox.flushQueue(), FlushOutcome.done);
    expect(await db.syncQueueDao.watchIssues().first, isEmpty, reason: 'every command was accepted');
    await puller.pull(session.warehouseId!);
  }
}

void main() {
  test('a worker raises a delivery, a supervisor approves it, and it is packed, dispatched and shipped', () async {
    final worker = await Phone.signIn('arjun');
    final lead = await Phone.signIn('hafiz');
    final item = (await worker.orders.findItem('WT-0001'))!;
    final bin = (await worker.orders.getPickLocations()).firstWhere((l) => l.name == 'A-01-01');
    final id = const Uuid().v4();

    await worker.orders.saveDeliveryOrder(DeliveryOrder(
      id: id,
      orderNumber: '',
      destination: 'Outlet Damansara',
      deliveryDate: DateTime.now(),
      status: OrderStatus.pendingApproval,
      requiresApproval: true,
      createdBy: '',
      createdAt: DateTime.now(),
      items: [OrderItem(itemId: item.id, itemName: item.name, itemSku: item.sku, quantity: 1, locationId: bin.id, locationCode: bin.name)],
    ));
    await worker.sync();

    await lead.sync();
    expect((await lead.orders.getDeliveryOrderById(id))!.status, OrderStatus.pendingApproval);
    await lead.orders.updateOrderStatus(kind: OrderKind.delivery, id: id, status: OrderStatus.submitted);
    await lead.sync();

    await worker.sync();
    for (final next in [OrderStatus.packed, OrderStatus.inTransit, OrderStatus.shipped]) {
      await worker.orders.updateOrderStatus(kind: OrderKind.delivery, id: id, status: next);
    }
    await worker.sync();

    final shipped = (await worker.orders.getDeliveryOrderById(id))!;
    expect(shipped.status, OrderStatus.shipped);
    expect(shipped.statusHistory.map((h) => h.status), [
      OrderStatus.draft, OrderStatus.pendingApproval, OrderStatus.submitted, OrderStatus.packed, OrderStatus.inTransit, OrderStatus.shipped,
    ]);
    expect(shipped.statusHistory.map((h) => h.changedBy).toSet(), {'Arjun Nair', 'Hafiz Rahman'});
  }, skip: api == null ? 'Set WARETRACK_API=http://localhost:5050 (with the server running) to run this.' : false);
}
```

- [ ] **Step 2: Run against the local API**

Start the dev database and the server on `order-names`:

```bash
docker start deploy-postgres-1
cd ~/projects/Personal/DotNet/waretrack-server && ASPNETCORE_ENVIRONMENT=Development dotnet run --project src/WareTrack.Api --urls http://localhost:5050
```

The server must be running in the background. Its log shows `Now listening on: "http://localhost:5050"`, and the `OrderNames` migration is applied at start-up. Then:

Run: `WARETRACK_API=http://localhost:5050 $F test test/live`
Expected: 3/3 PASS (receiving, counting, orders).

Do not run the live tests twice within a minute: the login rate limit trips. Afterwards stop the server and run `docker stop deploy-postgres-1` (do not restart Docker Desktop; it would stop the Lantern stack).

- [ ] **Step 3: Full suite and commit**

Run: `$F test -r failures-only`
Expected: everything passes except the 2 pre-existing `welcome_screen_test` failures; 3 live tests skipped.

```bash
git add test/live/api_orders_live_test.dart
git commit -m "test(live): a delivery from a worker's phone, approved by a supervisor's, through to shipped

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```
