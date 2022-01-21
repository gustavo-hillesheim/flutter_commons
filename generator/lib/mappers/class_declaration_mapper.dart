import 'package:analyzer/dart/ast/ast.dart';

import 'field_declaration_mapper.dart';
import '../models/class.dart';

class ClassDeclarationMapper {
  final fieldsMapper = FieldDeclarationMapper();

  Class toClass(ClassDeclaration classDeclaration) {
    return Class(
      name: classDeclaration.name.name,
      fields: fieldsMapper.declarationsToFields(
        classDeclaration.members.whereType<FieldDeclaration>().toList(),
      ),
    );
  }
}
