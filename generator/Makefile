publish_local:
	cd .. && dart pub global activate --source path generator

run_on_example:
	make publish_local && cd example && flutter_commons_generator -t User

coverage:
	dart run code_coverage --ignoreBarrelFiles -u