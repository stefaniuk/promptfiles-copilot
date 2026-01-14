# This file is for you! Edit it to implement your own hooks (make targets) into
# the project as automated steps to be executed locally and in the CD pipeline.

include scripts/init.mk

# ==============================================================================
# Project-specific targets

format: # Auto-format code @Quality
	# No formatting required for this repository

lint: # Run linter to check code style and errors @Quality
	check=all ./scripts/githooks/check-file-format.sh
	check=all ./scripts/githooks/check-markdown-format.sh

test: # Run all tests @Testing
	# No tests required for this repository

apply: # Copy prompt files assets to a destination repository; mandatory: dest=[path] @Operations
	if [ -z "$(dest)" ]; then
		echo "Error: dest argument is required. Usage: make apply dest=/path/to/destination"
		exit 1
	fi
	./scripts/apply.sh "$(dest)"

clean:: # Remove project-specific generated files (main) @Operations
	rm -rf .github/skills/repository-template/assets
	find . \( \
		-name ".coverage" -o \
		-name ".env" -o \
		-name "*.log" -o \
		-name "coverage.xml" \
	\) -prune -exec rm -rf {} +

config:: # Configure development environment (main) @Configuration
	make _install-dependencies
	.github/skills/repository-template/scripts/git-clone-repository-template.sh

# ==============================================================================

${VERBOSE}.SILENT: \
	apply \
	clean \
	config \
	format \
	lint \
	test \
