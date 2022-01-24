import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../models/class.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class SaveUseCaseGenerator extends ClassTargetedGenerator {
  SaveUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    final outputPath = relativePath(
      '../usecase/$snakeCaseMemberName/save_${snakeCaseMemberName}_usecase.dart',
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
    return '''
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../dto/$snakeCaseClassName/editing_${snakeCaseClassName}_dto.dart';
import '../../repository/${snakeCaseClassName}_repository.dart';

class Save${classObj.name}UseCase extends UseCase<Editing${classObj.name}Dto, ${idField.type}> {
  final ${classObj.name}Repository repository;

  Save${classObj.name}UseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, ${idField.type}>> execute(Editing${classObj.name}Dto input) {
    return repository.save(input.to${classObj.name}());
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
import '${packageImport('../dto/$snakeCaseClassName/editing_${snakeCaseClassName}_dto.dart', packageRoot: packageRoot, relativeTo: sourcePath)}';
import '${packageImport('../repository/${snakeCaseClassName}_repository.dart', packageRoot: packageRoot, relativeTo: sourcePath)}';
import '${packageImport(outputPath, packageRoot: packageRoot)}';
import '${packageImport(sourcePath, packageRoot: packageRoot)}';

void main() {
  late ${classObj.name}Repository repository;
  late Save${classObj.name}UseCase usecase;
  // TODO: create ${classObj.name} object or use a shared one
  final ${classObj.name} resulting${classObj.name};
  // TODO: create Editing${classObj.name}Dto object or use a shared one
  final Editing${classObj.name}Dto dto;

  setUp(() {
    repository = ${classObj.name}RepositoryMock();
    usecase = Save${classObj.name}UseCase(repository: repository);
  });

  test('WHEN executed SHOULD call repository', () async {
    when(() => repository.save(resulting${classObj.name}))
        .thenAnswer((_) async => Right(resulting${classObj.name}.${idField.name}!));

    final result = await usecase.execute(dto);

    expect(result.isRight(), true);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.save(resulting${classObj.name}))
        .thenAnswer((_) async => const Left(FakeFailure('failure')));

    final result = await usecase.execute(dto);

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
