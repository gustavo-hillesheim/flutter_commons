import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_commons_generator/main.dart';

void main(List<String> args) {
  generate(buildArgs(getParser().parse(args)))
      .listen((event) => print(event.message));
}

ArgParser getParser() {
  final generateParser = ArgParser()
    ..addOption('target', abbr: 't', mandatory: true)
    ..addFlag('overrideExistingFiles');

  return ArgParser()..addCommand('generate', generateParser);
}

GenerationArgs buildArgs(ArgResults parsedArgs) {
  if (parsedArgs.command?.name == 'generate') {
    final generateArgs = parsedArgs.command!;
    if (generateArgs.rest.isEmpty) {
      print('Inform which structure should be generated');
      exit(1);
    }
    return GenerationArgs(
      target: generateArgs['target'],
      structureToGenerate: generateArgs.rest[0],
      overrideExisting: generateArgs['overrideExistingFiles'],
    );
  } else {
    print('Unknown command ${parsedArgs.command?.name}');
    exit(1);
  }
}
