import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

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

    return GeneratorResult.single(
      path: join(
        dirname(path),
        '../dto/$snakeCaseMemberName/listing_${snakeCaseMemberName}_dto.dart',
      ),
      content: DartFormatter().format(
        _buildString(classObj, snakeCaseMemberName),
      ),
    );
  }

  String _buildString(Class classObj, String snakeCaseMemberName) {
    final uncapitalizedClassName = classObj.name.uncapitalized;
    return '''
import 'package:equatable/equatable.dart';

import '../../models/$snakeCaseMemberName.dart';

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
