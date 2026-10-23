import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/purchase_order.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/scanner_preview_panel.dart';
import '../providers/receiving_provider.dart';

/// Track behind the To receive / Received switch and the progress bars.
Color _trackColor(Brightness brightness) => brightness == Brightness.dark
    ? const Color(0xFF2A2A2A)
    : const Color(0xFFE1E8E7);

Color _accent(Brightness brightness) =>
    brightness == Brightness.dark ? AppColors.darkAccent : AppColors.primary;

// An open in-progress row in dark mode sits on deep teal, like the Stock Count card on Home.
const _tealMuted = Color(0xFFC9DCDA);
const _tealIdle = Color(0xFF7FA19E);
const _tealRule = Color(0x24FFFFFF);

class PoListScreen extends ConsumerStatefulWidget {
  const PoListScreen({super.key});

  @override
  ConsumerState<PoListScreen> createState() => _PoListScreenState();
}

class _PoListScreenState extends ConsumerState<PoListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _syncAndReload() =>
      ref.read(purchaseOrdersNotifierProvider.notifier).syncAndReload();

  void _setSearch(String value) {
    _searchController.text = value;
    setState(() => _search = value);
  }

  /// A scanned PO barcode fills the search, so the order is the one row left.
  Future<void> _scanPo() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      // Over the bottom bar, not under it.
      useRootNavigator: true,
      showDragHandle: true,
      builder: (_) => const _ScanPoSheet(),
    );
    if (code == null || !mounted) return;
    _setSearch(code);
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(purchaseOrdersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Purchase orders',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Scan a PO barcode',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanPo,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ordersState.when(
          loading: () => const _PoListSkeleton(),
          error: (_, __) => _LoadFailed(
            onRetry: () => ref.invalidate(purchaseOrdersNotifierProvider),
          ),
          data: (orders) {
            final query = _search.toLowerCase();
            final filtered = query.isEmpty
                ? orders
                : orders
                    .where(
                      (order) =>
                          order.displayNumber.toLowerCase().contains(query) ||
                          order.supplier.toLowerCase().contains(query),
                    )
                    .toList();

            final inProgress =
                filtered.where((o) => o.status == PoStatus.inProgress).toList();
            final pending =
                filtered.where((o) => o.status == PoStatus.pending).toList();
            final completed =
                filtered.where((o) => o.status == PoStatus.received).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _search = value),
                    decoration: InputDecoration(
                      hintText: 'Search PO or supplier',
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _search.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => _setSearch(''),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SegmentTabs(
                    controller: _tabs,
                    labels: [
                      'To receive · ${inProgress.length + pending.length}',
                      'Received · ${completed.length}',
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      RefreshIndicator(
                        onRefresh: _syncAndReload,
                        child: _PoList(
                          sections: [
                            ('In progress', inProgress),
                            ('Not started', pending),
                          ],
                          emptyText: _search.isEmpty
                              ? 'No purchase orders to receive. Pull down to check for new ones.'
                              : 'No orders to receive match "$_search".',
                          emptyAction: _search.isEmpty
                              ? ('Check received', () => _tabs.animateTo(1))
                              : ('Clear search', () => _setSearch('')),
                          ref: ref,
                        ),
                      ),
                      RefreshIndicator(
                        onRefresh: _syncAndReload,
                        child: _PoList(
                          sections: [(null, completed)],
                          emptyText: _search.isEmpty
                              ? 'No received orders yet.'
                              : 'No received orders match "$_search".',
                          emptyAction: _search.isEmpty
                              ? ('Check to receive', () => _tabs.animateTo(0))
                              : ('Clear search', () => _setSearch('')),
                          ref: ref,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// To receive / Received as one segmented switch; the TabBar keeps swiping between them.
class _SegmentTabs extends StatelessWidget {
  final TabController controller;
  final List<String> labels;

  const _SegmentTabs({required this.controller, required this.labels});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _trackColor(brightness),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.surfaceFor(brightness),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        splashBorderRadius: BorderRadius.circular(8),
        labelColor: _accent(brightness),
        unselectedLabelColor: AppColors.textSecondary(brightness),
        labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
        tabs: [for (final label in labels) Tab(height: 36, text: label)],
      ),
    );
  }
}

class _PoList extends StatelessWidget {
  final List<(String?, List<PurchaseOrder>)> sections;
  final String emptyText;
  final (String, VoidCallback) emptyAction;
  final WidgetRef ref;

  const _PoList({
    required this.sections,
    required this.emptyText,
    required this.emptyAction,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final visible = sections.where((s) => s.$2.isNotEmpty).toList();

    if (visible.isEmpty) {
      // Scrollable, so pulling down still fetches new orders.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(32, 120, 32, 16),
        children: [
          Text(
            emptyText,
            textAlign: TextAlign.center,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary(brightness)),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: emptyAction.$2,
              child: Text(emptyAction.$1),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        for (final (label, orders) in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PoSection(label: label, orders: orders, ref: ref),
          ),
      ],
    );
  }
}

/// One flat card per section, its orders as rows split by dividers.
class _PoSection extends StatelessWidget {
  final String? label;
  final List<PurchaseOrder> orders;
  final WidgetRef ref;

  const _PoSection(
      {required this.label, required this.orders, required this.ref});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              '$label · ${orders.length}',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(brightness),
              ),
            ),
          ),
        Material(
          color: AppColors.surfaceFor(brightness),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < orders.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 16,
                    color: brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.divider,
                  ),
                _PoRow(order: orders[i], ref: ref),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// An in-progress row opens in place to show its lines and Continue receiving; other rows open their order.
class _PoRow extends StatefulWidget {
  final PurchaseOrder order;
  final WidgetRef ref;

  const _PoRow({required this.order, required this.ref});

  @override
  State<_PoRow> createState() => _PoRowState();
}

class _PoRowState extends State<_PoRow> {
  bool _expanded = false;

  PurchaseOrder get order => widget.order;

  void _startReceive() {
    widget.ref.read(activeReceiveNotifierProvider.notifier).startReceive(order);
    context.push(AppRoutes.receivingItems);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final onTeal = _expanded && brightness == Brightness.dark;
    final primaryText =
        onTeal ? Colors.white : AppColors.textPrimary(brightness);
    final secondary = onTeal ? _tealMuted : AppColors.textSecondary(brightness);
    final inProgress = order.status == PoStatus.inProgress;
    final lines = order.lineItems.length;
    final linesStarted = order.receivedCount;
    final units = order.lineItems.fold<int>(0, (sum, i) => sum + i.expected);
    final progress = lines > 0 ? linesStarted / lines : 0.0;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final header = InkWell(
      onTap: switch (order.status) {
        PoStatus.inProgress => () => setState(() => _expanded = !_expanded),
        PoStatus.pending => _startReceive,
        PoStatus.received => () =>
            context.push(AppRoutes.receivingDetails, extra: order.id),
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.supplier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(color: primaryText),
                  ),
                ),
                const SizedBox(width: 8),
                _DateLabel(order: order, muted: secondary),
              ],
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: order.displayNumber,
                    style: AppTextStyles.code.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' · ${_plural(lines, 'line')} · ${_plural(units, 'unit')}',
                  ),
                ],
              ),
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                height: 1.4,
                color: secondary,
              ),
            ),
            if (inProgress) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                      backgroundColor:
                          onTeal ? _tealRule : _trackColor(brightness),
                      color: _accent(brightness),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$linesStarted of $lines lines',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      color: secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, size: 20, color: secondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    if (!inProgress) return header;

    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 200);
    return AnimatedContainer(
      duration: duration,
      color: onTeal ? AppColors.primary : Colors.transparent,
      // Ripples paint on this layer, above the teal, not on the card beneath it.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(expanded: _expanded, child: header),
            AnimatedSize(
              duration: duration,
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? _LinePreview(
                      order: order,
                      onTeal: onTeal,
                      onContinue: _startReceive,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  static String _plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
}

/// The first lines of an order being received, started ones first, then Continue receiving.
class _LinePreview extends StatelessWidget {
  static const _shown = 3;

  final PurchaseOrder order;
  final bool onTeal;
  final VoidCallback onContinue;

  const _LinePreview({
    required this.order,
    required this.onTeal,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final secondary = onTeal ? _tealMuted : AppColors.textSecondary(brightness);
    final idle = onTeal ? _tealIdle : secondary;
    final primaryText =
        onTeal ? Colors.white : AppColors.textPrimary(brightness);
    final lineStyle = AppTextStyles.body.copyWith(fontSize: 13, height: 1.4);
    final sorted = [
      ...order.lineItems.where((i) => i.received != null),
      ...order.lineItems.where((i) => i.received == null),
    ];
    final hidden = sorted.length - _shown;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            height: 1,
            color: onTeal
                ? _tealRule
                : brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.divider,
          ),
          const SizedBox(height: 12),
          for (final line in sorted.take(_shown))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  line.received != null
                      ? Icon(Icons.check,
                          size: 16,
                          color: _accent(brightness),
                          semanticLabel: 'Started')
                      : Icon(Icons.radio_button_unchecked,
                          size: 16, color: idle),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: lineStyle.copyWith(color: primaryText),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${line.received ?? 0} / ${line.expected}',
                    style: lineStyle.copyWith(color: secondary),
                  ),
                ],
              ),
            ),
          if (hidden > 0)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Text(
                'and $hidden more…',
                style: lineStyle.copyWith(color: secondary),
              ),
            ),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: onContinue,
            child: const Text('Continue receiving'),
          ),
        ],
      ),
    );
  }
}

