import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final endpoints = ['/hotels', '/destinations', '/flights', '/travel-offices'];
  for (var ep in endpoints) {
    try {
      final res = await http.get(Uri.parse('https://sufar-rho.vercel.app/api' + ep));
      print('Endpoint: ' + ep + ' -> Status: ' + res.statusCode.toString());
      if (res.statusCode == 200) {
        final body = res.body;
        if (body.contains('EgyptAir') || body.contains('office') || body.contains('Airline') || body.contains('Emirates')) {
           print('FOUND OFFICE IN ' + ep);
        }
        print('Sample from ' + ep + ': ' + body.substring(0, body.length < 200 ? body.length : 200));
      }
    } catch(e) {
      print(e);
    }
  }
}
