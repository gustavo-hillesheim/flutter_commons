import 'package:flutter_commons_generator/annotations/id.dart';

class User {
  @Id()
  final int? id;
  final String username;
  final String password;

  const User({
    required this.username,
    required this.password,
    this.id,
  });
}
