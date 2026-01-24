#!/bin/bash

set -euo pipefail

# Copy prompt files assets to a destination repository.
#
# Usage:
#   $ [options] ./scripts/apply.sh <destination-directory>
#
# Arguments:
#   destination-directory   Target directory (absolute or relative path)
#
# Options:
#   wipe=true               # Remove destination .github/{agents,instructions,prompts,skills} before copying, default is 'false'
#   VERBOSE=true            # Show all the executed commands, default is 'false'
#
# Technology switches (default is 'false' for all, set to 'true' to include):
#   all=true                # Include all technology-specific files
#   python=true             # Include Python instruction and enforcement prompt
#   typescript=true         # Include TypeScript instruction and enforcement prompt
#   react=true              # Include React instruction and enforcement prompt
#   rust=true               # Include Rust instruction and enforcement prompt
#   terraform=true          # Include Terraform instruction and enforcement prompt
#   tauri=true              # Include Tauri instruction and enforcement prompt (auto-enables rust, typescript, react)
#   playwright=true         # Include Playwright instruction and prompt (requires python or typescript)
#   django=true             # Include Django skill (auto-enables python)
#   fastapi=true            # Include FastAPI skill (auto-enables python)
#
# Always copied (default/glue layer):
#   - All spec-kit agents (.github/agents)
#   - Shell, Docker, Makefile instructions and prompts
#   - Codebase documentation prompts (codebase.*)
#   - Spec-kit prompts (speckit.*, review.speckit-*)
#   - Utility prompts (util.*)
#   - Shared includes (baselines)
#   - Default templates (Makefile, Dockerfile, compose.yaml, shell-script)
#   - repository-template skill
#   - copilot-instructions.md
#   - pull_request_template.md (if not already present)
#   - constitution.md
#   - .specify/scripts/bash
#   - .specify/templates
#   - adr-template.md
#   - docs/codebase-overview/
#   - docs/prompts/
#   - project.code-workspace (if not already present)
#
# Exit codes:
#   0 - All files copied successfully
#   1 - Missing or invalid arguments
#
# Examples:
#   $ ./scripts/apply.sh /path/to/my-project
#   $ python=true ./scripts/apply.sh ../my-project
#   $ all=true ./scripts/apply.sh ~/projects/my-app
#   $ python=true playwright=true ./scripts/apply.sh ~/projects/my-app
#   $ django=true ./scripts/apply.sh ~/projects/my-app  # auto-enables python

# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

AGENTS_DIR="${REPO_ROOT}/.github/agents"
INSTRUCTIONS_DIR="${REPO_ROOT}/.github/instructions"
PROMPTS_DIR="${REPO_ROOT}/.github/prompts"
SKILLS_DIR="${REPO_ROOT}/.github/skills"
COPILOT_INSTRUCTIONS="${REPO_ROOT}/.github/copilot-instructions.md"
PULL_REQUEST_TEMPLATE="${REPO_ROOT}/.github/pull_request_template.md"
CONSTITUTION="${REPO_ROOT}/.specify/memory/constitution.md"
SPECIFY_SCRIPTS_BASH="${REPO_ROOT}/.specify/scripts/bash"
SPECIFY_TEMPLATES="${REPO_ROOT}/.specify/templates"
ADR_TEMPLATE="${REPO_ROOT}/docs/adr/adr-template.md"
DOCS_CODEBASE_OVERVIEW="${REPO_ROOT}/docs/codebase-overview"
DOCS_PROMPTS="${REPO_ROOT}/docs/prompts"
WORKSPACE_FILE="${REPO_ROOT}/project.code-workspace"

# Default instruction files (glue layer)
DEFAULT_INSTRUCTIONS=("docker" "makefile" "shell")

# Default prompt patterns (glue layer and spec-kit)
DEFAULT_PROMPT_PATTERNS=("codebase.*" "enforce.docker" "enforce.makefile" "enforce.shell" "review.speckit-*" "speckit.*" "util.*")

# Default templates (glue layer)
DEFAULT_TEMPLATES=("Makefile.template" "Dockerfile.template" "compose.yaml.template" "shell-script.template.sh")

# Default skills
DEFAULT_SKILLS=("repository-template")

# All technology switches (for iteration)
ALL_TECHS=("python" "typescript" "react" "rust" "terraform" "tauri" "playwright" "django" "fastapi")

