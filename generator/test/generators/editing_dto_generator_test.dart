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

    expect(generatorResult.files.length, 2);
    final generatedDtoFile = generatorResult.files[0];
    expect(
        normalize(generatedDtoFile.path),
        normalize(join(
            exampleDirDirectory.path, 'lib/dto/user/editing_user_dto.dart')));
    expect(
      generatedDtoFile.content,
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

    final generatedTestFile = generatorResult.files[1];
    expect(
        normalize(generatedTestFile.path),
        normalize(join(exampleDirDirectory.path,
            'test/dto/user/editing_user_dto_test.dart')));
    expect(generatedTestFile.content, '''
import 'package:test/test.dart';
import 'package:example/dto/user/editing_user_dto.dart';
import 'package:example/models/user.dart';

void main() {
  // TODO: create User object or use a shared one
  final User user;

  test('SHOULD convert DTO to User', () {
    final dto = EditingUserDto(
      id: user.id,
      username: user.username,
      password: user.password,
    );

    expect(dto.toUser(), user);
  });
}
''');
  });
}
