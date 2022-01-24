import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_generator/code_generator.dart';

import 'class_targeted_generator.dart';
import '../models/class.dart';
import '../mappers/class_declaration_mapper.dart';
import '../extensions.dart';

class GetAllUseCaseGenerator extends ClassTargetedGenerator {
  GetAllUseCaseGenerator({required String target}) : super(target: target);

  @override
  GeneratorResult generate(ClassDeclaration member, String path) {
    final classObj = ClassDeclarationMapper().toClass(member);
    final snakeCaseMemberName = classObj.name.toSnakeCase();

    final outputPath = relativePath(
      '../usecase/$snakeCaseMemberName/get_${snakeCaseMemberName}s_usecase.dart',
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
    final snakeCaseClassName = classObj.name.toSnakeCase();
    return '''
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../dto/$snakeCaseClassName/listing_${snakeCaseClassName}_dto.dart';
import '../../repository/${snakeCaseClassName}_repository.dart';

class Get${classObj.name}sUseCase extends UseCase<NoParams, List<Listing${classObj.name}Dto>> {
  final ${classObj.name}Repository repository;

  Get${classObj.name}sUseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, List<Listing${classObj.name}Dto>>> execute(NoParams input) {
    return repository.findAll().then(
          (r) => r.map(
            (entities) =>
                entities.map((e) => Listing${classObj.name}Dto.from${classObj.name}(e)).toList(),
          ),
        );
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
    final snakeCaseClassName = classObj.name.toSnakeCase();
    final classVariableName = classObj.name.uncapitalized;
    return '''
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_commons_core/flutter_commons_core.dart';
import '${packageImport('../dto/$snakeCaseClassName/listing_${snakeCaseClassName}_dto.dart', packageRoot: packageRoot, relativeTo: sourcePath)}';
import '${packageImport('../repository/${snakeCaseClassName}_repository.dart', packageRoot: packageRoot, relativeTo: sourcePath)}';
import '${packageImport(outputPath, packageRoot: packageRoot)}';
import '${packageImport(sourcePath, packageRoot: packageRoot)}';

void main() {
  late ${classObj.name}Repository repository;
  late Get${classObj.name}sUseCase usecase;
  // TODO: create ${classObj.name} objects or use a shared one
  final List<${classObj.name}> ${classVariableName}s = [];
  // TODO: create Listing${classObj.name}Dto objects or use a shared one
  final List<Listing${classObj.name}Dto> resultingDtos = [];

  setUp(() {
    repository = ${classObj.name}RepositoryMock();
    usecase = Get${classObj.name}sUseCase(repository: repository);
  });

  test('WHEN executed SHOULD call repository', () async {
    when(() => repository.findAll())
        .thenAnswer((_) async => Right(${classVariableName}s));

    final result = await usecase.execute(const NoParams());

    expect(result.isRight(), true);
    expect(result.getRight().toNullable(), resultingDtos);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.findAll())
        .thenAnswer((_) async => const Left(FakeFailure('failure')));

    final result = await usecase.execute(const NoParams());

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
