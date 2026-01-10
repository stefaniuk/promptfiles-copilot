# ==============================================================================
# Development workflow targets
# ==============================================================================

format: # Auto-format code @CodeQuality
	# No formatting required for this repository

lint: # Run linter to check code style and errors @CodeQuality
	# No linting required for this repository

test: # Run all tests @Testing
	# No tests required for this repository

clean:: # Remove all generated and temporary files (common) @Development
	find . \( \
		-name ".coverage" -o \
		-name ".env" -o \
		-name "*.log" -o \
		-name "coverage.xml" \
	\) -prune -exec rm -rf {} +

# ==============================================================================
# Operations targets
# ==============================================================================

apply: # Copy prompt files assets to a destination repository; mandatory: dest=[path] @Operations
	@if [ -z "$(dest)" ]; then \
		echo "Error: dest argument is required. Usage: make apply dest=/path/to/destination"; \
		exit 1; \
	fi
	./scripts/apply.sh "$(dest)"

# ==============================================================================
# Helper targets (do not edit)
# ==============================================================================

help: # Print help @Others
	printf "\nUsage: \033[3m\033[93m[arg1=val1] [arg2=val2] \033[0m\033[0m\033[32mmake\033[0m\033[34m <command>\033[0m\n\n"
	perl -e '$(HELP_SCRIPT)' $(MAKEFILE_LIST)

list-variables: # List all the variables available to make @Others
	$(foreach v, $(sort $(.VARIABLES)),
		$(if $(filter-out default automatic, $(origin $v)),
			$(if $(and $(patsubst %_PASSWORD,,$v), $(patsubst %_PASS,,$v), $(patsubst %_KEY,,$v), $(patsubst %_SECRET,,$v)),
				$(info $v=$($v) ($(value $v)) [$(flavor $v),$(origin $v)]),
				$(info $v=****** (******) [$(flavor $v),$(origin $v)])
			)
		)
	)

# ==============================================================================
# Make configuration (do not edit)
# ==============================================================================

.DEFAULT_GOAL := help
.EXPORT_ALL_VARIABLES:
.NOTPARALLEL:
.ONESHELL:
.PHONY: * # Please do not change this line! The alternative usage of it introduces unnecessary complexity and is considered an anti-pattern.
MAKEFLAGS := --no-print-director
SHELL := /bin/bash
ifeq (true, $(shell [[ "${VERBOSE}" =~ ^(true|yes|y|on|1|TRUE|YES|Y|ON)$$ ]] && echo true))
	.SHELLFLAGS := -cex
else
	.SHELLFLAGS := -ce
endif
${VERBOSE}.SILENT:

# This script parses all the make target descriptions and renders the help output.
HELP_SCRIPT = \
	\
	use Text::Wrap; \
	%help_info; \
	my $$max_command_length = 0; \
	my $$terminal_width = `tput cols` || 120; chomp($$terminal_width); \
	\
	while(<>){ \
		next if /^_/; \
		\
		if (/^([\w-_]+)\s*:.*\#(.*?)(@(\w+))?\s*$$/) { \
			my $$command = $$1; \
			my $$description = $$2; \
			$$description =~ s/@\w+//; \
			my $$category_key = $$4 // 'Others'; \
			(my $$category_name = $$category_key) =~ s/(?<=[a-z])([A-Z])/\ $$1/g; \
			$$category_name = lc($$category_name); \
			$$category_name =~ s/^(.)/\U$$1/; \
			\
			push @{$$help_info{$$category_name}}, [$$command, $$description]; \
			$$max_command_length = (length($$command) > 37) ? 40 : $$max_command_length; \
		} \
	} \
	\
	my $$description_width = $$terminal_width - $$max_command_length - 4; \
	$$Text::Wrap::columns = $$description_width; \
	\
	for my $$category (sort { $$a eq 'Others' ? 1 : $$b eq 'Others' ? -1 : $$a cmp $$b } keys %help_info) { \
		print "\033[1m$$category\033[0m:\n\n"; \
		for my $$item (sort { $$a->[0] cmp $$b->[0] } @{$$help_info{$$category}}) { \
			my $$description = $$item->[1]; \
			my @desc_lines = split("\n", wrap("", "", $$description)); \
			my $$first_line_description = shift @desc_lines; \
			\
			$$first_line_description =~ s/(\w+)(\|\w+)?=/\033[3m\033[93m$$1$$2\033[0m=/g; \
			\
			my $$formatted_command = $$item->[0]; \
			$$formatted_command = substr($$formatted_command, 0, 37) . "..." if length($$formatted_command) > 37; \
			\
			print sprintf("  \033[0m\033[34m%-$${max_command_length}s\033[0m%s %s\n", $$formatted_command, $$first_line_description); \
			for my $$line (@desc_lines) { \
				$$line =~ s/(\w+)(\|\w+)?=/\033[3m\033[93m$$1$$2\033[0m=/g; \
				print sprintf(" %-$${max_command_length}s  %s\n", " ", $$line); \
			} \
			print "\n"; \
		} \
	}
