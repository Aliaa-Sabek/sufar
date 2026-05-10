import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.get(Uri.parse('https://sufar-rho.vercel.app/api/travel-offices'));
  print(res.body);
}
