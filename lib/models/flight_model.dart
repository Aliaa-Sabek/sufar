class FlightModel {
  final int flightId;
  final String flightNumber;
  final String airline;
  final String originCity;
  final String originCode;
  final String destinationCity;
  final String destinationCode;
  final DateTime? departureDatetime;
  final DateTime? arrivalDatetime;
  final int durationMinutes;
  final String flightType;
  final String airlineClass;
  final String aircraftType;
  final double priceEGP;
  final int seatsTotal;
  final int seatsAvailable;
  final String status;
  final int baggageAllowanceKg;
  final bool mealIncluded;
  final String terminal;

  FlightModel({
    required this.flightId,
    required this.flightNumber,
    required this.airline,
    required this.originCity,
    required this.originCode,
    required this.destinationCity,
    required this.destinationCode,
    required this.departureDatetime,
    required this.arrivalDatetime,
    required this.durationMinutes,
    required this.flightType,
    required this.airlineClass,
    required this.aircraftType,
    required this.priceEGP,
    required this.seatsTotal,
    required this.seatsAvailable,
    required this.status,
    required this.baggageAllowanceKg,
    required this.mealIncluded,
    required this.terminal,
  });

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return false;
    if (value is int || value is num) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      flightId: _toInt(json['flight_id'] ?? json['id']),
      flightNumber: (json['flight_number'] ?? '').toString(),
      airline: (json['airline'] ?? '').toString(),
      originCity: (json['origin_city'] ?? '').toString(),
      originCode: (json['origin_code'] ?? '').toString(),
      destinationCity: (json['destination_city'] ?? '').toString(),
      destinationCode: (json['destination_code'] ?? '').toString(),
      departureDatetime: _toDateTime(json['departure_datetime']),
      arrivalDatetime: _toDateTime(json['arrival_datetime']),
      durationMinutes: _toInt(json['duration_minutes']),
      flightType: (json['flight_type'] ?? '').toString(),
      airlineClass: (json['airline_class'] ?? '').toString(),
      aircraftType: (json['aircraft_type'] ?? '').toString(),
      priceEGP: _toDouble(json['price_EGP'] ?? json['price_egp']),
      seatsTotal: _toInt(json['seats_total']),
      seatsAvailable: _toInt(json['seats_available']),
      status: (json['status'] ?? '').toString(),
      baggageAllowanceKg: _toInt(json['baggage_allowance_kg']),
      mealIncluded: _toBool(json['meal_included']),
      terminal: (json['terminal'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flight_id': flightId,
      'flight_number': flightNumber,
      'airline': airline,
      'origin_city': originCity,
      'origin_code': originCode,
      'destination_city': destinationCity,
      'destination_code': destinationCode,
      'departure_datetime': departureDatetime?.toIso8601String(),
      'arrival_datetime': arrivalDatetime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'flight_type': flightType,
      'airline_class': airlineClass,
      'aircraft_type': aircraftType,
      'price_EGP': priceEGP,
      'seats_total': seatsTotal,
      'seats_available': seatsAvailable,
      'status': status,
      'baggage_allowance_kg': baggageAllowanceKg,
      'meal_included': mealIncluded,
      'terminal': terminal,
    };
  }
}