/// Due or received date; only Due today and Overdue take a colour, as plain text with no fill.
class _DateLabel extends StatelessWidget {
  final PurchaseOrder order;
  final Color muted;

  const _DateLabel({required this.order, required this.muted});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final secondary = AppTextStyles.body.copyWith(
      fontSize: 13,
      height: 1.4,
      color: muted,
    );
    final urgent = secondary.copyWith(fontWeight: FontWeight.w600);

    if (order.status == PoStatus.received) {
      final at = order.receivedAt;
      return at == null
          ? const SizedBox.shrink()
          : Text('Received ${_date(at)}', style: secondary);
    }

    final due = order.dueDate;
    if (due == null) return Text('No due date', style: secondary);

    final days = DateUtils.dateOnly(due)
        .difference(DateUtils.dateOnly(DateTime.now()))
        .inDays;
    if (days < 0) {
      return Text('Overdue',
          style: urgent.copyWith(color: AppColors.errorText(brightness)));
    }
    if (days == 0) {
      return Text('Due today',
          style: urgent.copyWith(color: AppColors.warningText(brightness)));
    }
    if (days == 1) return Text('Due tomorrow', style: secondary);
    return Text('Due ${_date(due)}', style: secondary);
  }

  /// "22 Apr", with the year only when it is not this year.
  static String _date(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dayMonth = '${date.day} ${months[date.month - 1]}';
    return date.year == DateTime.now().year
        ? dayMonth
        : '$dayMonth ${date.year}';
  }
}

