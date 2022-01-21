import 'package:flutter_commons_generator/generators/editing_dto_generator.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late EditingDtoGenerator generator;

  setUp(() {
    generator = EditingDtoGenerator(target: 'User');
  });

  test('SHOULD generate EditingDto for User class', () async {
    final generatorResult = await runGenerator(generator);

    expect(generatorResult.files.length, 1);
    final generatedFile = generatorResult.files[0];
    expect(
        normalize(generatedFile.path),
        normalize(join(
            exampleDirDirectory.path, 'lib/dto/user/editing_user_dto.dart')));
    expect(
      generatedFile.content,
      '''import 'package:equatable/equatable.dart';
import '../../models/user.dart';

class EditingUserDto extends Equatable {
  final int? id;
  final String username;
  final String password;

  EditingUserDto({
    this.id,
    required this.username,
    required this.password,
  });

  User toUser() {
    return User(
      id: id,
      username: username,
      password: password,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      username,
      password,
    ];
  }
}
''',
    );
  });
}
