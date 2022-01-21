import 'package:analyzer/dart/ast/ast.dart';

import '../models/metadata.dart';

class AnnotationMapper {
  Metadata toMetadata(Annotation annotation) {
    return Metadata(
      annotation.name.name,
      constructorName: annotation.constructorName?.name,
    );
  }
}
