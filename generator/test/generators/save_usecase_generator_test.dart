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

    expect(generatorResult.files.length, 1);
    final generatedFile = generatorResult.files[0];
    expect(
        normalize(generatedFile.path),
        normalize(join(exampleDirDirectory.path,
            'lib/usecase/user/save_user_usecase.dart')));
    expect(
      generatedFile.content,
      '''import 'package:flutter_commons_core/flutter_commons_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../models/user.dart';
import '../../dto/editing_user_dto.dart';
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
  });
}
