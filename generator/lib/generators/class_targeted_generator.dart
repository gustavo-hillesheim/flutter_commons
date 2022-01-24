import 'dart:io';

import 'package:code_generator/code_generator.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

import '../models/class.dart';
import '../models/field.dart';

abstract class ClassTargetedGenerator extends GeneratorForClass {
  final String target;
  final DartFormatter formatter = DartFormatter();

  ClassTargetedGenerator({required this.target});

  @override
  bool shouldGenerateFor(ClassDeclaration member, String path) {
    return super.shouldGenerateFor(member, path) && member.name.name == target;
  }

  Field findIdField(Class classObj) {
    return classObj.instanceFields.firstWhere(
        (f) => f.hasMetadata('Id') && f.type != null,
        orElse: () => throw Exception(
            'Could not find field annotated with @Id() in ${classObj.name}'));
  }

  String relativePath(String path, {required String from}) {
    return join(dirname(from), path);
  }

  String testPath(String library, {required String packageRoot}) {
    final relativeLibraryPath =
        relativeToLibPath(library, packageRoot: packageRoot);
    return join(
      packageRoot,
      'test',
      relativeLibraryPath.replaceAll('.dart', '') + '_test.dart',
    );
  }

  String relativeToLibPath(String library, {required String packageRoot}) {
    final libFolderPath = join(packageRoot, 'lib');
    return normalize(library)
        .replaceFirst('$libFolderPath$separator', '')
        .replaceAll('\\', '/');
  }

  String relativeImport(String library, {required String from}) {
    return relative(library, from: dirname(from)).replaceAll('\\', '/');
  }

  String packageImport(
    String library, {
    required String packageRoot,
    String? relativeTo,
  }) {
    final packageName = packageRoot.split(separator).last;
    if (relativeTo != null) {
      library = relativePath(library, from: relativeTo);
    }
    final libraryPath = relativeToLibPath(library, packageRoot: packageRoot);
    return 'package:$packageName/$libraryPath';
  }

  String format(String code) => formatter.format(code);

  String getPackageRoot(String path) {
    FileSystemEntity entity = File(path);
    while (entity.parent != entity) {
      final parent = entity.parent;
      for (final file in parent.listSync()) {
        if (file is File && file.path.endsWith('pubspec.yaml')) {
          return parent.absolute.path;
        }
      }
      entity = parent;
    }
    throw Exception('Could not find package root');
  }
}
