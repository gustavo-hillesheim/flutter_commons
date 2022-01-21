import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_commons_generator/mappers/annotation_mapper.dart';

import '../models/field.dart';

class FieldDeclarationMapper {
  final annotationMapper = AnnotationMapper();

  List<Field> declarationsToFields(List<FieldDeclaration> declarations) {
    return declarations
        .map(declarationToFields)
        .fold([], (list, fields) => list..addAll(fields));
  }

  List<Field> declarationToFields(FieldDeclaration declaration) {
    final fields = declaration.fields;
    return fields.variables.map((v) {
      final metadata = [
        ...v.metadata,
        ...fields.metadata,
        ...declaration.metadata,
      ].map(annotationMapper.toMetadata).toList();

      return Field(
        name: v.name.name,
        keyword: fields.keyword?.keyword?.lexeme,
        isStatic: declaration.isStatic,
        type: fields.type?.type?.getDisplayString(withNullability: false),
        nullableType:
            fields.type?.type?.getDisplayString(withNullability: true),
        metadata: metadata,
      );
    }).toList(growable: false);
  }
}
