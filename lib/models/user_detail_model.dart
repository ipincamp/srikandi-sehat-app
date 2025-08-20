class UserDetail {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool profileComplete;
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
    required this.profileComplete,
    required this.profile,
    this.currentCycleNumber,
    required this.cycleHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      profileComplete: json['profile_complete'] ?? false,
      profile: UserProfile.fromJson(json['profile'] ?? {}),
      currentCycleNumber: json['current_cycle_number'],
      cycleHistory: json['cycle_history'] != null
          ? List<CycleHistory>.from(
              json['cycle_history'].map((x) => CycleHistory.fromJson(x ?? {})),
            )
          : <CycleHistory>[],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class UserProfile {
  final String phone;
  final String birthdate;
  final int heightCm;
  final int weightKg;
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
      phone: json['phone'] ?? '-',
      birthdate: json['birthdate'] ?? '',
      heightCm: json['tb_cm'] ?? 0,
      weightKg: json['bb_kg'] ?? 0,
      bmi: (json['bmi'] ?? 0).toDouble(),
      lastEducation: json['edu_now'] ?? '-',
      lastParentEducation: json['edu_parent'] ?? '-',
      lastParentJob: json['job_parent'] ?? '-',
      internetAccess: json['inet_access'] ?? '-',
      firstMenstruation: json['first_haid'] ?? 0,
      address: json['address'] ?? '-',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class CycleHistory {
  final int id;
  final DateTime startDate;
  final DateTime finishDate;
  final int periodLengthDays;
  final int? cycleLengthDays;

  CycleHistory({
    required this.id,
    required this.startDate,
    required this.finishDate,
    required this.periodLengthDays,
    this.cycleLengthDays,
  });

  factory CycleHistory.fromJson(Map<String, dynamic> json) {
    return CycleHistory(
      id: json['id'] ?? 0,
      startDate: DateTime.parse(json['start_date'] ?? ''),
      finishDate: DateTime.parse(json['finish_date'] ?? ''),
      periodLengthDays: json['period_length_days'] ?? 0,
      cycleLengthDays: json['cycle_length_days'],
    );
  }
}
