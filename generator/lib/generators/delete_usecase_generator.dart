import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../models/class.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class DeleteUseCaseGenerator extends ClassTargetedGenerator {
  DeleteUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    final outputPath = relativePath(
      '../usecase/$snakeCaseMemberName/delete_${snakeCaseMemberName}_usecase.dart',
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
          )),
        ),
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

class Delete${classObj.name}UseCase extends UseCase<${classObj.name}, void> {
  static const entityWithoutIdError = 'Can not delete entity with null id';

  final ${classObj.name}Repository repository;

  Delete${classObj.name}UseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, void>> execute(${classObj.name} input) async {
    if (input.${idField.name} == null) {
      return const Left(BusinessFailure(entityWithoutIdError));
    }
    return repository.deleteById(input.id!);
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
  late Delete${classObj.name}UseCase usecase;
  // TODO: create ${classObj.name} object or use a shared one
  final ${classObj.name} $classVariableName;
  // TODO: create ${classObj.name} object or use a shared one
  final ${classObj.name} ${classVariableName}WithoutId;

  setUp(() {
    repository = ${classObj.name}RepositoryMock();
    usecase = Delete${classObj.name}UseCase(repository: repository);
  });

  test('WHEN executed SHOULD call repository', () async {
    when(() => repository.deleteById($classVariableName.${idField.name}!))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase.execute($classVariableName);

    expect(result.isRight(), true);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.deleteById($classVariableName.${idField.name}!))
        .thenAnswer((_) async => const Left(FakeFailure('failure')));

    final result = await usecase.execute($classVariableName);

    expect(result.isLeft(), true);
    expect(result.getLeft().toNullable()?.message, 'failure');
  });

  test('WHEN $classVariableName has no id SHOULD return Failure', () async {
    final result = await usecase.execute(${classVariableName}WithoutId);

    expect(result.isLeft(), true);
    expect(result.getLeft().toNullable()?.message, Delete${classObj.name}UseCase.entityWithoutIdError,);

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
