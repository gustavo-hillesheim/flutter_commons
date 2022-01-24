import 'package:flutter_commons_generator/generators/get_all_usecase_generator.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late GetAllUseCaseGenerator generator;

  setUp(() {
    generator = GetAllUseCaseGenerator(target: 'User');
  });

  test('SHOULD generate GetUsersUseCase for User class', () async {
    final generatorResult = await runGenerator(generator);

    expect(generatorResult.files.length, 2);
    final generatedFile = generatorResult.files[0];
    expect(
      normalize(generatedFile.path),
      normalize(join(
        exampleDirDirectory.path,
        'lib/usecase/user/get_users_usecase.dart',
      )),
    );
    expect(
      generatedFile.content,
      '''import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../dto/user/listing_user_dto.dart';
import '../../repository/user_repository.dart';

class GetUsersUseCase extends UseCase<NoParams, List<ListingUserDto>> {
  final UserRepository repository;

  GetUsersUseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, List<ListingUserDto>>> execute(NoParams input) {
    return repository.findAll().then(
          (r) => r.map(
            (entities) =>
                entities.map((e) => ListingUserDto.fromUser(e)).toList(),
          ),
        );
  }
}
''',
    );

    final generatedTestFile = generatorResult.files[1];
    expect(
        normalize(generatedTestFile.path),
        normalize(join(exampleDirDirectory.path,
            'test/usecase/user/get_users_usecase_test.dart')));
    expect(generatedTestFile.content, '''import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:example/dto/user/listing_user_dto.dart';
import 'package:example/repository/user_repository.dart';
import 'package:example/usecase/user/get_users_usecase.dart';
import 'package:example/models/user.dart';

void main() {
  late UserRepository repository;
  late GetUsersUseCase usecase;
  // TODO: create User objects or use a shared one
  final List<User> users = [];
  // TODO: create ListingUserDto objects or use a shared one
  final List<ListingUserDto> resultingDtos = [];

  setUp(() {
    repository = UserRepositoryMock();
    usecase = GetUsersUseCase(repository: repository);
  });

  test('WHEN executed SHOULD call repository', () async {
    when(() => repository.findAll()).thenAnswer((_) async => Right(users));

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
class UserRepositoryMock extends Mock implements UserRepository {}

class FakeFailure extends Failure {
  const FakeFailure(String message) : super(message);
}
''');
  });
}
