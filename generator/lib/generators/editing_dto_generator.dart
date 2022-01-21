import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../builders/class_builder.dart';
import '../builders/library_bulder.dart';
import '../extensions.dart';
import '../mappers/class_declaration_mapper.dart';
import '../models/class.dart';

class EditingDtoGenerator extends ClassTargetedGenerator {
  EditingDtoGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();
    final libraryBuilder = LibraryBuilder(
      '../dto/$snakeCaseMemberName/editing_${snakeCaseMemberName}_dto.dart',
      relativeTo: path,
    );

    libraryBuilder.import('package:equatable/equatable.dart');
    libraryBuilder.import(path);
    libraryBuilder.declare(_buildClass(classObj));

    return GeneratorResult.single(
      path: libraryBuilder.path,
      content: libraryBuilder.buildString(),
    );
  }

  String _buildClass(Class classObj) {
    final classBuilder = ClassBuilder(
      'Editing${classObj.name}Dto',
      extend: 'Equatable',
    );
    classBuilder.addFields(classObj.instanceFields);
    classBuilder.addDefaultConstructor();

    var getPropsBody = 'return [';
    var toMemberBody = 'return ${classObj.name}(';
    for (final field in classObj.instanceFields) {
      toMemberBody += '${field.name}: ${field.name},';
      getPropsBody += '${field.name},';
    }
    toMemberBody += ');';
    getPropsBody += '];';
    classBuilder.addMethod(
      'to${classObj.name}',
      returnType: classObj.name,
      body: toMemberBody,
    );
    classBuilder.addGetter(
      'props',
      returnType: 'List<Object?>',
      body: getPropsBody,
      metadata: ['@override'],
    );
    return classBuilder.buildString();
  }
}
