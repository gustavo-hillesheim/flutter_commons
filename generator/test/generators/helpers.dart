import 'dart:io';

import 'package:path/path.dart';
import 'package:code_generator/code_generator.dart';

final exampleDirDirectory = Directory(join(Directory.current.path, 'example'));

Future<GeneratorResult> runGenerator(Generator generator) async {
  final codeGenerator = CodeGenerator(generators: [generator]);
  const packageAnalyzer = PackageAnalyzer();

  final libraries = await packageAnalyzer.analyze(exampleDirDirectory);
  return codeGenerator.runGenerators(libraries);
}
