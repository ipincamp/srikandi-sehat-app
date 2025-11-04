class MenstrualCycle {
  final int id;
  final DateTime startDate;
  final DateTime finishDate;
  final int periodLength;
  final int? cycleLength;
  final bool isPeriodNormal;
  final bool? isCycleNormal;
  final bool? isDeleted;
  final String? deletionReason;
  final DateTime? deletedAt;

  MenstrualCycle({
    required this.id,
    required this.startDate,
    required this.finishDate,
    required this.periodLength,
    this.cycleLength,
    required this.isPeriodNormal,
    this.isCycleNormal,
    this.isDeleted,
    this.deletionReason,
    this.deletedAt,
  });

  factory MenstrualCycle.fromJson(Map<String, dynamic> json) {
    DateTime safeParseDate(dynamic dateString) {
      if (dateString == null) {
        // Jika tanggal null (misal siklus aktif),
        // gunakan tanggal hari ini sebagai fallback
        return DateTime.now();
      }
      try {
        // Konversi ke string dulu untuk keamanan ekstra
        return DateTime.parse(dateString.toString());
      } catch (e) {
        // Fallback jika format tanggal tidak valid
        return DateTime.now();
      }
    }

    return MenstrualCycle(
      id: json['id'] ?? 0,
      startDate: safeParseDate(json['start_date']),
      finishDate: safeParseDate(json['finish_date']),
      periodLength: json['period_length'] ?? 0,
      cycleLength: json['cycle_length'],
      isPeriodNormal: json['is_period_normal'] ?? false,
      isCycleNormal: json['is_cycle_normal'],
      isDeleted: json.containsKey('is_deleted') ? json['is_deleted'] : null,
      deletionReason: json.containsKey('deletion_reason')
          ? json['deletion_reason']
          : null,
      deletedAt: json.containsKey('deleted_at') && json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }
}

class MenstrualCycleResponse {
  final List<MenstrualCycle> cycles;
  final Metadata metadata;

  MenstrualCycleResponse({required this.cycles, required this.metadata});

  factory MenstrualCycleResponse.fromJson(Map<String, dynamic> json) {
    return MenstrualCycleResponse(
      cycles: (json['data'] as List)
          .map((cycle) => MenstrualCycle.fromJson(cycle))
          .toList(),
      metadata: Metadata.fromJson(json['metadata']),
    );
  }
}

class Metadata {
  final int limit;
  final int totalData;
  final int totalPages;
  final int currentPage;

  Metadata({
    required this.limit,
    required this.totalData,
    required this.totalPages,
    required this.currentPage,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      limit: json['limit'] ?? 10,
      totalData: json['total_data'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      currentPage: json['current_page'] ?? 1,
    );
  }
}
