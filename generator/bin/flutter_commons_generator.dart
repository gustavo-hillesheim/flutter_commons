import 'package:args/args.dart';
import 'package:flutter_commons_generator/main.dart';

void main(List<String> args) {
  generate(buildArgs(getParser().parse(args)));
}

ArgParser getParser() {
  return ArgParser()..addOption('target', abbr: 't', mandatory: true);
}

GenerationArgs buildArgs(ArgResults parsedArgs) {
  return GenerationArgs(target: parsedArgs['target']);
}
