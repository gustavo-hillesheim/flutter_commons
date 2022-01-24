import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../models/class.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class GetOneUseCaseGenerator extends ClassTargetedGenerator {
  GetOneUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    final outputPath = relativePath(
      '../usecase/$snakeCaseMemberName/get_${snakeCaseMemberName}_usecase.dart',
      from: path,
    );
    final packageRoot = getPackageRoot(path);
    return GeneratorResult(
      [
        GeneratedFile(
          path: outputPath,
          content: format(_buildUseCaseLibrary(
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
            )))
      ],
    );
  }

  String _buildUseCaseLibrary(
    Class classObj, {
    required String outputPath,
    required String sourcePath,
  }) {
    final idField = findIdField(classObj);
    final snakeCaseClassName = classObj.name.toSnakeCase();
    final relativeClassImport = relativeImport(sourcePath, from: outputPath);
    return '''
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '$relativeClassImport';
import '../../repository/${snakeCaseClassName}_repository.dart';

class Get${classObj.name}UseCase extends UseCase<${idField.type}, ${classObj.name}?> {
  final ${classObj.name}Repository repository;

  Get${classObj.name}UseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, ${classObj.name}?>> execute(${idField.type} input) {
    return repository.findById(input);
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
    final idField = findIdField(classObj);
    final snakeCaseClassName = classObj.name.toSnakeCase();
    final classVariableName = classObj.name.uncapitalized;
    return '''
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_commons_core/flutter_commons_core.dart';
import '${packageImport('../repository/${snakeCaseClassName}_repository.dart', packageRoot: packageRoot, relativeTo: sourcePath)}';
import '${packageImport(outputPath, packageRoot: packageRoot)}';
import '${packageImport(sourcePath, packageRoot: packageRoot)}';

void main() {
  late ${classObj.name}Repository repository;
  late Get${classObj.name}UseCase usecase;
  // TODO: create User object or use a shared one
  final ${classObj.name} $classVariableName;

  setUp(() {
    repository = ${classObj.name}RepositoryMock();
    usecase = Get${classObj.name}UseCase(repository: repository);
  });

  test('WHEN executed SHOULD call repository', () async {
    when(() => repository.findById($classVariableName.${idField.name}!))
        .thenAnswer((_) async => Right($classVariableName));

    final result = await usecase.execute($classVariableName.${idField.name}!);

    expect(result.isRight(), true);
    expect(result.getRight().toNullable(), $classVariableName);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.findById($classVariableName.${idField.name}!))
        .thenAnswer((_) async => const Left(FakeFailure('failure')));

    final result = await usecase.execute($classVariableName.${idField.name}!);

    expect(result.isLeft(), true);
    expect(result.getLeft().toNullable()?.message, 'failure');
  });
}

// If you want to, you could add these classes to a shared file and remove them from each generated file
class ${classObj.name}RepositoryMock extends Mock implements ${classObj.name}Repository {}
class FakeFailure extends Failure {
  const FakeFailure(String message) : super(message);
}
''';
  }
}
