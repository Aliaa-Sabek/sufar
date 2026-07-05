import 'package:http/http.dart' as http;

void main() async {
  final base = 'https://sufar-rho.vercel.app/images/destinations/Cairo';
  final exts = ['.jpg', '.jpeg', '.png'];
  final names = ['cairo', 'Cairo', '1', 'image', 'photo', 'cover', 'hero'];
  
  for (var name in names) {
    for (var ext in exts) {
      final url = '$base/$name$ext';
      try {
        final res = await http.get(Uri.parse(url)).timeout(Duration(seconds: 3));
        if (res.statusCode == 200) {
          print('FOUND: $url');
        } else {
          print('Not found: $url (${res.statusCode})');
        }
      } catch (e) {
        print('Error $url: $e');
      }
    }
  }
}
