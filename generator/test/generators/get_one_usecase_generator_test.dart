import 'package:flutter_commons_generator/generators/get_one_usecase_generator.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late GetOneUseCaseGenerator generator;

  setUp(() {
    generator = GetOneUseCaseGenerator(target: 'User');
  });

  test('SHOULD generate GetUserUseCase for User class', () async {
    final generatorResult = await runGenerator(generator);

    expect(generatorResult.files.length, 2);
    final generatedFile = generatorResult.files[0];
    expect(
        normalize(generatedFile.path),
        normalize(join(exampleDirDirectory.path,
            'lib/usecase/user/get_user_usecase.dart')));
    expect(
      generatedFile.content,
      '''import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../models/user.dart';
import '../../repository/user_repository.dart';

class GetUserUseCase extends UseCase<int, User?> {
  final UserRepository repository;

  GetUserUseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, User?>> execute(int input) {
    return repository.findById(input);
  }
}
''',
    );

    final generatedTestFile = generatorResult.files[1];
    expect(
        normalize(generatedTestFile.path),
        normalize(join(exampleDirDirectory.path,
            'test/usecase/user/get_user_usecase_test.dart')));
    expect(generatedTestFile.content, '''import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:example/repository/user_repository.dart';
import 'package:example/usecase/user/get_user_usecase.dart';
import 'package:example/models/user.dart';

void main() {
  late UserRepository repository;
  late GetUserUseCase usecase;
  // TODO: set the object for comparison
  final User user;

  setUp(() {
    repository = UserRepositoryMock();
    usecase = GetUserUseCase(repository: repository);
  });

  test('WHEN executed SHOULD call repository', () async {
    when(() => repository.findById(user.id!))
        .thenAnswer((_) async => Right(user));

    final result = await usecase.execute(user.id!);

    expect(result.isRight(), true);
    expect(result.getRight().toNullable(), user);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.findById(user.id!))
        .thenAnswer((_) async => const Left(FakeFailure('failure')));

    final result = await usecase.execute(user.id!);

    expect(result.isLeft(), true);
    expect(result.getLeft().toNullable()?.message, 'failure');
  });
}

class UserRepositoryMock extends Mock implements UserRepository {}

class FakeFailure extends Failure {
  const FakeFailure(String message) : super(message);
}
''');
  });
}
