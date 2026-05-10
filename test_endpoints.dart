import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final endpoints = ['/travel-offices', '/offices', '/travelOffices', '/travel_offices'];
  
  for (var ep in endpoints) {
    try {
      final res = await http.get(Uri.parse('https://sufar-rho.vercel.app/api' + ep));
      print('Endpoint: ' + ep + ' -> Status: ' + res.statusCode.toString());
      if (res.statusCode == 200) {
         print(res.body.substring(0, res.body.length < 100 ? res.body.length : 100));
      }
    } catch(e) {
      print(e);
    }
  }
}
