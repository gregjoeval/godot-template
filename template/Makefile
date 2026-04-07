GODOT ?= godot
GDUNIT4_SCRIPT := addons/gdUnit4/bin/GdUnitCmdTool.gd

.PHONY: test test-single lint check bump setup

## Run all gdUnit4 tests headlessly.
test:
	$(GODOT) --headless --path . \
		-s $(GDUNIT4_SCRIPT) \
		-a "res://tests_gdunit4/" \
		--ignoreHeadlessMode

## Run a single test file. Usage: make test-single FILE=tests_gdunit4/test_foo.gd
test-single:
	$(GODOT) --headless --path . \
		-s $(GDUNIT4_SCRIPT) \
		-a "res://$(FILE)" \
		--ignoreHeadlessMode

## Lint all GDScript files with gdtoolkit.
lint:
	gdlint scripts/ tests_gdunit4/

## Static analysis check (gdtoolkit format check).
check:
	gdformat --check scripts/ tests_gdunit4/

## Bump version using conventional commits and generate changelog.
bump:
	cz bump --changelog

## Set up development environment (requires .NET runtime and Python 3).
setup:
	git config core.hooksPath tools/hooks
	uv tool install gdtoolkit
	uv tool install pre-commit
	uv tool install commitizen
	pre-commit install
	dotnet tool install --global Chickensoft.GodotEnv
	godotenv godot install
	godotenv godot use
