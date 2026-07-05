import 'package:http/http.dart' as http;

void main() async {
  // Original url: https://res.cloudinary.com/dgggctaxn/image/upload/v1778365907/sufar/hotels/steigenberger-el-tahrir/general/12.jpg
  // Try changing general to rooms and see if we get 200
  final baseUrl = 'https://res.cloudinary.com/dgggctaxn/image/upload/sufar/hotels/steigenberger-el-tahrir/rooms';
  
  for (int i = 0; i < 20; i++) {
    final url = '$baseUrl/$i.jpg';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        print('FOUND: $url');
      }
    } catch (e) {
      // ignore
    }
  }
}
