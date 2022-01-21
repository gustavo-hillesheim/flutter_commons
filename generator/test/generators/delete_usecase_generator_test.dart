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

    expect(generatorResult.files.length, 1);
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
  });
}
