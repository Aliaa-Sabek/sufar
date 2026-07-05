import 'package:http/http.dart' as http;

void main() async {
  final bases = [
    'https://res.cloudinary.com/dgggctaxn/image/upload/sufar/images/destinations',
    'https://res.cloudinary.com/dgggctaxn/image/upload/images/destinations',
    'https://res.cloudinary.com/dgggctaxn/image/upload/destinations',
    'https://res.cloudinary.com/dgggctaxn/image/upload/sufar/destinations',
  ];
  final cities = ['Cairo', 'cairo'];
  final names = ['cairo', 'Cairo', '1', 'image'];
  final exts = ['.jpg', '.jpeg', '.png'];
  
  for (var base in bases) {
    for (var city in cities) {
      for (var name in names) {
        for (var ext in exts) {
          final url = '$base/$city/$name$ext';
          try {
            final res = await http.get(Uri.parse(url)).timeout(Duration(seconds: 2));
            if (res.statusCode == 200) {
              print('FOUND: $url');
              return;
            }
          } catch (e) {
            // ignore
          }
        }
      }
    }
  }
  print('None found.');
}
