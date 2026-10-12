import 'package:warehouse_app/core/models/order.dart';

/// Bins to pick from in Sample mode.
const sampleOrderLocations = <OrderLocation>[
  OrderLocation(id: 'bin-a0101', name: 'A-01-01', type: 'Bin'),
  OrderLocation(id: 'bin-a0102', name: 'A-01-02', type: 'Bin'),
  OrderLocation(id: 'bin-b0101', name: 'B-01-01', type: 'Bin'),
  OrderLocation(id: 'dock-1', name: 'DOCK-1', type: 'Dock'),
];
