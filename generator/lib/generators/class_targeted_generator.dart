import 'package:code_generator/code_generator.dart';
import 'package:analyzer/dart/ast/ast.dart';

abstract class ClassTargetedGenerator extends GeneratorForClass {
  final String target;

  ClassTargetedGenerator({required this.target});

  @override
  bool shouldGenerateFor(ClassDeclaration member, String path) {
    return super.shouldGenerateFor(member, path) && member.name.name == target;
  }
}
