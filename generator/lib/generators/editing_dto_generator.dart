import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

import 'class_targeted_generator.dart';
import '../extensions.dart';
import '../mappers/class_declaration_mapper.dart';
import '../models/class.dart';

class EditingDtoGenerator extends ClassTargetedGenerator {
  EditingDtoGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    return GeneratorResult.single(
      path: join(
        dirname(path),
        '../dto/$snakeCaseMemberName/editing_${snakeCaseMemberName}_dto.dart',
      ),
      content: DartFormatter().format(
        _buildString(classObj, snakeCaseMemberName),
      ),
    );
  }

  String _buildString(Class classObj, String snakeCaseMemberName) => '''
import 'package:equatable/equatable.dart';

import '../../models/$snakeCaseMemberName.dart';

class Editing${classObj.name}Dto extends Equatable {
  ${classObj.instanceFields.map((f) => 'final ${f.nullableType} ${f.name};').join('\n')}

  Editing${classObj.name}Dto({
  ${classObj.instanceFields.map((f) => '${!f.isNullable ? 'required' : ''} this.${f.name},').join('\n')}
  });

  ${classObj.name} to${classObj.name}() {
    return ${classObj.name}(
      ${classObj.instanceFields.map((f) => '${f.name}: ${f.name},').join('\n')}
    );
  }

  @override
  List<Object?> get props {
    return [
      ${classObj.instanceFields.map((f) => '${f.name},').join('\n')}
    ];
  }
}
      ''';
}
