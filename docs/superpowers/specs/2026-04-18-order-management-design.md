# Order Management — Design Spec

**Date**: 2026-04-18
**Features**: Delivery Order Creation, Sales Order Creation
**Status**: Approved

---

## Overview

Two independent order management features added to the warehouse app:

- **Delivery Orders (DO)** — stock transfers between predefined locations (warehouse → outlet, outlet → outlet)
- **Sales Orders (SO)** — sales to freeform customers

Both features are accessible to Worker and Supervisor roles. Each is a self-contained component with its own list, creation flow, and detail screen.

---

## Architecture & Navigation

### Structure

Two separate components — no shared hub screen. Each has its own navigation branch.

```
Dashboard
  ├── Delivery Orders card  →  /delivery-orders
  │     ├── DO List Screen
  │     │     └── FAB (+)  →  /delivery-orders/new  (3-step creation)
  │     └── DO Detail Screen  →  /delivery-orders/:id
  └── Sales Orders card  →  /sales-orders
        ├── SO List Screen
        │     └── FAB (+)  →  /sales-orders/new  (3-step creation)
        └── SO Detail Screen  →  /sales-orders/:id
```

### Dashboard Integration

Both quick action cards added to Worker and Supervisor dashboards:
- Worker: 2 → 4 cards (2×2 grid)
- Supervisor: 4 → 6 cards (2×3 grid)

Routes use `context.push` for all nested screens (preserves back stack).

---

## Status Flow

Both DO and SO share the same status lifecycle:

```
Draft → [Optional] Pending Approval → Submitted → Packed → In Transit → Shipped
```

- **Draft**: saved via "Save as Draft" on Step 3 — order exists but is not submitted; can be edited and submitted later
- **Pending Approval**: inserted only when creator toggles "Require Approval" on
- **Submitted → Shipped**: any role (Worker or Supervisor) can advance the status
- **Approve**: moves order from Pending Approval → Submitted
- **Reject**: moves order back to Draft — creator can edit and resubmit

---

## Screens

### List Screen

- AppBar: back arrow + title ("Delivery Orders" / "Sales Orders")
- Tabs: **Active** (Draft, Pending Approval, Submitted, Packed, In Transit) | **Completed** (Shipped only)
- Each card shows:
  - Order number (DO-YYYY-XXXX / SO-YYYY-XXXX) + date (top row)
  - Route `From → To` (DO) or customer name (SO)
  - Solid status bar at bottom: item count (left) + status label (right), white text
- Status bar colors:
  - Pending Approval: `#F57F17`
  - Submitted: `#1565C0`
  - Packed: `#E65100`
  - In Transit: `#FF8F00`
  - Shipped: `#2E7D32`
- FAB (+) bottom-right → opens creation flow
- Empty state: centered secondary text, no illustrations
- Pull-to-refresh supported

### Creation Flow (3 steps, shared structure for DO and SO)

**Step 1 — Basic Info**

*Delivery Order:*
- From (required) — dropdown from predefined location list
- To (required) — dropdown from predefined location list
- Delivery Date (required) — date picker, defaults to today
- Require Approval — toggle (off by default); subtitle: "Supervisor must approve before packing"
- Notes — optional freeform text area

*Sales Order:*
- Customer Name (required) — freeform text field
- Order Date (required) — date picker, defaults to today
- Require Approval — toggle (off by default)
- Notes — optional freeform text area

**Step 2 — Add Items**
- Shared between DO and SO (`ItemPickerSheet` widget)
- Barcode scan bar at top — scans into item list
- "or browse below" divider — manual search/browse from item list
- Each added item: name, SKU, quantity stepper (− / qty / +)
- "Add another item" dashed button at bottom
- Minimum 1 item required to proceed

**Step 3 — Review & Submit**
- Read-only summary of all Step 1 fields
- Items list with quantities
- Two actions:
  - "Save as Draft" — outline button (saves without submitting)
  - "Submit Order" — primary button (sets status to Submitted or Pending Approval)

**Step indicator**: 3 dots in AppBar area — done (✓ green), active (highlighted), inactive (grey)

