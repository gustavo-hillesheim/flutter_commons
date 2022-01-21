import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../mappers/class_declaration_mapper.dart';
import '../models/class.dart';
import '../builders/library_bulder.dart';
import '../builders/class_builder.dart';
import '../extensions.dart';

class ListingDtoGenerator extends ClassTargetedGenerator {
  ListingDtoGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();
    final libraryBuilder = LibraryBuilder(
      '../dto/$snakeCaseMemberName/listing_${snakeCaseMemberName}_dto.dart',
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
      'Listing${classObj.name}Dto',
      extend: 'Equatable',
    );
    classBuilder.addFields(classObj.instanceFields);
    classBuilder.addDefaultConstructor();
    final fromMemberInitializers = <String, String>{};
    var getPropsBody = 'return [';
    for (final field in classObj.instanceFields) {
      fromMemberInitializers[field.name] =
          '${classObj.name.uncapitalized}.${field.name}';
      getPropsBody += '${field.name},';
    }
    getPropsBody += '];';
    classBuilder.addNamedConstructor(
      'from${classObj.name}',
      params: ['${classObj.name} ${classObj.name.uncapitalized}'],
      initializers: fromMemberInitializers,
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
