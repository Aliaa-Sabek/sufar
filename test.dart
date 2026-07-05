import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://res.cloudinary.com/dgggctaxn/image/upload/sufar/destinations/cairo/cairo.jpg';
  try {
    final res = await http.get(Uri.parse(url));
    print('Status: ${res.statusCode}');
  } catch (e) {
    print('Error: $e');
  }
}
