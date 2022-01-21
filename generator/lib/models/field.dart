import 'metadata.dart';

class Field {
  final String? keyword;
  final String? type;
  final String? nullableType;
  final String name;
  final bool isStatic;
  final List<Metadata> metadata;

  const Field({
    required this.name,
    this.isStatic = false,
    this.metadata = const [],
    this.keyword,
    this.type,
    this.nullableType,
  });

  bool get isFinal => keyword == 'final';
  bool get isNullable => nullableType?.endsWith('?') ?? false;

  bool hasMetadata(String metadataName) =>
      metadata.any((m) => m.name == metadataName);
}
