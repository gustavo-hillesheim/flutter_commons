import 'package:flutter_commons_generator/models/field.dart';

class Class {
  final String name;
  final List<Field> fields;

  Class({
    required this.name,
    this.fields = const [],
  });

  List<Field> get instanceFields => fields.where((f) => !f.isStatic).toList();
}
