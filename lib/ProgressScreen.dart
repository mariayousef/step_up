import 'dart:math';
import 'package:flutter/material.dart';
import 'package:step_up/app_colors.dart';
import 'package:step_up/models/progress_model.dart';
import 'package:step_up/services/progress_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  MAIN SCREEN  –  wraps ProgressScreen inside a PageView with bottom nav
//  (keeping existing behaviour intact)
// ═══════════════════════════════════════════════════════════════════════════════

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 2);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          Center(child: Text("Home Screen")),
          Center(child: Text("Location Screen")),
          ProgressScreen(),
          Center(child: Text("Profile Screen")),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: "Location",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: "Progress",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PROGRESS SCREEN  –  fetches real data from backend
// ═══════════════════════════════════════════════════════════════════════════════

class ProgressScreen extends StatefulWidget {
  final String? parentId;
  final bool isEmbedded;

  const ProgressScreen({super.key, this.parentId, this.isEmbedded = false});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'week';
  ProgressData? _data;
  bool _isLoading = true;
  String? _error;

  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _fetchProgress();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchProgress() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ProgressService.getProgress(_selectedPeriod, parentId: widget.parentId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
      _animController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changePeriod(String period) {
    if (period == _selectedPeriod) return;
    setState(() => _selectedPeriod = period);
    _fetchProgress();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _isLoading
        ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 4,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading progress...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        : _error != null
            ? _buildError()
            : ListenableBuilder(
                listenable: _animController,
                builder: (context, _) => _buildContent(),
              );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      appBar: Navigator.canPop(context) 
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textMain),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProgress,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final data = _data ?? ProgressData.empty;
    final animVal = _progressAnim.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          'Progress 📊',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        if (data.message.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            data.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 24),

        // ── Overall Progress Circle ──────────────────────────────────────
        _OverallCircle(
          percentage: (data.overallProgress * animVal).round(),
          targetPercentage: data.overallProgress,
          animValue: animVal,
        ),
        const SizedBox(height: 28),

        // ── Speech & Body bars ───────────────────────────────────────────
        _ProgressBar(
          label: 'Speech Training',
          emoji: '🗣️',
          value: data.speechProgress,
          animValue: animVal,
          color: const Color(0xFF4E8AFF),
        ),
        const SizedBox(height: 16),
        _ProgressBar(
          label: 'Body Training',
          emoji: '💪',
          value: data.bodyProgress,
          animValue: animVal,
          color: const Color(0xFFFF9F43),
        ),
        const SizedBox(height: 28),

        // ── Period Toggle ────────────────────────────────────────────────
        _PeriodToggle(
          selected: _selectedPeriod,
          onChanged: _changePeriod,
        ),
        const SizedBox(height: 24),

        // ── Chart ────────────────────────────────────────────────────────
        _ChartCard(
          chart: data.chart,
          period: _selectedPeriod,
          animValue: animVal,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😢', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Could not load progress!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _fetchProgress,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  OVERALL CIRCULAR PROGRESS
// ═══════════════════════════════════════════════════════════════════════════════

class _OverallCircle extends StatelessWidget {
  final int percentage;
  final int targetPercentage;
  final double animValue;

  const _OverallCircle({
    required this.percentage,
    required this.targetPercentage,
    required this.animValue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [AppColors.softShadow],
        ),
        child: Column(
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _CircleProgressPainter(
                  progress: (targetPercentage / 100.0) * animValue,
                  trackColor: AppColors.outline,
                  progressColor: AppColors.primary,
                  strokeWidth: 14,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      const Text(
                        'Overall',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    if (sweepAngle > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -pi / 2, // Start from top
        sweepAngle,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: -pi / 2,
            endAngle: 3 * pi / 2,
            colors: [
              progressColor,
              progressColor.withValues(alpha: 0.7),
              progressColor,
            ],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter old) =>
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PROGRESS BAR ROW
// ═══════════════════════════════════════════════════════════════════════════════

class _ProgressBar extends StatelessWidget {
  final String label;
  final String emoji;
  final int value;
  final double animValue;
  final Color color;

  const _ProgressBar({
    required this.label,
    required this.emoji,
    required this.value,
    required this.animValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = (value * animValue).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              Text(
                '$displayValue%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (value / 100.0 * animValue).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PERIOD TOGGLE  (Week / Month / Year)
// ═══════════════════════════════════════════════════════════════════════════════

class _PeriodToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _PeriodToggle({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Row(
        children: [
          _buildTab('week', 'Week'),
          _buildTab('month', 'Month'),
          _buildTab('year', 'Year'),
        ],
      ),
    );
  }

  Widget _buildTab(String period, String label) {
    final isSelected = selected == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  CHART CARD  –  grouped bar chart using CustomPainter
// ═══════════════════════════════════════════════════════════════════════════════

class _ChartCard extends StatelessWidget {
  final List<ChartEntry> chart;
  final String period;
  final double animValue;

  const _ChartCard({
    required this.chart,
    required this.period,
    required this.animValue,
  });

  String get _periodLabel {
    switch (period) {
      case 'month':
        return 'Monthly';
      case 'year':
        return 'Yearly';
      default:
        return 'Weekly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_periodLabel Progress',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _LegendDot(color: AppColors.primary, label: 'Overall'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFF4E8AFF), label: 'Speech'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFFF9F43), label: 'Body'),
            ],
          ),
          const SizedBox(height: 16),
          chart.isEmpty
              ? SizedBox(
                  height: 180,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('📭', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 8),
                        Text(
                          'No data yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 200,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _BarChartPainter(
                      entries: chart,
                      animValue: animValue,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  BAR CHART PAINTER
// ═══════════════════════════════════════════════════════════════════════════════

class _BarChartPainter extends CustomPainter {
  final List<ChartEntry> entries;
  final double animValue;

  static const Color _overallColor = AppColors.primary;
  static const Color _speechColor = Color(0xFF4E8AFF);
  static const Color _bodyColor = Color(0xFFFF9F43);

  _BarChartPainter({required this.entries, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    const double bottomPadding = 28; // space for labels
    const double topPadding = 8;
    final double chartH = size.height - bottomPadding - topPadding;
    final int n = entries.length;
    final double groupWidth = size.width / n;

    // Dynamic bar width based on available space
    // Each group has 3 bars + 2 gaps. We want bars to fill ~60% of groupWidth.
    final double maxBarWidth = (groupWidth * 0.6) / 3;
    final double barWidth = maxBarWidth.clamp(3.0, 10.0);
    final double barGap = (barWidth * 0.35).clamp(1.0, 4.0);
    final double totalBarsWidth = barWidth * 3 + barGap * 2;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE8ECF0)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = topPadding + chartH * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Decide how many labels to skip to avoid overlap
    // Measure a typical label to see how much space it needs
    final textStyle = TextStyle(
      color: AppColors.textSecondary.withValues(alpha: 0.8),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    final sampleTp = TextPainter(
      text: TextSpan(text: 'Wed', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelWidth = sampleTp.width + 6; // plus some spacing
    final int labelStep = (labelWidth / groupWidth).ceil().clamp(1, n);

    for (int i = 0; i < n; i++) {
      final entry = entries[i];
      final cx = groupWidth * i + groupWidth / 2;
      final startX = cx - totalBarsWidth / 2;

      // Draw 3 bars: overall, speech, body
      _drawBar(canvas, startX, entry.overall, _overallColor, chartH,
          topPadding, barWidth);
      _drawBar(canvas, startX + barWidth + barGap, entry.speech, _speechColor,
          chartH, topPadding, barWidth);
      _drawBar(canvas, startX + (barWidth + barGap) * 2, entry.body,
          _bodyColor, chartH, topPadding, barWidth);

      // Only draw label every labelStep entries to avoid overlap
      if (i % labelStep == 0) {
        final tp = TextPainter(
          text: TextSpan(text: entry.day, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(cx - tp.width / 2, size.height - bottomPadding + 8),
        );
      }
    }
  }

  void _drawBar(Canvas canvas, double x, int value, Color color,
      double chartH, double topPadding, double barWidth) {
    final barH = (value / 100.0).clamp(0.0, 1.0) * chartH * animValue;
    if (barH <= 0) return;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        x,
        topPadding + chartH - barH,
        barWidth,
        barH,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(
      rect,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.animValue != animValue || old.entries != entries;
}