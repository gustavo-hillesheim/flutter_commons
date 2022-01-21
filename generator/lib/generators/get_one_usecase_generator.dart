import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../models/class.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class GetOneUseCaseGenerator extends ClassTargetedGenerator {
  GetOneUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    return GeneratorResult.single(
      path: relativePath(
        path,
        '../usecase/$snakeCaseMemberName/get_${snakeCaseMemberName}_usecase.dart',
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
import 'package:fpdart/fpdart.dart';

import '../../models/$snakeCaseMemberName.dart';
import '../../repository/${snakeCaseMemberName}_repository.dart';

class Get${classObj.name}UseCase extends UseCase<${idField.type}, ${classObj.name}?> {
  final ${classObj.name}Repository repository;

  Get${classObj.name}UseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, ${classObj.name}?>> execute(${idField.type} input) {
    return repository.findById(input);
  }
}
    ''';
  }
}
