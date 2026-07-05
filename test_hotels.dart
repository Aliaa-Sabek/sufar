import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = 'http://sufar-rho.vercel.app/api/hotels?limit=100';
  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final jsonResponse = jsonDecode(res.body);
      final hotels = jsonResponse['hotels'] as List;
      for (var hotel in hotels) {
        bool hasRooms = false;
        for (var img in hotel['images']) {
          if (img.toString().contains('rooms')) {
            hasRooms = true;
          }
        }
        if (hasRooms) {
          print('Hotel: ${hotel['name']} has rooms images!');
          for (var img in hotel['images']) {
            if (img.toString().contains('rooms')) {
              print('  $img');
            }
          }
        }
      }
      print('Done scanning ${hotels.length} hotels.');
    } else {
      print('Status: ${res.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
