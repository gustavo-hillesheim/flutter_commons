import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../builders/class_builder.dart';
import '../models/class.dart';
import '../models/field.dart';
import '../builders/library_bulder.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class DeleteUseCaseGenerator extends ClassTargetedGenerator {
  DeleteUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();
    final libraryBuilder = LibraryBuilder(
      '../usecase/$snakeCaseMemberName/delete_${snakeCaseMemberName}_usecase.dart',
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
    final idField = classObj.instanceFields.firstWhere(
        (f) => f.hasMetadata('Id') && f.type != null,
        orElse: () => throw Exception(
            'Could not find field annotated with @Id() in ${classObj.name}'));
    final classBuilder = ClassBuilder(
      'Delete${classObj.name}UseCase',
      extend: 'UseCase<${classObj.name}, void>',
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
      returnType: 'Future<Either<Failure, void>>',
      body: '''
      if (input.${idField.name} == null) {
        return const Left(BusinessFailure('Can not delete entity with null id'));
      }
      return repository.deleteById(input.id!);
      ''',
      params: ['${classObj.name} input'],
      metadata: ['@override'],
      async: true,
    );
    return classBuilder.buildString();
  }
}
