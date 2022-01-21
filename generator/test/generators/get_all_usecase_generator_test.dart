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
        normalize(join(exampleDirDirectory.path,
            'lib/usecase/user/get_users_usecase.dart')));
    expect(
      generatedFile.content,
      '''import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';
import '../../models/user.dart';
import '../../repository/user_repository.dart';

abstract class GetUsersUseCase extends UseCase<NoParams, List<User>> {
  final UserRepository repository;

  GetUsersUseCase({
    required this.repository,
  });

  @override
  Future<Either<Failure, List<User>>> execute(NoParams input) {
    return repository.findAll();
  }
}
''',
    );
  });
}
