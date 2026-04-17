import 'package:warehouse_app/core/models/location.dart';

final List<Location> sampleLocations = [
  const Location(
    id: 'loc_warehouse_a',
    name: 'Warehouse A',
    hasZones: true,
    zones: ['Zone A1', 'Zone A2', 'Zone A3', 'Zone A4'],
  ),
  const Location(
    id: 'loc_warehouse_b',
    name: 'Warehouse B',
    hasZones: true,
    zones: ['Zone B1', 'Zone B2', 'Zone B3'],
  ),
  const Location(
    id: 'loc_cold_storage',
    name: 'Cold Storage',
    hasZones: true,
    zones: ['Freezer Row 1', 'Freezer Row 2', 'Chiller Section'],
  ),
  const Location(
    id: 'loc_mezzanine',
    name: 'Mezzanine Floor',
    hasZones: true,
    zones: ['Level M1', 'Level M2'],
  ),
  const Location(
    id: 'loc_loading_bay',
    name: 'Loading Bay',
    hasZones: false,
  ),
  const Location(
    id: 'loc_returns_area',
    name: 'Returns Area',
    hasZones: false,
  ),
  const Location(
    id: 'loc_bulk_store',
    name: 'Bulk Store',
    hasZones: true,
    zones: ['Aisle 1', 'Aisle 2', 'Aisle 3'],
  ),
  const Location(
    id: 'loc_dispatch',
    name: 'Dispatch Zone',
    hasZones: false,
  ),
];
