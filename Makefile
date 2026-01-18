# This file is for you! Edit it to implement your own hooks (make targets) into
# the project as automated steps to be executed locally and in the CD pipeline.

include scripts/init.mk

# ==============================================================================
# Project-specific targets

format: # Auto-format code @Quality
	# No formatting required for this repository

lint-file-format: # Check file formats @Quality
	check=all ./scripts/githooks/check-file-format.sh && echo "file format: ok"

lint-markdown-format: # Check markdown formatting @Quality
	check=all ./scripts/githooks/check-markdown-format.sh && echo "markdown format: ok"

lint-markdown-links: # Check markdown links @Quality
	output=$$(check=all ./scripts/githooks/check-markdown-links.sh 2>&1) && echo "markdown links: ok" || { echo "$$output"; exit 1; }

lint: # Run linter to check code style and errors @Quality
	$(MAKE) lint-file-format
	$(MAKE) lint-markdown-format
	$(MAKE) lint-markdown-links

test: # Run all tests @Testing
	# No tests required for this repository

clone-rt: # Clone the repository template into .github/skills/repository-template @Operations
	.github/skills/repository-template/scripts/git-clone-repository-template.sh

specify: # Re-initialise speck-kit files @Operations
	specify init \
		--ai copilot \
		--script sh \
		--ignore-agent-tools \
		--no-git \
		--here \
		--force

apply: # Copy prompt files assets to a destination repository; mandatory: dest=[path] @Operations
	if [ -z "$(dest)" ]; then
		echo "Error: dest argument is required. Usage: make apply dest=/path/to/destination"
		exit 1
	fi
	./scripts/apply.sh "$(dest)"

count-tokens: # Count LLM tokens for key instruction packs; optional: args=[files/options] @Operations
	uv run --with tiktoken python scripts/count-tokens.py \
		$(if $(args),$(args), \
			--sort-by tokens \
			.github/copilot-instructions.md \
			.specify/memory/constitution.md \
			.github/instructions/makefile.instructions.md \
			.github/instructions/shell.instructions.md \
			.github/instructions/docker.instructions.md \
			.github/instructions/python.instructions.md \
			.github/instructions/typescript.instructions.md \
			.github/instructions/terraform.instructions.md \
			.github/instructions/includes \
		)

clean:: # Remove project-specific generated files (main) @Operations
	rm -rf \
		.github/skills/repository-template/assets \
		docs/codebase-overview \
		docs/prompt-reports
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
	clone-rt \
	config \
	count-tokens \
	format \
	lint \
	lint-file-format \
	lint-markdown-format \
	lint-markdown-links \
	test \
