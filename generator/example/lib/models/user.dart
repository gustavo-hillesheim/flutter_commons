import 'package:flutter_commons_generator/annotations/id.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  @Id()
  final int? id;
  final String username;
  final String password;

  const User({
    required this.username,
    required this.password,
    this.id,
  });

  @override
  List<Object?> get props => [id, username, password];
}
