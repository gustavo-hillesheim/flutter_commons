import 'package:path/path.dart';
import 'package:flutter_commons_generator/generators/listing_dto_generator.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late ListingDtoGenerator generator;

  setUp(() {
    generator = ListingDtoGenerator(target: 'User');
  });

  test('SHOULD generate ListingDto for User class', () async {
    final generatorResult = await runGenerator(generator);

    expect(generatorResult.files.length, 2);
    final generatedFile = generatorResult.files[0];
    expect(
        normalize(generatedFile.path),
        normalize(join(
            exampleDirDirectory.path, 'lib/dto/user/listing_user_dto.dart')));
    expect(
      generatedFile.content,
      '''import 'package:equatable/equatable.dart';

import '../../models/user.dart';

class ListingUserDto extends Equatable {
  final int? id;
  final String username;
  final String password;

  ListingUserDto({
    this.id,
    required this.username,
    required this.password,
  });

  ListingUserDto.fromUser(User user)
      : id = user.id,
        username = user.username,
        password = user.password;

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
            'test/dto/user/listing_user_dto_test.dart')));
    expect(generatedTestFile.content, '''
import 'package:test/test.dart';
import 'package:example/dto/user/listing_user_dto.dart';
import 'package:example/models/user.dart';

void main() {
  // TODO: set the object for comparison
  final User user;

  test('SHOULD convert User to DTO', () {
    final dto = ListingUserDto.fromUser(user);

    expect(dto.id, user.id);
    expect(dto.username, user.username);
    expect(dto.password, user.password);
  });
}
''');
  });
}
