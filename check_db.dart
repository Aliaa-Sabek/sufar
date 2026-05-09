// ignore_for_file: avoid_print
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://iecxzdhjdjnjoivuhfmk.supabase.co/rest/v1';
  final key =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImllY3h6ZGhqZGpuam9pdnVoZm1rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1ODY5NTIsImV4cCI6MjA4ODE2Mjk1Mn0.Edprq_hJqIUxCSnjh7rJXmTWsrICRvDoVKQNT09RKBE';

  final headers = {'apikey': key, 'Authorization': 'Bearer $key'};

  final tables = ['hotels', 'destinations', 'travel_offices'];

  for (var table in tables) {
    print('\n--- $table ---');
    final response = await http.get(
      Uri.parse('$url/$table?select=*'),
      headers: headers,
    );
    print('Status Code: ${response.statusCode}');
    print(response.body);
  }
}
