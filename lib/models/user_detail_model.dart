// models/user_detail_model.dart
class UserDetail {
  final String id;
  final String name;
  final String email;
  final String role;
  final UserProfile profile;
  final int? currentCycleNumber;
  final List<CycleHistory> cycleHistory;
  final String createdAt;
  final String updatedAt;

  UserDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.profile,
    this.currentCycleNumber,
    required this.cycleHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profile: UserProfile.fromJson(json['profile']),
      currentCycleNumber: json['current_cycle_number'],
      cycleHistory: List<CycleHistory>.from(
          json['cycle_history'].map((x) => CycleHistory.fromJson(x))),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class UserProfile {
  final String phone;
  final String birthdate;
  final int heightCm;
  final double weightKg;
  final double bmi;
  final String lastEducation;
  final String lastParentEducation;
  final String lastParentJob;
  final String internetAccess;
  final int firstMenstruation;
  final String address;
  final String updatedAt;

  UserProfile({
    required this.phone,
    required this.birthdate,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.lastEducation,
    required this.lastParentEducation,
    required this.lastParentJob,
    required this.internetAccess,
    required this.firstMenstruation,
    required this.address,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      phone: json['phone'],
      birthdate: json['birthdate'],
      heightCm: json['height_cm'],
      // weightKg: json['weight_kg'],
      weightKg: double.tryParse(json['weight_kg'].toString()) ?? 0.0,
      bmi: json['bmi'].toDouble(),
      lastEducation: json['last_education'],
      lastParentEducation: json['last_parent_education'],
      lastParentJob: json['last_parent_job'],
      internetAccess: json['internet_access'],
      firstMenstruation: json['first_menstruation'],
      address: json['address'],
      updatedAt: json['updated_at'],
    );
  }
}

class CycleHistory {
  final int id;
  final String startDate;
  final String finishDate;
  final double periodLengthDays;
  final double? cycleLengthDays;

  CycleHistory({
    required this.id,
    required this.startDate,
    required this.finishDate,
    required this.periodLengthDays,
    this.cycleLengthDays,
  });

  factory CycleHistory.fromJson(Map<String, dynamic> json) {
    return CycleHistory(
      id: json['id'],
      startDate: json['start_date'],
      finishDate: json['finish_date'],
      periodLengthDays: json['period_length_days']?.toDouble(),
      cycleLengthDays: json['cycle_length_days']?.toDouble(),
    );
  }
}
