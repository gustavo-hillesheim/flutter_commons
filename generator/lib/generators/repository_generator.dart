import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../builders/class_builder.dart';
import '../builders/library_bulder.dart';
import '../extensions.dart';
import '../mappers/class_declaration_mapper.dart';
import '../models/class.dart';

class RepositoryGenerator extends ClassTargetedGenerator {
  RepositoryGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();
    final libraryBuilder = LibraryBuilder(
      '../repository/${snakeCaseMemberName}_repository.dart',
      relativeTo: path,
    );

    libraryBuilder
        .import('package:flutter_commons_core/flutter_commons_core.dart');
    libraryBuilder.import(path);
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
      '${classObj.name}Repository',
      extend: 'Repository<${classObj.name}, ${idField.type}>',
      abstract: true,
    );
    return classBuilder.buildString();
  }
}
