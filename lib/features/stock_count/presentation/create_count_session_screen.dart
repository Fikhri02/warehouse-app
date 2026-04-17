import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/models/location.dart';
import '../../../core/models/worker.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/sample/sample_locations.dart';
import '../../../data/sample/sample_workers.dart';
import '../providers/create_count_session_notifier.dart';
import '../providers/stock_count_provider.dart';

enum _LocationPermissionUiState { initial, denied, permanentlyDenied }

class CreateCountSessionScreen extends ConsumerStatefulWidget {
  const CreateCountSessionScreen({super.key});

  @override
  ConsumerState<CreateCountSessionScreen> createState() =>
      _CreateCountSessionScreenState();
}

class _CreateCountSessionScreenState
    extends ConsumerState<CreateCountSessionScreen> {
  bool _submitted = false;
  bool _submitting = false;
  bool _showHints = false;
  String _workerQuery = '';
  _LocationPermissionUiState _locationPermissionState =
      _LocationPermissionUiState.initial;

  bool get _showWorkerSearch => sampleWorkers.length >= 5;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadLocationPermissionState);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCountSessionNotifierProvider);
    final notifier = ref.read(createCountSessionNotifierProvider.notifier);
    final brightness = Theme.of(context).brightness;
    final selectedLocation = _selectedLocation(state.locationId);
    final selectedWorker = _selectedWorker(state.assignedWorkerId);
    final visibleWorkers = _filteredWorkers();
    final workerOptions = _workerOptions(visibleWorkers, selectedWorker);
    final hasDeadlineError = _submitted &&
        state.deadline != null &&
        state.deadline!.isBefore(DateTime.now());
    final hasLocationError = _submitted && state.locationId == null;
    final saveIndicator = _saveIndicatorData(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Count Session'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(34),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: SizedBox(
              height: 26,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Row(
                  key: ValueKey(saveIndicator.label),
                  children: [
                    if (saveIndicator.showSpinner)
                      const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white70,
                          ),
                        ),
                      )
                    else
                      Icon(
                        saveIndicator.icon,
                        size: 14,
                        color: saveIndicator.color,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      saveIndicator.label,
                      style: AppTextStyles.caption.copyWith(
                        color: saveIndicator.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header: required field legend + hint toggle
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary(brightness),
                          ),
                          children: const [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: AppColors.info,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' Required field'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      FilterChip(
                        label: Text(_showHints ? 'Hide hints' : 'Show hints'),
                        selected: _showHints,
                        onSelected: (v) => setState(() => _showHints = v),
                        avatar: Icon(
                          _showHints
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 14,
                        ),
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  if (_showHints)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Choose the location first, then add zone, worker, and deadline only if they matter for this session.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Location field
                  const _FieldHeader(text: 'Location', required: true),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(state.locationId),
                          initialValue: state.locationId,
                          decoration: const InputDecoration(
                            hintText: 'Select location',
                          ),
                          items: sampleLocations
                              .map(
                                (location) => DropdownMenuItem<String>(
                                  value: location.id,
                                  child: Text(location.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              notifier.setLocation(value);
                            }
                          },
                        ),
                      ),
                      if (_locationPermissionState !=
                          _LocationPermissionUiState.permanentlyDenied) ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _useNearestLocation,
                          icon: const Icon(
                            Icons.my_location_outlined,
                            size: 18,
                          ),
                          label: const Text('Use Nearest'),
                        ),
                      ],
                    ],
                  ),
                  if (hasLocationError)
                    const _InlineError(
                      'Select a location before creating the session.',
                    ),
                  if (_showHints && !hasLocationError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        selectedLocation == null
                            ? 'Pick the warehouse or area where the count will happen.'
                            : selectedLocation.hasZones
                                ? 'This location has zone data. You can narrow the session further below.'
                                : 'This location does not use zones, so the extra selector stays hidden.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                      ),
                    ),

                  // Permanently denied location warning
                  if (_locationPermissionState ==
                      _LocationPermissionUiState.permanentlyDenied) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningSurface(brightness),
                        border: Border.all(
                          color: AppColors.warningBorder(brightness),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 16,
                            color: AppColors.warningForeground(brightness),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Location permission is permanently denied. Enable it in app settings to use nearest location.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warningForeground(brightness),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => openAppSettings(),
                            child: const Text('Go to Settings'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Denied (requestable) location warning
                  if (_locationPermissionState ==
                      _LocationPermissionUiState.denied) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningSurface(brightness),
                        border: Border.all(
                          color: AppColors.warningBorder(brightness),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 16,
                            color: AppColors.warningForeground(brightness),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Location access is needed for nearest-site selection.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warningForeground(brightness),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _useNearestLocation,
                            child: const Text('Enable Location'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Zone / Aisle field
                  if (selectedLocation?.hasZones == true &&
                      selectedLocation!.zones.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const _FieldHeader(text: 'Zone / Aisle'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      key: ValueKey(state.zoneAisle),
                      initialValue: state.zoneAisle,
                      decoration: const InputDecoration(
                        hintText: 'Select zone or aisle',
                      ),
                      items: selectedLocation.zones
                          .map(
                            (zone) => DropdownMenuItem<String>(
                              value: zone,
                              child: Text(zone),
                            ),
                          )
                          .toList(),
                      onChanged: notifier.setZoneAisle,
                    ),
                    if (_showHints)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Use zone or aisle only when the selected location has mapped sections.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary(brightness),
                          ),
                        ),
                      ),
                  ],

                  // Worker field
                  const SizedBox(height: 16),
                  const _FieldHeader(text: 'Assign Worker'),
                  const SizedBox(height: 6),
                  if (_showWorkerSearch) ...[
                    TextField(
                      onChanged: (value) =>
                          setState(() => _workerQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search worker',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _workerSearchHelperText(
                        visibleWorkers: visibleWorkers,
                        selectedWorker: selectedWorker,
                      ),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  DropdownButtonFormField<String?>(
                    key: ValueKey(
                      '${state.assignedWorkerId}_${workerOptions.length}_${_workerQuery.trim()}',
                    ),
                    initialValue: state.assignedWorkerId,
                    decoration: const InputDecoration(
                      hintText: 'Assign later',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Assign later'),
                      ),
                      ...workerOptions.map(
                        (worker) => DropdownMenuItem<String?>(
                          value: worker.id,
                          child: Text(
                            selectedWorker?.id == worker.id &&
                                    !visibleWorkers
                                        .any((w) => w.id == worker.id)
                                ? '${worker.name} · ${worker.role} (selected)'
                                : '${worker.name} · ${worker.role}',
                          ),
                        ),
                      ),
                    ],
                    onChanged: notifier.setWorker,
                  ),
                  if (_showHints)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Leave this unassigned if the supervisor wants to decide the worker later.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                      ),
                    ),
                  if (visibleWorkers.isEmpty && selectedWorker == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'No workers match that search yet. Clear the search or keep this session unassigned.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                      ),
                    ),

                  // Deadline field
                  const SizedBox(height: 16),
                  const _FieldHeader(text: 'Deadline'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('Today'),
                        onPressed: () => notifier.setDeadline(_today()),
                      ),
                      ActionChip(
                        label: const Text('Tomorrow'),
                        onPressed: () => notifier.setDeadline(_tomorrow()),
                      ),
                      ActionChip(
                        label: const Text('End of Week'),
                        onPressed: () => notifier.setDeadline(_endOfWeek()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _submitting
                        ? null
                        : () => _pickDeadline(state.deadline),
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        hintText: 'Select date',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        state.deadline == null
                            ? 'No deadline'
                            : _formatDate(context, state.deadline!),
                        style: AppTextStyles.body.copyWith(
                          color: state.deadline == null
                              ? AppColors.textSecondary(brightness)
                              : AppColors.textPrimary(brightness),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: state.deadline == null
                          ? null
                          : () => notifier.setDeadline(null),
                      child: const Text('Clear deadline'),
                    ),
                  ),
                  if (hasDeadlineError)
                    const _InlineError('Deadline must be in the future.'),
                  if (_showHints && !hasDeadlineError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        state.deadline == null
                            ? 'Leave this empty if the team can count whenever ready.'
                            : 'This deadline is saved with the draft and can be changed later.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                      ),
                    ),

                  // Session summary card
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Session summary',
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Location',
                            value: selectedLocation?.name ?? '—',
                          ),
                          _SummaryRow(
                            label: 'Zone / Aisle',
                            value: state.zoneAisle ?? '—',
                          ),
                          _SummaryRow(
                            label: 'Assigned worker',
                            value: selectedWorker?.name ?? 'Unassigned',
                          ),
                          _SummaryRow(
                            label: 'Deadline',
                            value: state.deadline == null
                                ? 'No deadline'
                                : _formatDate(context, state.deadline!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Session'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadLocationPermissionState() async {
    final status = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    setState(() {
      _locationPermissionState = _permissionStateFromStatus(status);
    });
  }

  Future<void> _useNearestLocation() async {
    final currentStatus = await Permission.locationWhenInUse.status;
    if (!mounted) return;

    if (currentStatus.isGranted || currentStatus.isLimited) {
      _selectNearestLocation();
      return;
    }

    if (currentStatus.isPermanentlyDenied || currentStatus.isRestricted) {
      setState(() {
        _locationPermissionState = _LocationPermissionUiState.permanentlyDenied;
      });
      return;
    }

    final requestStatus = await Permission.locationWhenInUse.request();
    if (!mounted) return;

    setState(() {
      _locationPermissionState = _permissionStateFromStatus(requestStatus);
    });

    if (requestStatus.isGranted || requestStatus.isLimited) {
      _selectNearestLocation();
    }
  }

  Future<void> _pickDeadline(DateTime? initialDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref.read(createCountSessionNotifierProvider.notifier).setDeadline(
          DateTime(picked.year, picked.month, picked.day, 17),
        );
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);

    final state = ref.read(createCountSessionNotifierProvider);
    if (state.locationId == null) return;
    if (state.deadline != null && state.deadline!.isBefore(DateTime.now())) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final sessionId =
          await ref.read(createCountSessionNotifierProvider.notifier).submit();
      await ref
          .read(stockCountNotifierProvider.notifier)
          .loadSessionById(sessionId);
      if (!mounted) return;
      context.push(AppRoutes.stockCountScan);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create session — please try again'),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Location? _selectedLocation(String? locationId) {
    if (locationId == null) return null;
    for (final location in sampleLocations) {
      if (location.id == locationId) return location;
    }
    return null;
  }

  Worker? _selectedWorker(String? workerId) {
    if (workerId == null) return null;
    for (final worker in sampleWorkers) {
      if (worker.id == workerId) return worker;
    }
    return null;
  }

  List<Worker> _filteredWorkers() {
    final query = _workerQuery.trim().toLowerCase();
    if (query.isEmpty) return sampleWorkers;
    return sampleWorkers
        .where(
          (worker) =>
              worker.name.toLowerCase().contains(query) ||
              worker.role.toLowerCase().contains(query),
        )
        .toList();
  }

  List<Worker> _workerOptions(
    List<Worker> visibleWorkers,
    Worker? selectedWorker,
  ) {
    if (selectedWorker == null) return visibleWorkers;
    final hasSelected = visibleWorkers.any(
      (worker) => worker.id == selectedWorker.id,
    );
    if (hasSelected) return visibleWorkers;
    return [selectedWorker, ...visibleWorkers];
  }

  void _selectNearestLocation() {
    setState(() {
      _locationPermissionState = _LocationPermissionUiState.initial;
    });
    ref
        .read(createCountSessionNotifierProvider.notifier)
        .setLocation(sampleLocations.first.id);
  }

  _LocationPermissionUiState _permissionStateFromStatus(
    PermissionStatus status,
  ) {
    if (status.isGranted || status.isLimited) {
      return _LocationPermissionUiState.initial;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return _LocationPermissionUiState.permanentlyDenied;
    }
    return _LocationPermissionUiState.denied;
  }

  _SaveIndicatorData _saveIndicatorData(CreateCountSessionState state) {
    switch (state.saveStatus) {
      case CreateSessionSaveStatus.saving:
        return const _SaveIndicatorData(
          label: 'Saving draft',
          icon: Icons.sync,
          color: Colors.white70,
          showSpinner: true,
        );
      case CreateSessionSaveStatus.saved:
        return const _SaveIndicatorData(
          label: 'Draft saved',
          icon: Icons.check_circle_outline,
          color: Colors.white70,
        );
      case CreateSessionSaveStatus.error:
        return const _SaveIndicatorData(
          label: 'Draft save failed',
          icon: Icons.error_outline,
          color: Color(0xFFFFCDD2),
        );
      case CreateSessionSaveStatus.idle:
        if (_hasDraftContent(state)) {
          return const _SaveIndicatorData(
            label: 'Draft saves automatically',
            icon: Icons.drafts_outlined,
            color: Colors.white70,
          );
        }
        return const _SaveIndicatorData(
          label: 'Optional fields can be filled later',
          icon: Icons.info_outline,
          color: Colors.white70,
        );
    }
  }

  bool _hasDraftContent(CreateCountSessionState state) {
    return state.locationId != null ||
        state.zoneAisle != null ||
        state.assignedWorkerId != null ||
        state.deadline != null ||
        state.draftId != null;
  }

  String _workerSearchHelperText({
    required List<Worker> visibleWorkers,
    required Worker? selectedWorker,
  }) {
    final query = _workerQuery.trim();
    if (query.isEmpty) {
      return '${sampleWorkers.length} workers available. Leave unassigned if the supervisor will decide later.';
    }
    if (visibleWorkers.isEmpty && selectedWorker != null) {
      return 'No new matches for "$query". The current selection is still preserved.';
    }
    if (visibleWorkers.isEmpty) {
      return 'No workers match "$query".';
    }
    return 'Showing ${visibleWorkers.length} of ${sampleWorkers.length} workers.';
  }

  String _formatDate(BuildContext context, DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatMediumDate(value);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 18);
  }

  DateTime _tomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18);
  }

  DateTime _endOfWeek() {
    final now = DateTime.now();
    final daysUntilSunday = DateTime.daysPerWeek - now.weekday;
    final end = now.add(Duration(days: daysUntilSunday));
    return DateTime(end.year, end.month, end.day, 18);
  }
}

class _FieldHeader extends StatelessWidget {
  final String text;
  final bool required;

  const _FieldHeader({
    required this.text,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: AppTextStyles.micro.copyWith(
            color: AppColors.textSecondary(brightness),
            letterSpacing: 0.5,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: AppTextStyles.micro.copyWith(
              color: AppColors.info,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary(brightness),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String text;

  const _InlineError(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}

class _SaveIndicatorData {
  final String label;
  final IconData icon;
  final Color color;
  final bool showSpinner;

  const _SaveIndicatorData({
    required this.label,
    required this.icon,
    required this.color,
    this.showSpinner = false,
  });
}
