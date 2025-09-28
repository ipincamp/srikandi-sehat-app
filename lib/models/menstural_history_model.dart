class MenstrualCycle {
  final int id;
  final DateTime startDate;
  final DateTime finishDate;
  final int periodLength;
  final int? cycleLength;
  final bool isPeriodNormal;
  final bool? isCycleNormal;

  MenstrualCycle({
    required this.id,
    required this.startDate,
    required this.finishDate,
    required this.periodLength,
    this.cycleLength,
    required this.isPeriodNormal,
    this.isCycleNormal,
  });

  factory MenstrualCycle.fromJson(Map<String, dynamic> json) {
    return MenstrualCycle(
      id: json['id'],
      startDate: DateTime.parse(json['start_date']),
      finishDate: DateTime.parse(json['finish_date']),
      periodLength: json['period_length'],
      cycleLength: json['cycle_length'],
      isPeriodNormal: json['is_period_normal'],
      isCycleNormal: json['is_cycle_normal'],
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
      limit: json['limit'],
      totalData: json['total_data'],
      totalPages: json['total_pages'],
      currentPage: json['current_page'],
    );
  }
}
