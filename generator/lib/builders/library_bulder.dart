import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

class LibraryBuilder {
  final String path;
  String _imports = '';
  String _declarations = '';

  LibraryBuilder(String path, {String? relativeTo})
      : path = relativeTo != null ? join(dirname(relativeTo), path) : path;

  void import(String path) {
    if (path.startsWith('package') || !Uri.parse(path).isAbsolute) {
      _imports += 'import \'$path\';';
    } else {
      final import =
          relative(path, from: dirname(this.path)).replaceAll('\\', '/');
      _imports += 'import \'$import\';';
    }
  }

  void declare(String declaration) {
    _declarations += declaration;
  }

  String buildString() {
    return DartFormatter().format('$_imports\n\n$_declarations');
  }
}
