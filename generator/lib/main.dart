import 'dart:io';

import 'package:code_generator/code_generator.dart';
import 'package:code_generator/generation_step.dart';
import 'package:flutter_commons_generator/generators/delete_usecase_generator.dart';

import 'generators/save_usecase_generator.dart';
import 'generators/get_one_usecase_generator.dart';
import 'generators/get_all_usecase_generator.dart';
import 'generators/repository_generator.dart';
import 'generators/editing_dto_generator.dart';
import 'generators/listing_dto_generator.dart';

Stream<GenerationStep> generate(GenerationArgs args) {
  final generator = CodeGenerator(generators: [
    if (['crud'].contains(args.structureToGenerate)) ...[
      ListingDtoGenerator(target: args.target),
      EditingDtoGenerator(target: args.target),
      RepositoryGenerator(target: args.target),
      GetAllUseCaseGenerator(target: args.target),
      GetOneUseCaseGenerator(target: args.target),
      SaveUseCaseGenerator(target: args.target),
      DeleteUseCaseGenerator(target: args.target),
    ],
  ]);
  return generator.generateFor(
    Directory.current,
    overrideExisting: args.overrideExisting,
  );
}

class GenerationArgs {
  final String target;
  final String structureToGenerate;
  final bool overrideExisting;

  GenerationArgs({
    required this.target,
    required this.structureToGenerate,
    required this.overrideExisting,
  });
}
