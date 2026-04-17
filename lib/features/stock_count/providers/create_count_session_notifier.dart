import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/app_database.dart' as db;

enum CreateSessionSaveStatus { idle, saving, saved, error }

class CreateCountSessionState {
  final String? locationId;
  final String? zoneAisle;
  final String? assignedWorkerId;
  final DateTime? deadline;
  final String? draftId;
  final CreateSessionSaveStatus saveStatus;

  const CreateCountSessionState({
    this.locationId,
    this.zoneAisle,
    this.assignedWorkerId,
    this.deadline,
    this.draftId,
    this.saveStatus = CreateSessionSaveStatus.idle,
  });

  CreateCountSessionState copyWith({
    String? locationId,
    Object? zoneAisle = _sentinel,
    Object? assignedWorkerId = _sentinel,
    Object? deadline = _sentinel,
    String? draftId,
    CreateSessionSaveStatus? saveStatus,
  }) {
    return CreateCountSessionState(
      locationId: locationId ?? this.locationId,
      zoneAisle: zoneAisle == _sentinel ? this.zoneAisle : zoneAisle as String?,
      assignedWorkerId: assignedWorkerId == _sentinel
          ? this.assignedWorkerId
          : assignedWorkerId as String?,
      deadline: deadline == _sentinel ? this.deadline : deadline as DateTime?,
      draftId: draftId ?? this.draftId,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }
}

// Sentinel for nullable copyWith fields
const Object _sentinel = Object();

class CreateCountSessionNotifier extends Notifier<CreateCountSessionState> {
  Timer? _debounceTimer;
  Timer? _statusResetTimer;

  @override
  CreateCountSessionState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _statusResetTimer?.cancel();
    });
    return const CreateCountSessionState();
  }

  void setLocation(String locationId) {
    state = state.copyWith(
      locationId: locationId,
      zoneAisle: null,
    );
    _scheduleSave();
  }

  void setZoneAisle(String? zoneAisle) {
    state = state.copyWith(zoneAisle: zoneAisle);
    _scheduleSave();
  }

  void setWorker(String? workerId) {
    state = state.copyWith(assignedWorkerId: workerId);
    _scheduleSave();
  }

  void setDeadline(DateTime? deadline) {
    state = state.copyWith(deadline: deadline);
    _scheduleSave();
  }

  /// Validates and finalises the session as [in_progress].
  /// Returns the session ID.
  /// Throws [StateError] if [locationId] is null.
  Future<String> submit() async {
    final locationId = state.locationId;
    if (locationId == null) {
      throw StateError('locationId is required to submit a count session');
    }

    final sessionId = _getOrCreateDraftId();
    final dao = ref.read(db.appDatabaseProvider).countSessionDao;
    await dao.saveOrUpdateDraft(
      db.CountSessionsCompanion.insert(
        id: sessionId,
        location: '',
        status: 'in_progress',
        startedAt: DateTime.now(),
        locationId: Value(locationId),
        assignedWorkerId: Value(state.assignedWorkerId),
        deadline: Value(state.deadline),
        zoneAisle: Value(state.zoneAisle),
      ),
    );
    return sessionId;
  }

  // ── internals ──────────────────────────────────────────────────────────────

  void _scheduleSave() {
    _debounceTimer?.cancel();
    _statusResetTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _save);
  }

  Future<void> _save() async {
    state = state.copyWith(saveStatus: CreateSessionSaveStatus.saving);
    try {
      final sessionId = _getOrCreateDraftId();
      final dao = ref.read(db.appDatabaseProvider).countSessionDao;
      await dao.saveOrUpdateDraft(
        db.CountSessionsCompanion.insert(
          id: sessionId,
          location: '',
          status: 'draft',
          startedAt: DateTime.now(),
          locationId: Value(state.locationId),
          assignedWorkerId: Value(state.assignedWorkerId),
          deadline: Value(state.deadline),
          zoneAisle: Value(state.zoneAisle),
        ),
      );
      state = state.copyWith(saveStatus: CreateSessionSaveStatus.saved);
      _statusResetTimer = Timer(const Duration(milliseconds: 1800), () {
        if (state.saveStatus == CreateSessionSaveStatus.saved) {
          state = state.copyWith(saveStatus: CreateSessionSaveStatus.idle);
        }
      });
    } catch (_) {
      state = state.copyWith(saveStatus: CreateSessionSaveStatus.error);
    }
  }

  /// Returns the existing [draftId] or generates and persists a new one.
  String _getOrCreateDraftId() {
    final existing = state.draftId;
    if (existing != null) return existing;
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    state = state.copyWith(draftId: newId);
    return newId;
  }
}

final createCountSessionNotifierProvider =
    NotifierProvider<CreateCountSessionNotifier, CreateCountSessionState>(
  CreateCountSessionNotifier.new,
);
