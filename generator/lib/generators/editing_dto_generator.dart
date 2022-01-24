import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

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

    final outputPath = relativePath(
      '../dto/$snakeCaseMemberName/editing_${snakeCaseMemberName}_dto.dart',
      from: path,
    );
    return GeneratorResult.single(
      path: outputPath,
      content: format(_buildString(classObj, outputPath, path)),
    );
  }

  String _buildString(Class classObj, String outputPath, String sourcePath) {
    final relativeClassImport = relativeImport(sourcePath, from: outputPath);
    return '''
import 'package:equatable/equatable.dart';

import '$relativeClassImport';

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
}
