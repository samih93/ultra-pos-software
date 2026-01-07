import 'dart:convert';

class OpeningHoursModel {
  final String day; // "monday", "tuesday", etc.
  final String openAt; // "10:00"
  final String closeAt; // "23:30"
  final bool isClosed; // true for closed days (like Sunday)

  OpeningHoursModel({
    required this.day,
    required this.openAt,
    required this.closeAt,
    required this.isClosed,
  });

  factory OpeningHoursModel.fromJson(Map<String, dynamic> json) {
    return OpeningHoursModel(
      day: json['day'] ?? "",
      openAt: json['openAt'] ?? '',
      closeAt: json['closeAt'] ?? '',
      isClosed: json['isClosed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'openAt': openAt,
      'closeAt': closeAt,
      'isClosed': isClosed,
    };
  }

  OpeningHoursModel copyWith({
    String? day,
    String? openAt,
    String? closeAt,
    bool? isClosed,
  }) {
    return OpeningHoursModel(
      day: day ?? this.day,
      openAt: openAt ?? this.openAt,
      closeAt: closeAt ?? this.closeAt,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  // Helper to parse list from JSON string
  static List<OpeningHoursModel> parseList(dynamic jsonString) {
    if (jsonString == null) {
      print('Opening hours is null, using default');
      return getDefaultHours();
    }

    try {
      // Handle if it's already a List (from local DB)
      if (jsonString is List) {
        return jsonString
            .map((json) => OpeningHoursModel.fromJson(json))
            .toList();
      }

      // Handle if it's a String (from server)
      if (jsonString is String) {
        if (jsonString.isEmpty) {
          print('Opening hours is empty string, using default');
          return getDefaultHours();
        }
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((json) => OpeningHoursModel.fromJson(json)).toList();
      }

      print('Opening hours unexpected type: ${jsonString.runtimeType}');
      return getDefaultHours();
    } catch (e, stackTrace) {
      print('Error parsing opening hours: $e');
      print('Stack trace: $stackTrace');
      print('Input was: $jsonString');
      return getDefaultHours();
    }
  }

  // Helper to encode list to JSON string
  static String encodeList(List<OpeningHoursModel> hours) {
    return jsonEncode(hours.map((h) => h.toJson()).toList());
  }

  // Default hours
  static List<OpeningHoursModel> getDefaultHours() {
    return [
      OpeningHoursModel(
        day: 'monday',
        openAt: '10:00',
        closeAt: '00:00',
        isClosed: false,
      ),
      OpeningHoursModel(
        day: 'tuesday',
        openAt: '10:00',
        closeAt: '00:00',
        isClosed: false,
      ),
      OpeningHoursModel(
        day: 'wednesday',
        openAt: '10:00',
        closeAt: '00:00',
        isClosed: false,
      ),
      OpeningHoursModel(
        day: 'thursday',
        openAt: '10:00',
        closeAt: '00:00',
        isClosed: false,
      ),
      OpeningHoursModel(
        day: 'friday',
        openAt: '10:00',
        closeAt: '00:00',
        isClosed: false,
      ),
      OpeningHoursModel(
        day: 'saturday',
        openAt: '10:00',
        closeAt: '00:00',
        isClosed: false,
      ),
      OpeningHoursModel(
        day: 'sunday',
        openAt: '10:00',
        closeAt: '00:00',
        isClosed: false,
      ),
    ];
  }
}