/// Placeholder rows shaped like the real ones while orders load.
class _PoListSkeleton extends StatelessWidget {
  const _PoListSkeleton();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bar = _trackColor(brightness);

    Widget block(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bar,
            borderRadius: BorderRadius.circular(4),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(brightness),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 4; i++)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    block(160, 14),
                    const SizedBox(height: 8),
                    block(220, 12),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadFailed({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load purchase orders.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary(brightness)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// Camera sheet for a PO barcode; closes with the first code it reads.
class _ScanPoSheet extends StatefulWidget {
  const _ScanPoSheet();

  @override
  State<_ScanPoSheet> createState() => _ScanPoSheetState();
}

class _ScanPoSheetState extends State<_ScanPoSheet> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan the PO barcode',
              style: AppTextStyles.title
                  .copyWith(color: AppColors.textPrimary(brightness)),
            ),
            const SizedBox(height: 12),
            ScannerPreviewPanel(
              collapsedHeight: 280,
              expandedHeight: 280,
              onDetect: (capture) {
                if (_done) return;
                final code = capture.barcodes
                    .map((b) => b.rawValue)
                    .whereType<String>()
                    .firstOrNull;
                if (code == null) return;
                _done = true;
                Navigator.of(context).pop(code);
              },
            ),
          ],
        ),
      ),
    );
  }
}
