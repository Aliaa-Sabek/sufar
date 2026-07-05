import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('assets/destinations_data.json');
  final content = await file.readAsString();
  final List<dynamic> data = jsonDecode(content);

  final githubBase = 'https://raw.githubusercontent.com/Nada-Khaled21/Sufar/main/Images/destinations';

  final map = {
    'Cairo': 'cairo/27.jpg',
    'Alexandria': 'alexandria/62.png',
    'Hurghada': 'hurghada/0.jpg',
    'Sharm El Sheikh': 'sharm-el-sheikh/54.jpg',
    'Luxor': 'luxor/image.png',
    'Aswan': 'aswan/0.jpg',
    'Riyadh': 'riyadh/image.png',
    'Jeddah': 'jeddah/2.jpg',
    'Makkah': 'makkah/1.jpg',
    'Al Madinah': 'al-madina/image.png',
    'Dubai': 'dubai/54.jpg',
    'Abu Dhabi': 'abu-dhabi/image.png',
    'Doha': 'doha/image.png',
    'Amman': 'amman/0.png',
    'Beirut': 'beirut/image.png',
    'Paris': 'paris/0.jpg',
    'Rome': 'rome/0.jpg',
    'Barcelona': 'barcelona/0.jpg',
    'London': 'london/0.png',
    'New York': 'new-york/0.png',
    'Los Angeles': 'los-angeles/0.png',
    'Istanbul': 'istanbul/9.jpg',
    'Tokyo': 'tokyo/38.jpg',
    'Maldives': 'maldives/29.jpg',
  };

  for (var city in data) {
    final name = city['name'];
    if (map.containsKey(name)) {
      city['image'] = '$githubBase/${map[name]}';
    }
  }

  final encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(data));
  print('Updated destinations_data.json with GitHub URLs');
}