# ==============================================================================

# Get instruction file name for a technology.
# For playwright, returns the appropriate variant based on python/typescript being enabled.
# Arguments:
#   $1=[technology name]
function get-tech-instruction() {

  case "$1" in
    python) echo "python" ;;
    typescript) echo "typescript" ;;
    react) echo "reactjs" ;;
    rust) echo "rust" ;;
    terraform) echo "terraform" ;;
    tauri) echo "tauri" ;;
    playwright)
      # Return both variants if applicable
      local result=""
      if is-arg-true "${python:-false}" || is-arg-true "${all:-false}"; then
        result="playwright-python"
      fi
      if is-arg-true "${typescript:-false}" || is-arg-true "${all:-false}"; then
        [[ -n "${result}" ]] && result="${result} "
        result="${result}playwright-typescript"
      fi
      echo "${result}"
      ;;
    *) echo "" ;;
  esac
}

# Get prompt file name for a technology.
# For playwright, returns the appropriate variant based on python/typescript being enabled.
# Arguments:
#   $1=[technology name]
function get-tech-prompt() {

  case "$1" in
    python) echo "enforce.python" ;;
    typescript) echo "enforce.typescript" ;;
    react) echo "enforce.reactjs" ;;
    rust) echo "enforce.rust" ;;
    terraform) echo "enforce.terraform" ;;
    tauri) echo "enforce.tauri" ;;
    playwright)
      # Return both variants if applicable
      local result=""
      if is-arg-true "${python:-false}" || is-arg-true "${all:-false}"; then
        result="enforce.playwright-python"
      fi
      if is-arg-true "${typescript:-false}" || is-arg-true "${all:-false}"; then
        [[ -n "${result}" ]] && result="${result} "
        result="${result}enforce.playwright-typescript"
      fi
      echo "${result}"
      ;;
    *) echo "" ;;
  esac
}

# Get template file name for a technology.
# Arguments:
#   $1=[technology name]
function get-tech-template() {

  case "$1" in
    python) echo "pyproject.toml" ;;
    *) echo "" ;;
  esac
}

# Get skill directory name for a technology.
# Arguments:
#   $1=[technology name]
function get-tech-skill() {

  case "$1" in
    django) echo "django-project" ;;
    fastapi) echo "fastapi-project" ;;
    *) echo "" ;;
  esac
}

# ==============================================================================

