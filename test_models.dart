// ignore_for_file: avoid_print
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lib/models/destination_model.dart';
import 'lib/models/hotel_model.dart';
import 'lib/models/travel_office_model.dart';

void main() async {
  final url = 'https://iecxzdhjdjnjoivuhfmk.supabase.co/rest/v1';
  final key =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImllY3h6ZGhqZGpuam9pdnVoZm1rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1ODY5NTIsImV4cCI6MjA4ODE2Mjk1Mn0.Edprq_hJqIUxCSnjh7rJXmTWsrICRvDoVKQNT09RKBE';
  final headers = {'apikey': key, 'Authorization': 'Bearer $key'};

  final tables = ['destinations', 'hotels', 'travel_offices'];

  for (var t in tables) {
    print('\nTesting $t...');
    final res = await http.get(Uri.parse('$url/$t?select=*'), headers: headers);
    final list = jsonDecode(res.body);
    print('Length: ${list.length}');
    for (var json in list) {
      try {
        if (t == 'destinations') DestinationModel.fromJson(json);
        if (t == 'hotels') Hotel.fromJson(json);
        if (t == 'travel_offices') TravelOfficeModel.fromJson(json);
        print('Parsed $t item successfully.');
      } catch (e, s) {
        print('Error parsing $t: $e\n$s');
      }
    }
  }
}
