import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final url = 'https://sufar-rho.vercel.app/api/destinations';
  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      File('test_dest.json').writeAsStringSync(res.body);
      print('Saved test_dest.json');
    } else {
      print('Status: ${res.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
