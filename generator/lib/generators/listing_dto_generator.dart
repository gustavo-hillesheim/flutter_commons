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
    final packageRoot = getPackageRoot(path);
    return GeneratorResult(
      [
        GeneratedFile(
          path: outputPath,
          content: format(_buildDtoLibrary(
            classObj,
            outputPath: outputPath,
            sourcePath: path,
          )),
        ),
        GeneratedFile(
          path: testPath(outputPath, packageRoot: packageRoot),
          content: format(_buildTestLibrary(
            classObj,
            outputPath: outputPath,
            sourcePath: path,
            packageRoot: packageRoot,
          )),
        ),
      ],
    );
  }

  String _buildDtoLibrary(
    Class classObj, {
    required String outputPath,
    required String sourcePath,
  }) {
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

  String _buildTestLibrary(
    Class classObj, {
    required String outputPath,
    required String sourcePath,
    required String packageRoot,
  }) {
    final classVariableName = classObj.name.uncapitalized;
    return '''
import 'package:test/test.dart';
import '${packageImport(outputPath, packageRoot: packageRoot)}';
import '${packageImport(sourcePath, packageRoot: packageRoot)}';

void main() {
  // TODO: set the object for comparison
  final ${classObj.name} $classVariableName;

  test('SHOULD convert ${classObj.name} to DTO', () {
    final dto = Listing${classObj.name}Dto.from${classObj.name}($classVariableName);

    ${classObj.instanceFields.map((f) => 'expect(dto.${f.name}, $classVariableName.${f.name});').join('\n')}
  });
}
''';
  }
}
