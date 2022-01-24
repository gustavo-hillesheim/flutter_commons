import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../models/class.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class DeleteUseCaseGenerator extends ClassTargetedGenerator {
  DeleteUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    final outputPath = relativePath(
      '../usecase/$snakeCaseMemberName/delete_${snakeCaseMemberName}_usecase.dart',
      from: path,
    );
    return GeneratorResult.single(
      path: outputPath,
      content: format(_buildString(classObj, outputPath, path)),
    );
  }

  String _buildString(Class classObj, String outputPath, String sourcePath) {
    final idField = findIdField(classObj);
    final snakeCaseClassName = classObj.name.toSnakeCase();
    final relativeClassImport = relativeImport(sourcePath, from: outputPath);
    return '''
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '$relativeClassImport';
import '../../repository/${snakeCaseClassName}_repository.dart';

class Delete${classObj.name}UseCase extends UseCase<${classObj.name}, void> {
  final ${classObj.name}Repository repository;

  Delete${classObj.name}UseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, void>> execute(${classObj.name} input) async {
    if (input.${idField.name} == null) {
      return const Left(BusinessFailure('Can not delete entity with null id'));
    }
    return repository.deleteById(input.id!);
  }
}
    ''';
  }
}
