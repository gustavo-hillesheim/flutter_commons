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

  String relativePath(String path1, String path2) {
    return join(dirname(path1), path2);
  }

  String format(String code) => formatter.format(code);
}
