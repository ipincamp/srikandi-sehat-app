class MenstrualCycleDetail {
  final int id;
  final DateTime startDate;
  final DateTime finishDate;
  final int periodLength;
  final int? cycleLength;
  final bool isPeriodNormal;
  final bool? isCycleNormal;

  MenstrualCycleDetail({
    required this.id,
    required this.startDate,
    required this.finishDate,
    required this.periodLength,
    this.cycleLength,
    required this.isPeriodNormal,
    this.isCycleNormal,
  });

  factory MenstrualCycleDetail.fromJson(Map<String, dynamic> json) {
    return MenstrualCycleDetail(
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

class MenstrualCycleDetailMetadata {
  final int limit;
  final int totalData;
  final int totalPages;
  final int currentPage;

  MenstrualCycleDetailMetadata({
    required this.limit,
    required this.totalData,
    required this.totalPages,
    required this.currentPage,
  });

  factory MenstrualCycleDetailMetadata.fromJson(Map<String, dynamic> json) {
    return MenstrualCycleDetailMetadata(
      limit: json['limit'],
      totalData: json['total_data'],
      totalPages: json['total_pages'],
      currentPage: json['current_page'],
    );
  }
}

class MenstrualCycleDetailResponse {
  final List<MenstrualCycleDetail> cycles;
  final MenstrualCycleDetailMetadata metadata;

  MenstrualCycleDetailResponse({required this.cycles, required this.metadata});

  factory MenstrualCycleDetailResponse.fromJson(Map<String, dynamic> json) {
    return MenstrualCycleDetailResponse(
      cycles: (json['data'] as List)
          .map((cycle) => MenstrualCycleDetail.fromJson(cycle))
          .toList(),
      metadata: MenstrualCycleDetailMetadata.fromJson(json['metadata']),
    );
  }
}
