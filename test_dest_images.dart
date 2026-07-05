import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = 'https://sufar-rho.vercel.app/api/destinations?limit=50';
  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final destinations = data['destinations'] as List;
      for (final d in destinations) {
        print('${d['name']}: ${d['image']}');
      }
    } else {
      print('Error: ${res.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
