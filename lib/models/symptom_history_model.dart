// models/symptom_history_model.dart
class SymptomHistoryResponse {
  final bool status;
  final String message;
  final SymptomHistoryData data;

  SymptomHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SymptomHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SymptomHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: SymptomHistoryData.fromJson(json['data'] ?? {}),
    );
  }
}

class SymptomHistoryData {
  final List<Symptom> data;
  final Metadata metadata;

  SymptomHistoryData({required this.data, required this.metadata});

  factory SymptomHistoryData.fromJson(Map<String, dynamic> json) {
    return SymptomHistoryData(
      data: List<Symptom>.from(
        (json['data'] ?? []).map((x) => Symptom.fromJson(x)),
      ),
      metadata: Metadata.fromJson(json['metadata'] ?? {}),
    );
  }
}

class Symptom {
  final int id;
  final int totalSymptoms;
  final DateTime logDate;

  Symptom({
    required this.id,
    required this.totalSymptoms,
    required this.logDate,
  });
factory Symptom.fromJson(Map<String, dynamic> json) {
  final rawDate = json['log_date'] ?? '1970-01-01';
  
  // Parse sebagai local time
  final parsedDate = DateTime.parse(rawDate).toLocal();

  return Symptom(
    id: json['id'] ?? 0,
    totalSymptoms: json['total_symptoms'] ?? 0,
    logDate: parsedDate,
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
