import 'package:http/http.dart' as http;

void main() async {
  final base = 'https://sufar-rho.vercel.app/images/destinations/Cairo';
  final exts = ['.jpg', '.jpeg', '.png'];
  final names = ['cairo', 'Cairo', '1', 'image', 'photo', 'cover'];
  
  for (var name in names) {
    for (var ext in exts) {
      final url = '$base/$name$ext';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        print('FOUND: $url');
      }
    }
  }
}
