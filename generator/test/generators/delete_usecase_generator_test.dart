import 'package:flutter_commons_generator/generators/delete_usecase_generator.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late DeleteUseCaseGenerator generator;

  setUp(() {
    generator = DeleteUseCaseGenerator(target: 'User');
  });

  test('SHOULD generate GetUserUseCase for User class', () async {
    final generatorResult = await runGenerator(generator);

    expect(generatorResult.files.length, 2);
    final generatedFile = generatorResult.files[0];
    expect(
        normalize(generatedFile.path),
        normalize(join(exampleDirDirectory.path,
            'lib/usecase/user/delete_user_usecase.dart')));
    expect(
      generatedFile.content,
      '''import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../models/user.dart';
import '../../repository/user_repository.dart';

class DeleteUserUseCase extends UseCase<User, void> {
  final UserRepository repository;

  DeleteUserUseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, void>> execute(User input) async {
    if (input.id == null) {
      return const Left(BusinessFailure('Can not delete entity with null id'));
    }
    return repository.deleteById(input.id!);
  }
}
''',
    );

    final generatedTestFile = generatorResult.files[1];
    expect(
        normalize(generatedTestFile.path),
        normalize(join(exampleDirDirectory.path,
            'test/usecase/user/delete_user_usecase_test.dart')));
    expect(generatedTestFile.content, '''import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:example/repository/user_repository.dart';
import 'package:example/usecase/user/delete_user_usecase.dart';
import 'package:example/models/user.dart';

void main() {
  late UserRepository repository;
  late DeleteUserUseCase usecase;
  // TODO: create User object or use a shared one
  final User user;

  setUp(() {
    repository = UserRepositoryMock();
    usecase = DeleteUserUseCase(repository: repository);
  });

  test('WHEN executed SHOULD call repository', () async {
    when(() => repository.deleteById(user.id!))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(user);

    expect(result.isRight(), true);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.deleteById(user.id!))
        .thenAnswer((_) async => const Left(FakeFailure('failure')));

    final result = await usecase.execute(user);

    expect(result.isLeft(), true);
    expect(result.getLeft().toNullable()?.message, 'failure');
  });
}

// If you want to, you could add these classes to a shared file and remove them from each generated file
class UserRepositoryMock extends Mock implements UserRepository {}

class FakeFailure extends Failure {
  const FakeFailure(String message) : super(message);
}
''');
  });
}
