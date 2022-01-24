import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../models/class.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class SaveUseCaseGenerator extends ClassTargetedGenerator {
  SaveUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    return GeneratorResult.single(
      path: relativePath(
        path,
        '../usecase/$snakeCaseMemberName/save_${snakeCaseMemberName}_usecase.dart',
      ),
      content: format(_buildString(classObj, snakeCaseMemberName)),
    );
  }

  String _buildString(Class classObj, String snakeCaseMemberName) {
    final idField = findIdField(classObj);
    return '''
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../models/$snakeCaseMemberName.dart';
import '../../dto/editing_${snakeCaseMemberName}_dto.dart';
import '../../repository/${snakeCaseMemberName}_repository.dart';

class Save${classObj.name}UseCase extends UseCase<Editing${classObj.name}Dto, ${idField.type}> {
  final ${classObj.name}Repository repository;

  Save${classObj.name}UseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, ${idField.type}>> execute(Editing${classObj.name}Dto input) {
    return repository.save(input.to${classObj.name}());
  }
}
    ''';
  }
}
