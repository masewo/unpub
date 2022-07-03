import 'dart:io';
import 'package:path/path.dart' as path;

var files = ['index.html', 'main.dart.js'];

main(List<String> args) {
  for (var file in files) {
    var content =
        File(path.absolute(path.join('..', 'unpub_web', 'build'), file))
            .readAsStringSync();
    content = content.replaceAll('\\', '\\\\').replaceAll('\$', '\\\$');
    content = 'const content = """$content""";\n';
    File(path.absolute(
            path.join('..', 'unpub', 'lib', 'src', 'static', '${file}.dart')))
        .writeAsStringSync(content);
  }
}
