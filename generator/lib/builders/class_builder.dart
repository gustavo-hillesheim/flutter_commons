import 'package:dart_style/dart_style.dart';
import 'package:flutter_commons_generator/models/field.dart';

class ClassBuilder {
  final String _name;
  final String? _extend;
  final bool _isAbstract;
  final List<Field> _fields = [];
  String _constructors = '';
  String _methods = '';

  ClassBuilder(this._name, {String? extend, bool abstract = false})
      : _extend = extend,
        _isAbstract = abstract;

  void addFields(List<Field> fields) => fields.forEach(addField);

  void addField(Field field) {
    _fields.add(field);
  }

  void addMethod(
    String name, {
    String? returnType,
    String? body,
    List<String>? metadata,
    List<String>? params,
    bool async = false,
  }) {
    _addMethod(
      '${metadata?.join('\n') ?? ''} '
      '$returnType $name(${params?.join(', ') ?? ''}) ${async ? 'async' : ''} { $body }',
    );
  }

  void addGetter(String name,
      {String? returnType, String? body, List<String>? metadata}) {
    _addMethod('$returnType get $name { $body }', metadata: metadata);
  }

  void _addMethod(String method, {List<String>? metadata}) {
    if (_methods.isNotEmpty) {
      _methods += '\n\n';
    }
    metadata?.forEach((m) => _methods += '$m\n');
    _methods += method;
  }

  void addDefaultConstructor() {
    var constructor = '$_name({';
    for (final field in _fields) {
      var constructorField = '';
      if (field.isFinal && !field.isNullable) {
        constructorField += 'required ';
      }
      constructorField += 'this.${field.name},';
      constructor += constructorField;
    }
    constructor += '});';
    _addConstructor(constructor);
  }

  void addNamedConstructor(String name,
      {List<String>? params, Map<String, String>? initializers}) {
    var constructor = '$_name.$name(${params?.join(', ') ?? ''})';
    if (initializers?.isNotEmpty ?? false) {
      constructor += ' : ' +
          initializers!.entries
              .map((entry) => '${entry.key} = ${entry.value}')
              .join(',');
    }
    constructor += ';';
    _addConstructor(constructor);
  }

  void _addConstructor(String constructor) {
    if (_constructors.isNotEmpty) {
      _constructors += '\n\n';
    }
    _constructors += constructor;
  }

  String buildString() {
    var classStr = '';
    if (_isAbstract) {
      classStr += 'abstract ';
    }
    classStr += 'class $_name';
    if (_extend != null) {
      classStr += ' extends $_extend';
    }
    classStr += ' {';
    void addGroup(String groupContent) {
      if (classStr != 'class $_name {' && groupContent.isNotEmpty) {
        classStr += '\n\n';
      }
      classStr += groupContent;
    }

    addGroup(_buildFields());
    addGroup(_constructors);
    addGroup(_methods);
    classStr += '}';

    return DartFormatter().format(classStr);
  }

  String _buildFields() {
    return _fields
        .map((f) => '${f.keyword} ${f.nullableType} ${f.name};')
        .join('');
  }
}