**Validation**: inline on "Next" tap — required fields must be filled, min 1 item on Step 2.

### Detail Screen

- AppBar: back arrow + order number
- Status banner (full-width, status color): status label (left) + date (right), white text
- Order Info card: route or customer, date, created by, notes
- Items card: item name, SKU, quantity per row
- Status History timeline: vertical timeline, each step shows status + timestamp; completed steps in primary green, current step in status color, upcoming steps greyed out
- Action button at bottom (context-aware):

| Current Status | Action Button |
|---|---|
| Draft | Edit Order (primary green) |
| Pending Approval | Reject (red `#C62828`) + Approve (primary green) |
| Submitted | Mark as Packed (primary green) |
| Packed | Mark as In Transit (primary green) |
| In Transit | Mark as Shipped (shipped green `#2E7D32`) |
| Shipped | No action button (completed) |

---

## Data Model (Drift)

```dart
// Predefined locations — seeded on first run
class Locations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'warehouse' | 'outlet'
}

class DeliveryOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text()(); // DO-YYYY-XXXX
  IntColumn get fromLocationId => integer().references(Locations, #id)();
  IntColumn get toLocationId => integer().references(Locations, #id)();
  DateTimeColumn get deliveryDate => dateTime()();
  TextColumn get status => text()(); // pending_approval|submitted|packed|in_transit|shipped|draft
  BoolColumn get requiresApproval => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class SalesOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text()(); // SO-YYYY-XXXX
  TextColumn get customerName => text()();
  DateTimeColumn get orderDate => dateTime()();
  TextColumn get status => text()();
  BoolColumn get requiresApproval => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

// Shared items — polymorphic via orderType + orderId
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer()();
  TextColumn get orderType => text()(); // 'delivery' | 'sales'
  TextColumn get itemId => text()();
  TextColumn get itemName => text()();
  TextColumn get itemSku => text()();
  IntColumn get quantity => integer()();
}

// Append-only status log
class OrderStatusHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer()();
  TextColumn get orderType => text()();
  TextColumn get status => text()();
  TextColumn get changedBy => text()();
  DateTimeColumn get changedAt => dateTime()();
}
```

### Riverpod Providers

| Provider | Type | Purpose |
|---|---|---|
| `deliveryOrdersProvider(tab)` | `StreamProvider` | DO list filtered by Active/Completed tab |
| `salesOrdersProvider(tab)` | `StreamProvider` | SO list filtered by Active/Completed tab |
| `orderDetailProvider(id, type)` | `FutureProvider` | Single order + items + history |
| `locationsProvider` | `FutureProvider` | Predefined location list (cached) |
| `createDeliveryOrderNotifier` | `AsyncNotifier` | Multi-step form state + submit |
| `createSalesOrderNotifier` | `AsyncNotifier` | Multi-step form state + submit |

---

## Shared Widget: ItemPickerSheet

Reusable widget used in both DO and SO creation Step 2.

- Barcode scanner input at top (uses existing scanner integration)
- Searchable item list below
- Each item row: name, SKU, quantity stepper
- Notifies parent via callback when items list changes
- Lives under `lib/shared/widgets/item_picker_sheet.dart`

---

## Error Handling

- **Form validation**: inline on "Next" / "Submit" tap — no real-time validation
- **Required field errors**: shown below the field label in error red (`#C62828`)
- **Async errors** (submit, status update): `SnackBar` at bottom with plain message
- **Empty list**: centered secondary text — "No delivery orders yet" / "No sales orders yet"
- **Offline**: `OfflineBanner` shows automatically; create and status-update actions queue in `SyncQueue` and flush on reconnect (same pattern as Stock Receiving)

---

## Design Compliance

All screens follow `Design.md`:
- Colors: `AppColors.*` tokens
- Typography: `AppTextStyles.*`
- SafeArea: applied at screen level
- Navigation: `context.push` for nested screens
- No emojis — Material Icons only
- Bottom action bars use full-width `ElevatedButton` / `OutlinedButton`