# Main entry point for the script.
function main() {

  if [[ $# -ne 1 ]]; then
    print-usage
    exit 1
  fi

  # Auto-enable rust, typescript, and react if tauri is specified
  if is-arg-true "${tauri:-false}"; then
    rust=true
    typescript=true
    react=true
  fi

  # Auto-enable python if django or fastapi is specified
  if is-arg-true "${django:-false}" || is-arg-true "${fastapi:-false}"; then
    python=true
  fi

  # Validate playwright requires python or typescript (unless all=true)
  if is-arg-true "${playwright:-false}" && ! is-arg-true "${all:-false}"; then
    if ! is-arg-true "${python:-false}" && ! is-arg-true "${typescript:-false}"; then
      print-error "playwright=true requires either python=true or typescript=true to be set"
    fi
  fi

  local destination="$1"

  # Handle relative paths by converting to absolute
  if [[ "${destination}" != /* ]]; then
    destination="$(cd "$(pwd)" && cd "$(dirname "${destination}")" 2>/dev/null && pwd)/$(basename "${destination}")" || destination="$(pwd)/${destination}"
  fi

  # Expand ~ to home directory
  destination="${destination/#\~/$HOME}"

  # Validate destination
  if [[ -z "${destination}" ]]; then
    print-error "Destination directory cannot be empty"
  fi

  # Create destination if it doesn't exist
  if [[ ! -d "${destination}" ]]; then
    print-info "Creating destination directory: ${destination}"
    mkdir -p "${destination}"
  fi

  echo "Applying prompt files to: ${destination}"
  print-enabled-technologies
  echo

  if is-arg-true "${wipe:-false}"; then
    wipe-directories "${destination}"
  fi

  copy-agents "${destination}"
  copy-instructions "${destination}"
  copy-prompts "${destination}"
  copy-skills "${destination}"
  copy-copilot-instructions "${destination}"
  copy-pull-request-template "${destination}"
  copy-constitution "${destination}"
  copy-specify-scripts-bash "${destination}"
  copy-specify-templates "${destination}"
  copy-adr-template "${destination}"
  copy-docs-codebase-overview "${destination}"
  copy-docs-prompts "${destination}"
  copy-workspace-file "${destination}"

  echo
  echo "Done. Assets copied to ${destination}"
}

# ==============================================================================

# Print which technologies are enabled.
function print-enabled-technologies() {

  local techs=()

  if is-arg-true "${all:-false}"; then
    techs+=("all")
  else
    for tech in "${ALL_TECHS[@]}"; do
      local var_value
      eval "var_value=\${${tech}:-false}"
      if is-arg-true "${var_value}"; then
        techs+=("${tech}")
      fi
    done
  fi

  if [[ ${#techs[@]} -eq 0 ]]; then
    echo "Technologies: default only (use all=true or individual switches to include more)"
  else
    echo "Technologies: default + ${techs[*]}"
  fi
}

# Check if a technology is enabled.
# Arguments:
#   $1=[technology name]
function is-tech-enabled() {

  local tech="$1"

  if is-arg-true "${all:-false}"; then
    return 0
  fi

  # Use indirect variable reference with default value
  local var_value
  eval "var_value=\${${tech}:-false}"
  if is-arg-true "${var_value}"; then
    return 0
  fi

  return 1
}

# Wipe target directories before copying.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function wipe-directories() {

  local dest="$1/.github"
  local dirs=("agents" "instructions" "prompts" "skills")

  for dir in "${dirs[@]}"; do
    if [[ -d "${dest}/${dir}" ]]; then
      print-info "Removing ${dest}/${dir}"
      rm -rf "${dest}/${dir}"
    fi
  done
}

# Copy agent files to the destination.
# All agents are spec-kit related and always copied.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-agents() {

  local dest_agents="$1/.github/agents"
  mkdir -p "${dest_agents}"

  print-info "Copying agent files to ${dest_agents}"
  find "${AGENTS_DIR}" -maxdepth 1 -name "*.md" -type f -exec cp {} "${dest_agents}/" \;
}

# Copy instruction files to the destination.
# Copies default instructions always, technology-specific ones based on switches.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-instructions() {

  local dest_instructions="$1/.github/instructions"
  mkdir -p "${dest_instructions}"

  print-info "Copying instruction files to ${dest_instructions}"

  # Copy default instruction files
  for instruction in "${DEFAULT_INSTRUCTIONS[@]}"; do
    local file="${INSTRUCTIONS_DIR}/${instruction}.instructions.md"
    if [[ -f "${file}" ]]; then
      cp "${file}" "${dest_instructions}/"
    fi
  done

  # Copy technology-specific instruction files
  for tech in "${ALL_TECHS[@]}"; do
    if is-tech-enabled "${tech}"; then
      local instructions
      instructions=$(get-tech-instruction "${tech}")
      if [[ -n "${instructions}" ]]; then
        # Handle space-separated list (for playwright)
        for instruction in ${instructions}; do
          local file="${INSTRUCTIONS_DIR}/${instruction}.instructions.md"
          if [[ -f "${file}" ]]; then
            cp "${file}" "${dest_instructions}/"
          fi
        done
      fi
    fi
  done

  # Copy includes directory (always - shared baselines)
  if [[ -d "${INSTRUCTIONS_DIR}/includes" ]]; then
    mkdir -p "${dest_instructions}/includes"
    cp -R "${INSTRUCTIONS_DIR}/includes/." "${dest_instructions}/includes/"
  fi

  # Copy templates directory (selective)
  if [[ -d "${INSTRUCTIONS_DIR}/templates" ]]; then
    mkdir -p "${dest_instructions}/templates"

    # Copy default templates
    for template in "${DEFAULT_TEMPLATES[@]}"; do
      local file="${INSTRUCTIONS_DIR}/templates/${template}"
      if [[ -f "${file}" ]]; then
        cp "${file}" "${dest_instructions}/templates/"
      fi
    done

    # Copy technology-specific templates
    for tech in "${ALL_TECHS[@]}"; do
      if is-tech-enabled "${tech}"; then
        local template
        template=$(get-tech-template "${tech}")
        if [[ -n "${template}" ]]; then
          local file="${INSTRUCTIONS_DIR}/templates/${template}"
          if [[ -f "${file}" ]]; then
            cp "${file}" "${dest_instructions}/templates/"
          fi
        fi
      fi
    done
  fi
}

# Copy prompt files to the destination.
# Copies default prompts always, technology-specific ones based on switches.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-prompts() {

  local dest_prompts="$1/.github/prompts"
  mkdir -p "${dest_prompts}"

  print-info "Copying prompt files to ${dest_prompts}"

  # Copy default prompt files using patterns
  for pattern in "${DEFAULT_PROMPT_PATTERNS[@]}"; do
    # Use find with -name to match patterns
    find "${PROMPTS_DIR}" -maxdepth 1 -name "${pattern}.prompt.md" -type f -exec cp {} "${dest_prompts}/" \; 2>/dev/null || true
  done

  # Copy technology-specific prompt files
  for tech in "${ALL_TECHS[@]}"; do
    if is-tech-enabled "${tech}"; then
      local prompts
      prompts=$(get-tech-prompt "${tech}")
      if [[ -n "${prompts}" ]]; then
        # Handle space-separated list (for playwright)
        for prompt in ${prompts}; do
          local file="${PROMPTS_DIR}/${prompt}.prompt.md"
          if [[ -f "${file}" ]]; then
            cp "${file}" "${dest_prompts}/"
          fi
        done
      fi
    fi
  done
}

# Copy skills files to the destination.
# Copies default skills always, technology-specific ones based on switches.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-skills() {

  local dest_skills="$1/.github/skills"
  mkdir -p "${dest_skills}"

  print-info "Copying skills files to ${dest_skills}"

  # Copy default skills
  for skill in "${DEFAULT_SKILLS[@]}"; do
    local skill_dir="${SKILLS_DIR}/${skill}"
    if [[ -d "${skill_dir}" ]]; then
      copy-directory-excluding-git "${skill_dir}" "${dest_skills}/${skill}"
    fi
  done

  # Copy technology-specific skills
  for tech in "${ALL_TECHS[@]}"; do
    if is-tech-enabled "${tech}"; then
      local skill
      skill=$(get-tech-skill "${tech}")
      if [[ -n "${skill}" ]]; then
        local skill_dir="${SKILLS_DIR}/${skill}"
        if [[ -d "${skill_dir}" ]]; then
          copy-directory-excluding-git "${skill_dir}" "${dest_skills}/${skill}"
        fi
      fi
    fi
  done
}

# Copy copilot-instructions.md to the destination.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-copilot-instructions() {

  local dest="$1/.github"
  mkdir -p "${dest}"

  print-info "Copying copilot-instructions.md to ${dest}"
  cp "${COPILOT_INSTRUCTIONS}" "${dest}/"
}

# Copy pull_request_template.md to the destination if missing.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-pull-request-template() {

  local dest_file="$1/.github/pull_request_template.md"
  mkdir -p "$(dirname "${dest_file}")"

  if [[ -f "${dest_file}" ]]; then
    print-info "Skipping pull_request_template.md (already exists)"
  else
    print-info "Copying pull_request_template.md to ${dest_file}"
    cp "${PULL_REQUEST_TEMPLATE}" "${dest_file}"
  fi
}

# Copy constitution.md to the destination.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-constitution() {

  local dest="$1/.specify/memory"
  mkdir -p "${dest}"

  print-info "Copying constitution.md to ${dest}"
  cp "${CONSTITUTION}" "${dest}/"
}

# Copy .specify/scripts/bash directory to the destination.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-specify-scripts-bash() {

  local dest="$1/.specify/scripts/bash"
  mkdir -p "${dest}"

  print-info "Copying .specify/scripts/bash to ${dest}"
  cp -R "${SPECIFY_SCRIPTS_BASH}/". "${dest}/"
}

# Copy .specify/templates directory to the destination.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-specify-templates() {

  local dest="$1/.specify/templates"
  mkdir -p "${dest}"

  print-info "Copying .specify/templates to ${dest}"
  cp -R "${SPECIFY_TEMPLATES}/". "${dest}/"
}

# Copy adr-template.md to the destination.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-adr-template() {

  local dest="$1/docs/adr"
  mkdir -p "${dest}"

  print-info "Copying adr-template.md to ${dest}"
  cp "${ADR_TEMPLATE}" "${dest}/"
}

# Copy docs/codebase-overview directory to the destination.
# Only copies .gitkeep if the destination directory is empty or doesn't exist.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-docs-codebase-overview() {

  local dest="$1/docs/codebase-overview"
  mkdir -p "${dest}"

  print-info "Copying docs/codebase-overview to ${dest}"

  # Check if destination directory has any files (excluding hidden files that start with .)
  local file_count
  file_count=$(find "${dest}" -maxdepth 1 -type f ! -name ".*" 2>/dev/null | wc -l | tr -d ' ')

  if [[ "${file_count}" -eq 0 ]]; then
    # Directory is empty, copy everything including .gitkeep
    cp -R "${DOCS_CODEBASE_OVERVIEW}/." "${dest}/"
  else
    # Directory has files, copy everything except .gitkeep
    find "${DOCS_CODEBASE_OVERVIEW}" -maxdepth 1 -type f ! -name ".gitkeep" -exec cp {} "${dest}/" \; 2>/dev/null || true
  fi
}

# Copy docs/prompts directory to the destination.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-docs-prompts() {

  local dest="$1/docs"
  mkdir -p "${dest}/prompts"

  print-info "Copying docs/prompts to ${dest}/prompts"
  cp -R "${DOCS_PROMPTS}/." "${dest}/prompts/"
  print-info "Creating docs/.gitignore"
  echo "prompts" > "${dest}/.gitignore"
}

# Copy project.code-workspace to the destination if it does not already exist.
# Arguments (provided as function parameters):
#   $1=[destination directory path]
function copy-workspace-file() {

  local dest_file="$1/project.code-workspace"

  if [[ -f "${dest_file}" ]]; then
    print-info "Skipping project.code-workspace (already exists)"
  else
    print-info "Copying project.code-workspace to $1"
    cp "${WORKSPACE_FILE}" "$1/"
  fi
}

# Copy a directory without bringing across any nested .git metadata.
# Arguments (provided as function parameters):
#   $1=[source directory path]
#   $2=[destination directory path]
function copy-directory-excluding-git() {

  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "${target_dir}"

  if command -v rsync > /dev/null 2>&1; then
    rsync -a --exclude='.git' --exclude='.git/' "${source_dir}/" "${target_dir}/"
  else
    tar -C "${source_dir}" --exclude='.git' -cf - . | tar -C "${target_dir}" -xf -
  fi

  return 0
}

# Print usage information.
function print-usage() {

  cat <<EOF
Usage: $(basename "$0") <destination-directory>

Copy prompt files assets to a destination repository.

Arguments:
    destination-directory   Target directory (absolute or relative path)

Technology switches (set to 'true' to include):
    all=true                Include all technology-specific files
    python=true             Python instruction and prompt
    typescript=true         TypeScript instruction and prompt
    react=true              React instruction and prompt
    rust=true               Rust instruction and prompt
    terraform=true          Terraform instruction and prompt
    tauri=true              Tauri instruction and prompt (auto-enables rust, typescript, react)
    playwright=true         Playwright instruction and prompt (requires python or typescript)
    django=true             Django skill (auto-enables python)
    fastapi=true            FastAPI skill (auto-enables python)

Other options:
    wipe=true               Remove destination directories before copying
    VERBOSE=true            Show all executed commands

Examples:
    $(basename "$0") /path/to/my-project
    python=true $(basename "$0") ../my-project
    all=true wipe=true $(basename "$0") ~/projects/my-app
    python=true playwright=true $(basename "$0") ~/projects/my-app
    django=true $(basename "$0") ~/projects/my-app  # auto-enables python
EOF
}

# Print an error message to stderr and exit.
# Arguments:
#   $1=[error message to display]
function print-error() {

  echo "Error: $1" >&2
  exit 1
}

# Print an informational message.
# Arguments:
#   $1=[message to display]
function print-info() {

  echo "→ $1"
}

# ==============================================================================

# Check if an argument is a truthy value.
# Arguments:
#   $1=[value to check]
function is-arg-true() {

  if [[ "$1" =~ ^(true|yes|y|on|1|TRUE|YES|Y|ON)$ ]]; then
    return 0
  else
    return 1
  fi
}

# ==============================================================================

is-arg-true "${VERBOSE:-false}" && set -x

main "$@"

exit 0
