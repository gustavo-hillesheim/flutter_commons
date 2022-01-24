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

    expect(generatorResult.files.length, 1);
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

import '../../models/user.dart';
import '../../dto/listing_user_dto.dart';
import '../../repository/user_repository.dart';

class GetUsersUseCase extends UseCase<NoParams, List<ListingUserDto>> {
  final UserRepository repository;

  GetUsersUseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, List<ListingUserDto>>> execute(NoParams input) {
    return repository.findAll().then(
          (entities) =>
              entities.map((e) => ListingUserDto.fromUser(e)).toList(),
        );
  }
}
''',
    );
  });
}
