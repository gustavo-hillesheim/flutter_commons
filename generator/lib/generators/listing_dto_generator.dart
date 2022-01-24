import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../mappers/class_declaration_mapper.dart';
import '../models/class.dart';
import '../extensions.dart';

class ListingDtoGenerator extends ClassTargetedGenerator {
  ListingDtoGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    final outputPath = relativePath(
      '../dto/$snakeCaseMemberName/listing_${snakeCaseMemberName}_dto.dart',
      from: path,
    );
    return GeneratorResult.single(
      path: outputPath,
      content: format(_buildString(classObj, outputPath, path)),
    );
  }

  String _buildString(Class classObj, String outputPath, String sourcePath) {
    final uncapitalizedClassName = classObj.name.uncapitalized;
    final relativeClassImport = relativeImport(sourcePath, from: outputPath);
    return '''
import 'package:equatable/equatable.dart';

import '$relativeClassImport';

class Listing${classObj.name}Dto extends Equatable {
  ${classObj.instanceFields.map((f) => 'final ${f.nullableType} ${f.name};').join('\n')}

  Listing${classObj.name}Dto({
    ${classObj.instanceFields.map((f) => '${!f.isNullable ? 'required' : ''} this.${f.name},').join('\n')}
  });

  Listing${classObj.name}Dto.from${classObj.name}(${classObj.name} $uncapitalizedClassName) :
    ${classObj.instanceFields.map((f) => '${f.name} = $uncapitalizedClassName.${f.name}').join(',')};

  @override
  List<Object?> get props {
    return [
      ${classObj.instanceFields.map((f) => '${f.name},').join('\n')}
    ];
  }
}
    ''';
  }
}
