import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../builders/class_builder.dart';
import '../models/class.dart';
import '../models/field.dart';
import '../builders/library_bulder.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class GetAllUseCaseGenerator extends ClassTargetedGenerator {
  GetAllUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();
    final libraryBuilder = LibraryBuilder(
      '../usecase/$snakeCaseMemberName/get_${snakeCaseMemberName}s_usecase.dart',
      relativeTo: path,
    );

    libraryBuilder.import(
      'package:flutter_commons_core/flutter_commons_core.dart',
    );
    libraryBuilder.import('package:fpdart/fpdart.dart');
    libraryBuilder.import(path);
    libraryBuilder
        .import('../../repository/${snakeCaseMemberName}_repository.dart');
    libraryBuilder.declare(_buildClass(classObj));

    return GeneratorResult.single(
      path: libraryBuilder.path,
      content: libraryBuilder.buildString(),
    );
  }

  String _buildClass(Class classObj) {
    final classBuilder = ClassBuilder(
      'Get${classObj.name}sUseCase',
      extend: 'UseCase<NoParams, List<${classObj.name}>>',
      abstract: true,
    );
    classBuilder.addField(Field(
      name: 'repository',
      type: '${classObj.name}Repository',
      nullableType: '${classObj.name}Repository',
      keyword: 'final',
    ));
    classBuilder.addDefaultConstructor();
    classBuilder.addMethod(
      'execute',
      returnType: 'Future<Either<Failure, List<${classObj.name}>>>',
      body: 'return repository.findAll();',
      params: ['NoParams input'],
      metadata: ['@override'],
    );
    return classBuilder.buildString();
  }
}
