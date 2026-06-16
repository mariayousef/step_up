class ProgressData {
  final int overallProgress;
  final int speechProgress;
  final int bodyProgress;
  final String message;
  final String period;
  final List<ChartEntry> chart;

  const ProgressData({
    required this.overallProgress,
    required this.speechProgress,
    required this.bodyProgress,
    required this.message,
    required this.period,
    required this.chart,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    final chartList = (json['chart'] as List<dynamic>? ?? [])
        .map((e) => ChartEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProgressData(
      overallProgress: (json['overall_progress'] as num?)?.toInt() ?? 0,
      speechProgress: (json['speech_progress'] as num?)?.toInt() ?? 0,
      bodyProgress: (json['body_progress'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '',
      period: json['period'] as String? ?? 'week',
      chart: chartList,
    );
  }

  /// Empty default when no data is available yet
  static const ProgressData empty = ProgressData(
    overallProgress: 0,
    speechProgress: 0,
    bodyProgress: 0,
    message: '',
    period: 'week',
    chart: [],
  );
}

class ChartEntry {
  final String day;
  final String date;
  final int overall;
  final int speech;
  final int body;

  const ChartEntry({
    required this.day,
    required this.date,
    required this.overall,
    required this.speech,
    required this.body,
  });

  factory ChartEntry.fromJson(Map<String, dynamic> json) {
    return ChartEntry(
      day: json['day'] as String? ?? '',
      date: json['date'] as String? ?? '',
      overall: (json['overall'] as num?)?.toInt() ?? 0,
      speech: (json['speech'] as num?)?.toInt() ?? 0,
      body: (json['body'] as num?)?.toInt() ?? 0,
    );
  }
}
