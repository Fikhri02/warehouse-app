import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../data/local/app_database.dart' as db;
import '../../../core/router/app_routes.dart';
import '../../../data/sample/sample_locations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/count_session.dart';
import '../providers/stock_count_provider.dart';

class StartCountScreen extends ConsumerStatefulWidget {
  const StartCountScreen({super.key});

  @override
  ConsumerState<StartCountScreen> createState() => _StartCountScreenState();
}

class _StartCountScreenState extends ConsumerState<StartCountScreen> {
  CountSession? _latestSession;
  bool _loadingSession = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadLatestInProgressSession);
  }

  Future<void> _loadLatestInProgressSession() async {
    final session = await ref
        .read(db.appDatabaseProvider)
        .countSessionDao
        .getLatestInProgressSession();
    if (!mounted) return;
    setState(() {
      _latestSession = session == null
          ? null
          : CountSession(
              id: session.id,
              location: session.location,
              label: session.label,
              startedAt: session.startedAt,
              status: CountSessionStatus.inProgress,
              locationId: session.locationId,
              assignedWorkerId: session.assignedWorkerId,
              deadline: session.deadline,
              zoneAisle: session.zoneAisle,
            );
      _loadingSession = false;
    });
  }

  Future<void> _resumeSession() async {
    final session = _latestSession;
    if (session == null) return;
    await ref
        .read(stockCountNotifierProvider.notifier)
        .loadSessionById(session.id);
    if (mounted) context.push(AppRoutes.stockCountScan);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final brightness = Theme.of(context).brightness;
    final latestSession = _latestSession;
    final latestLocationName = _locationName(latestSession);

    return Scaffold(
      appBar: AppBar(title: const Text('New Count Session')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Create and manage count sessions before the team starts scanning.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary(brightness),
              ),
            ),
            const SizedBox(height: 12),
            if (_loadingSession)
              const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ))
            else if (latestSession != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface(brightness),
                  border: Border.all(
                    color: AppColors.warningBorder(brightness),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Resume in-progress session',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warningForeground(brightness),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      latestLocationName,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.warningForeground(brightness),
                      ),
                    ),
                    if (latestSession.zoneAisle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        latestSession.zoneAisle!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warningForeground(brightness),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Started ${_formatDateTime(context, latestSession.startedAt)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warningForeground(brightness),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _resumeSession,
                            child: const Text('Resume'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                context.push(AppRoutes.stockCountCreate),
                            child: const Text('Create New'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (!isOnline)
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
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.warningForeground(brightness),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No connection — drafts and active sessions stay local and can sync later.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warningForeground(brightness),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New session',
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Set the location, optional worker, and deadline before counting begins.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.push(AppRoutes.stockCountCreate),
                        child: const Text('Create Session'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _locationName(CountSession? session) {
    if (session == null) return '';
    final locationId = session.locationId;
    final location = locationId == null
        ? null
        : sampleLocations.where((item) => item.id == locationId).firstOrNull;
    return location?.name ?? session.location;
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(dateTime);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(dateTime),
      alwaysUse24HourFormat: true,
    );
    return '$date, $time';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
