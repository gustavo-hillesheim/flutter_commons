import 'package:flutter_commons_generator/generators/repository_generator.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late RepositoryGenerator generator;

  setUp(() {
    generator = RepositoryGenerator(target: 'User');
  });

  test('SHOULD generate Repository for User class', () async {
    final generatorResult = await runGenerator(generator);

    expect(generatorResult.files.length, 1);
    final generatedFile = generatorResult.files[0];
    expect(
        normalize(generatedFile.path),
        normalize(join(
            exampleDirDirectory.path, 'lib/repository/user_repository.dart')));
    expect(
      generatedFile.content,
      '''import 'package:flutter_commons_core/flutter_commons_core.dart';
import '../models/user.dart';

abstract class UserRepository extends Repository<User, int> {}
''',
    );
  });
}
