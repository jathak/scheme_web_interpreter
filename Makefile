.PHONY: deploy test format format-dryrun

deploy:
	pub get
	pub build
	touch build/web/.static
	rm -r build/web/packages
	bash deploy.sh

test:
	dart test/scm.dart

format:
	dartfmt -w -l 100 .

format-dryrun:
	dartfmt -l 100 .
