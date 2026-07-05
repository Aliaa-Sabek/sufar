void main() {
  var path = 'cairo/hyatt/rooms/room1.jpg';
  var p = path;
  final parts = p.split('/');
  if (parts.length >= 3) {
    p = '${parts[1]}/general/${parts[2]}';
  } else if (parts.length == 2 && !parts[1].contains('general')) {
    p = '${parts[0]}/general/${parts[1]}';
  }
  print(p);
}
