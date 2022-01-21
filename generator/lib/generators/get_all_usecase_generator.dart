import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

import 'class_targeted_generator.dart';
import '../models/class.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class GetAllUseCaseGenerator extends ClassTargetedGenerator {
  GetAllUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    return GeneratorResult.single(
      path: join(
        dirname(path),
        '../usecase/$snakeCaseMemberName/get_${snakeCaseMemberName}s_usecase.dart',
      ),
      content:
          DartFormatter().format(_buildString(classObj, snakeCaseMemberName)),
    );
  }

  String _buildString(Class classObj, String snakeCaseMemberName) {
    return '''
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../models/$snakeCaseMemberName.dart';
import '../../repository/${snakeCaseMemberName}_repository.dart';

class Get${classObj.name}sUseCase extends UseCase<NoParams, List<${classObj.name}>> {
  final ${classObj.name}Repository repository;

  Get${classObj.name}sUseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, List<${classObj.name}>>> execute(NoParams input) {
    return repository.findAll();
  }
}
    ''';
  }
}
