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

    expect(generatorResult.files.length, 1);
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
  });
}
