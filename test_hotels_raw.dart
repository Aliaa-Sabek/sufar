import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final url = 'http://sufar-rho.vercel.app/api/hotels?limit=5';
  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      File('backend_hotels_response.json').writeAsStringSync(res.body);
      print('Saved!');
    } else {
      print('Status: ${res.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
