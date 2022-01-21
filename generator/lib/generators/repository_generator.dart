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

    return GeneratorResult.single(
      path: relativePath(
        path,
        '../repository/${snakeCaseMemberName}_repository.dart',
      ),
      content: format(_buildString(classObj, snakeCaseMemberName)),
    );
  }

  String _buildString(Class classObj, String snakeCaseMemberName) {
    final idField = classObj.instanceFields.firstWhere(
        (f) => f.hasMetadata('Id') && f.type != null,
        orElse: () => throw Exception(
            'Could not find field annotated with @Id() in ${classObj.name}'));
    return '''
import 'package:flutter_commons_core/flutter_commons_core.dart';

import '../models/$snakeCaseMemberName.dart';

abstract class ${classObj.name}Repository extends Repository<${classObj.name}, ${idField.type}> {}
    ''';
  }
}
