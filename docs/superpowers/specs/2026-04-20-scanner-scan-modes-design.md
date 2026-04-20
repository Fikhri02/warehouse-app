# Scanner Scan Mode Switcher — Design Spec

**Date**: 2026-04-20
**Feature**: Swipe-to-switch scan modes on the camera preview
**Screens**: Stock Count (`scan_count_screen.dart`), Stock Receiving (`receive_items_screen.dart`)
**Shared widget**: `scanner_preview_panel.dart`

---

## Overview

Add three scan modes to the camera preview, switchable by swiping left/right on the preview. A new `ScanModePanel` wrapper widget owns mode state and overlays, leaving `ScannerPreviewPanel` completely unchanged.

---

## Modes

| Mode | Enum value | Behaviour |
|------|-----------|-----------|
| One-snap | `ScanMode.oneSnap` | Camera starts frozen. User taps overlay to arm. One barcode detected → fires `onDetect`, immediately re-freezes. |
| Bulk | `ScanMode.bulk` | Existing continuous behaviour. No restriction. |
| 3s-delay | `ScanMode.threeSecDelay` | Camera starts armed. On detect → fires `onDetect`, shows 3s countdown overlay. Detections during countdown are silently ignored. Camera re-arms automatically at 0. |

**Default**: `bulk` on every screen open (per-session, no persistence).

**Swipe order** (left → right): `oneSnap` → `bulk` → `threeSecDelay`

---

## Architecture

New file: `lib/core/widgets/scan_mode_panel.dart`

```
ScanModePanel
├── _mode: ScanMode                   — ephemeral, starts at bulk
├── _pillVisible: bool                — auto-hides after 1.5s
├── _oneSnapArmed: bool               — one-snap arm state
├── _countdownTimer: Timer?           — 3s delay countdown
├── _countdownSeconds: int            — 3, 2, 1, 0
│
├── Stack
│   ├── ScannerPreviewPanel           — unchanged; receives _handleDetect
│   ├── GestureDetector               — onHorizontalDragEnd for mode switch
│   └── _ModeOverlay                  — pill + mode-specific overlay
```

`ScanModePanel` exposes an identical public API to `ScannerPreviewPanel`:

```dart
ScanModePanel({
  required FutureOr<void> Function(BarcodeCapture) onDetect,
  required double collapsedHeight,
  required double expandedHeight,
  bool paused = false,
  String pausedLabel = 'Scan paused',
  Widget? bottomRightOverlay,
  ValueChanged<bool>? onExpandedChanged,
})
```

Both caller screens replace `ScannerPreviewPanel(...)` with `ScanModePanel(...)` — no other changes.

---

## Gesture Handling

A `GestureDetector` with `onHorizontalDragEnd` and `behavior: HitTestBehavior.translucent` sits over the full panel stack. `translucent` ensures taps and other pointer events still reach `ScannerPreviewPanel` underneath. Flutter's gesture arena resolves horizontal vs vertical drag by initial direction — no conflict with `ScannerPreviewPanel`'s existing `onVerticalDragEnd`.

- Swipe right → advance mode index (wraps: `threeSecDelay` → `oneSnap`)
- Swipe left → retreat mode index (wraps: `oneSnap` → `threeSecDelay`)
- Velocity threshold: 250 (matches existing `_previewSwipeVelocityThreshold`)

On mode change:
1. Cancel any active countdown timer
2. Reset `_oneSnapArmed` to `false`
3. Set `_mode` to new mode
4. Show mode pill for 1.5s then hide

---

## Mode Pill

Floating pill, top-centre of the preview.

- **Bulk**: dark background (`rgba(0,0,0,0.6)`), label `BULK`, chevrons `‹ ›` on each side
- **One-snap / 3s-delay**: accent background (`AppColors.primary` at 75% opacity), label `ONE-SNAP` / `3S DELAY`
- Appears on every mode change, auto-hides after 1.5s via debounced `Timer`
- Also visible persistently inside the One-snap and 3s-delay overlays (so user knows why camera is paused)

---

## One-snap Overlay

Shown when `_mode == oneSnap && !_oneSnapArmed`.

- Full-area overlay: `rgba(10,10,30,0.65)` background
- Centre: accent-coloured ring (`AppColors.primary` at 60% opacity border, 18% fill) containing a target icon
- Label: `TAP TO SCAN NEXT` (white, semibold)
- Sub-label: `One-snap mode` (white at 45% opacity)
- Mode pill pinned at top-centre (always visible, no auto-hide while frozen)
- Tap anywhere on overlay → sets `_oneSnapArmed = true`, overlay disappears

---

## 3s-delay Overlay

Shown when `_mode == threeSecDelay && _countdownSeconds > 0`.

- Full-area overlay: `rgba(0,0,0,0.45)` background
- Centre: circular `AnimatedWidget` progress ring (`AppColors.primary` at 90% opacity), sweeps from full to empty over 3s
- Countdown number inside ring (3 → 2 → 1 → disappears at 0)
- Label: `NEXT SCAN IN` (white at 70% opacity, semibold)
- Mode pill pinned at top-centre (always visible while counting)
- Timer ticks each second; at 0 → overlay dismissed, camera re-arms

Implementation: `_countdownTimer = Timer.periodic(1s, ...)` started in `_handleDetect`. Cancelled in `dispose()` and on mode change.

The circular ring uses a custom `CustomPainter` or `CircularProgressIndicator` driven by `_countdownSeconds / 3`.

---

## onDetect Interception

`ScanModePanel._handleDetect(BarcodeCapture capture)`:

```
bulk         → widget.onDetect(capture)
oneSnap      → if armed: widget.onDetect(capture), set armed=false
threeSecDelay→ if not counting: widget.onDetect(capture), start countdown
             → if counting: ignore
```

---

## Caller Changes

**`scan_count_screen.dart`**: Replace `ScannerPreviewPanel(` with `ScanModePanel(` — all parameters identical.

**`receive_items_screen.dart`**: Same one-line swap.

Both files add import for `scan_mode_panel.dart`.

---

## Files Changed

| File | Change |
|------|--------|
| `lib/core/widgets/scan_mode_panel.dart` | **New** — `ScanModePanel` widget + `ScanMode` enum |
| `lib/features/stock_count/presentation/scan_count_screen.dart` | Import swap + widget name swap |
| `lib/features/receiving/presentation/receive_items_screen.dart` | Import swap + widget name swap |
| `lib/core/widgets/scanner_preview_panel.dart` | **No changes** |

---

## Edge Cases

| Situation | Behaviour |
|-----------|-----------|
| Mode switched while countdown active | Cancel timer, reset to armed state in new mode |
| Mode switched while one-snap frozen | Disarm; new mode takes effect immediately |
| `paused=true` passed from parent | `ScannerPreviewPanel` handles it; overlays still render on top |
| App navigates away mid-countdown | `dispose()` cancels timer |
| Swipe during frozen/countdown overlay | Gesture still fires; mode switches correctly |
