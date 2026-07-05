import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = 'https://sufar-rho.vercel.app/api/hotels?limit=3';
  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final hotels = data['hotels'] as List;
      for (final h in hotels) {
        print('${h['name']}');
        for (var img in h['images'] ?? []) {
          print('  - $img');
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
