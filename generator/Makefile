publish_local:
	cd .. && dart pub global activate --source path generator

run_on_example:
	make publish_local && cd example && flutter_commons_generator generate crud -t User

clear_example:
	cd example && \
	rmdir /Q /S test && \
	rmdir /Q /S lib\\dto && \
	rmdir /Q /S lib\\repository && \
	rmdir /Q /S lib\\usecase

coverage:
	dart run code_coverage --ignoreBarrelFiles -u