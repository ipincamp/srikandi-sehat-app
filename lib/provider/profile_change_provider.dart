import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileChangeProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  SharedPreferences? _prefs;

  // User data fields
  String? _id;
  String? _name;
  String? _email;
  String? _role;
  bool _profileComplete = false;

  // Profile fields
  String? _phone;
  String? _dob;
  String? _districtCode;
  String? _villageCode;
  String? _eduNow;
  String? _eduParent;
  String? _internetAccess;
  String? _firstHaid;
  String? _jobParent;
  int? _height;
  double? _weight;
  double? _bmi;
  String? _districtName;
  String? _villageName;
  String? _address;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get name => _name;
  String? get phone => _phone;
  String? get dob => _dob;
  int? get height => _height;
  double? get weight => _weight;
  String? get districtCode => _districtCode;
  String? get villageCode => _villageCode;
  String? get eduNow => _eduNow;
  String? get eduParent => _eduParent;
  String? get internetAccess => _internetAccess;
  String? get firstHaid => _firstHaid;
  String? get jobParent => _jobParent;
  String? get districtName => _districtName;
  String? get villageName => _villageName;
  String? get address => _address;
  bool get profileComplete => _profileComplete;

  // Expose complete user data
  Map<String, dynamic> get userData {
    return {
      'id': _id,
      'name': _name,
      'email': _email,
      'role': _role,
      'profile_complete': _profileComplete,
      'profile': {
        'phone': _phone,
        'birthdate': _dob,
        'tb_cm': _height,
        'bb_kg': _weight,
        'bmi': _bmi,
        'edu_now': _eduNow,
        'edu_parent': _eduParent,
        'job_parent': _jobParent,
        'inet_access': _internetAccess,
        'first_haid': _firstHaid,
        'address': _address,
        'address_code': _villageCode,
      },
    };
  }

  // Parse profile data from API response
  void _parseProfileData(Map<String, dynamic> userData) {
    try {
      _id = userData['id']?.toString();
      _name = userData['name']?.toString();
      _email = userData['email']?.toString();
      _role = userData['role']?.toString();
      _profileComplete = userData['profile_complete'] == true;

      final profile = userData['profile'] ?? {};
      _phone = profile['phone']?.toString();
      _dob = profile['birthdate']?.toString();
      _height = profile['tb_cm'] is int
          ? profile['tb_cm']
          : int.tryParse(profile['tb_cm']?.toString() ?? '');
      _weight = profile['bb_kg'] is double
          ? profile['bb_kg']
          : double.tryParse(profile['bb_kg']?.toString() ?? '');
      _bmi = profile['bmi'] is double
          ? profile['bmi']
          : double.tryParse(profile['bmi']?.toString() ?? '');
      _eduNow = profile['edu_now']?.toString();
      _eduParent = profile['edu_parent']?.toString();
      _internetAccess = profile['inet_access']?.toString();
      _firstHaid = profile['first_haid']?.toString();
      _jobParent = profile['job_parent']?.toString();
      _address = profile['address']?.toString();
      _villageCode = profile['address_code']?.toString();
    } catch (e) {
      _errorMessage = 'Failed to parse profile data';
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await init(); // Ensure prefs is initialized
      final token = _prefs?.getString('token');

      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found';
        return false;
      }

      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = '$baseUrl/me/details';

      final cleanedData = <String, dynamic>{};

      // Handle each field with proper type conversion
      if (profileData['name'] != null &&
          profileData['name'].toString().isNotEmpty) {
        cleanedData['name'] = profileData['name'].toString();
      }

      if (profileData['phone'] != null &&
          profileData['phone'].toString().isNotEmpty) {
        cleanedData['phone'] = profileData['phone'].toString();
      }

      if (profileData['address_code'] != null &&
          profileData['address_code'].toString().isNotEmpty) {
        cleanedData['address_code'] = profileData['address_code'].toString();
      }

      if (profileData['birthdate'] != null &&
          profileData['birthdate'].toString().isNotEmpty) {
        cleanedData['birthdate'] = profileData['birthdate'].toString();
      }

      if (profileData['tb_cm'] != null) {
        cleanedData['tb_cm'] =
            int.tryParse(profileData['tb_cm'].toString()) ?? 0;
      }

      if (profileData['bb_kg'] != null) {
        cleanedData['bb_kg'] =
            double.tryParse(profileData['bb_kg'].toString()) ?? 0.0;
      }

      if (profileData['edu_now'] != null &&
          profileData['edu_now'].toString().isNotEmpty) {
        cleanedData['edu_now'] = profileData['edu_now'].toString();
      }

      if (profileData['edu_parent'] != null &&
          profileData['edu_parent'].toString().isNotEmpty) {
        cleanedData['edu_parent'] = profileData['edu_parent'].toString();
      }

      if (profileData['inet_access'] != null &&
          profileData['inet_access'].toString().isNotEmpty) {
        cleanedData['inet_access'] = profileData['inet_access'].toString();
      }

      if (profileData['first_haid'] != null &&
          profileData['first_haid'].toString().isNotEmpty) {
        cleanedData['first_haid'] =
            int.tryParse(profileData['first_haid'].toString()) ?? 0;
      }

      if (profileData['job_parent'] != null &&
          profileData['job_parent'].toString().isNotEmpty) {
        cleanedData['job_parent'] = profileData['job_parent'].toString();
      }

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(cleanedData),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          _updateLocalProfile(cleanedData);
          await _prefs?.setBool('profile_complete', true);
          await _prefs?.setString('name', _name ?? '');
          return true;
        } catch (e) {
          _errorMessage = 'Failed to process server response';
          return false;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please login again.';
        return false;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _errorMessage =
              errorData['message'] ??
              'Failed to update profile (${response.statusCode})';
        } catch (e) {
          _errorMessage =
              'Failed to update profile (${response.statusCode}) - ${response.body}';
        }
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error occurred: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user profile
  Future<bool> fetchProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await init(); // Ensure prefs is initialized
      final token = _prefs?.getString('token');

      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found';
        return false;
      }

      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = '$baseUrl/me';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['data'] != null) {
            _parseProfileData(responseData['data']);
            return true;
          }

          _errorMessage = 'Profile data not found';
          return false;
        } catch (e) {
          _errorMessage = 'Failed to parse profile data';
          return false;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please login again.';
        return false;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _errorMessage =
              errorData['message'] ??
              'Failed to fetch profile (${response.statusCode})';
        } catch (e) {
          _errorMessage =
              'Failed to fetch profile (${response.statusCode}) - ${response.body}';
        }
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error occurred: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update local profile state
  void _updateLocalProfile(Map<String, dynamic> profileData) {
    try {
      if (profileData.containsKey('name')) {
        _name = profileData['name']?.toString();
      }
      if (profileData.containsKey('phone')) {
        _phone = profileData['phone']?.toString();
      }
      if (profileData.containsKey('birthdate')) {
        _dob = profileData['birthdate']?.toString();
      }
      if (profileData.containsKey('tb_cm')) {
        _height = profileData['tb_cm'] is int
            ? profileData['tb_cm']
            : int.tryParse(profileData['tb_cm']?.toString() ?? '');
      }
      if (profileData.containsKey('bb_kg')) {
        _weight = profileData['bb_kg'] is double
            ? profileData['bb_kg']
            : double.tryParse(profileData['bb_kg']?.toString() ?? '');
      }
      if (profileData.containsKey('address_code')) {
        _villageCode = profileData['address_code']?.toString();
      }
      if (profileData.containsKey('edu_now')) {
        _eduNow = profileData['edu_now']?.toString();
      }
      if (profileData.containsKey('edu_parent')) {
        _eduParent = profileData['edu_parent']?.toString();
      }
      if (profileData.containsKey('inet_access')) {
        _internetAccess = profileData['inet_access']?.toString();
      }
      if (profileData.containsKey('first_haid')) {
        _firstHaid = profileData['first_haid']?.toString();
      }
      if (profileData.containsKey('job_parent')) {
        _jobParent = profileData['job_parent']?.toString();
      }
    } catch (e) {
      _errorMessage = 'Error fetching local profile';
    }
  }

  // Setters for form updates
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setDob(String value) {
    _dob = value;
    notifyListeners();
  }

  void setHeight(String value) {
    _height = int.tryParse(value);
    notifyListeners();
  }

  void setWeight(String value) {
    _weight = double.tryParse(value);
    notifyListeners();
  }

  void setDistrictCode(String code) {
    _districtCode = code;
    notifyListeners();
  }

  void setDistrictName(String name) {
    _districtName = name;
    notifyListeners();
  }

  void setVillageCode(String code) {
    _villageCode = code;
    notifyListeners();
  }

  void setVillageName(String name) {
    _villageName = name;
    notifyListeners();
  }

  void setEduNow(String value) {
    _eduNow = value;
    notifyListeners();
  }

  void setEduParent(String value) {
    _eduParent = value;
    notifyListeners();
  }

  void setInternetAccess(String value) {
    _internetAccess = value;
    notifyListeners();
  }

  void setFirstHaid(String value) {
    _firstHaid = value;
    notifyListeners();
  }

  void setJobParent(String value) {
    _jobParent = value;
    notifyListeners();
  }
}
