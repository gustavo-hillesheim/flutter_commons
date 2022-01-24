import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../extensions.dart';
import '../mappers/class_declaration_mapper.dart';
import '../models/class.dart';

class RepositoryGenerator extends ClassTargetedGenerator {
  RepositoryGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    final outputPath = relativePath(
      '../repository/${snakeCaseMemberName}_repository.dart',
      from: path,
    );
    return GeneratorResult.single(
      path: outputPath,
      content: format(_buildString(classObj, outputPath, path)),
    );
  }

  String _buildString(Class classObj, String outputPath, String sourcePath) {
    final idField = findIdField(classObj);
    final relativeClassImport = relativeImport(sourcePath, from: outputPath);
    return '''
import 'package:flutter_commons_core/flutter_commons_core.dart';

import '$relativeClassImport';

abstract class ${classObj.name}Repository extends Repository<${classObj.name}, ${idField.type}> {}
    ''';
  }
}
