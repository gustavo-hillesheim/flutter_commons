import 'package:flutter_commons_generator/generators/save_usecase_generator.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late SaveUseCaseGenerator generator;

  setUp(() {
    generator = SaveUseCaseGenerator(target: 'User');
  });

  test('SHOULD generate GetUserUseCase for User class', () async {
    final generatorResult = await runGenerator(generator);

    expect(generatorResult.files.length, 2);
    final generatedFile = generatorResult.files[0];
    expect(
        normalize(generatedFile.path),
        normalize(join(exampleDirDirectory.path,
            'lib/usecase/user/save_user_usecase.dart')));
    expect(
      generatedFile.content,
      '''import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../dto/user/editing_user_dto.dart';
import '../../repository/user_repository.dart';

class SaveUserUseCase extends UseCase<EditingUserDto, int> {
  final UserRepository repository;

  SaveUserUseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, int>> execute(EditingUserDto input) {
    return repository.save(input.toUser());
  }
}
''',
    );

    final generatedTestFile = generatorResult.files[1];
    expect(
        normalize(generatedTestFile.path),
        normalize(join(exampleDirDirectory.path,
            'test/usecase/user/save_user_usecase_test.dart')));
    expect(generatedTestFile.content, '''import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:example/dto/user/editing_user_dto.dart';
import 'package:example/repository/user_repository.dart';
import 'package:example/usecase/user/save_user_usecase.dart';
import 'package:example/models/user.dart';

void main() {
  late UserRepository repository;
  late SaveUserUseCase usecase;
  // TODO: create User object or use a shared one
  final User user;
  // TODO: create EditingUserDto object or use a shared one
  final EditingUserDto dto;

  setUp(() {
    repository = UserRepositoryMock();
    usecase = SaveUserUseCase(repository: repository);
  });

  test('WHEN executed SHOULD call repository', () async {
    when(() => repository.save(user)).thenAnswer((_) async => Right(user.id!));

    final result = await usecase.execute(dto);

    expect(result.isRight(), true);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.save(user))
        .thenAnswer((_) async => const Left(FakeFailure('failure')));

    final result = await usecase.execute(dto);

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
