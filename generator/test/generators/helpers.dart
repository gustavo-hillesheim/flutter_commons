import 'dart:io';

import 'package:code_generator/generation_step.dart';
import 'package:path/path.dart';
import 'package:code_generator/code_generator.dart';

final exampleDirDirectory = Directory(join(Directory.current.path, 'example'));

Future<CodeGenerationResult> runGenerator(Generator generator) async {
  final codeGenerator = CodeGenerator(generators: [generator]);
  const packageAnalyzer = PackageAnalyzer();

  final libraries = await packageAnalyzer.analyze(exampleDirDirectory);
  return codeGenerator.runGenerators(libraries).last
      as Future<CodeGenerationResult>;
}
