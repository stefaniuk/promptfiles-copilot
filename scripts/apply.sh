#!/usr/bin/env bash
#
# Copy prompt files assets to a destination repository
#
# Usage: ./scripts/apply.sh <destination-directory>
#
# Copies:
#   - Agent files
#   - Instruction files
#   - Prompt files
#   - Skills files
#   - copilot-instructions.md
#   - constitution.md
#   - adr-template.md
#   - docs/.gitignore

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source directories
AGENTS_DIR="${REPO_ROOT}/.github/agents"
INSTRUCTIONS_DIR="${REPO_ROOT}/.github/instructions"
PROMPTS_DIR="${REPO_ROOT}/.github/prompts"
SKILLS_DIR="${REPO_ROOT}/.github/skills"
COPILOT_INSTRUCTIONS="${REPO_ROOT}/.github/copilot-instructions.md"
CONSTITUTION="${REPO_ROOT}/.specify/memory/constitution.md"
ADR_TEMPLATE="${REPO_ROOT}/docs/adr/adr-template.md"
DOCS_GITIGNORE="${REPO_ROOT}/docs/.gitignore"

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

usage() {
    cat <<EOF
Usage: $(basename "$0") <destination-directory>

Copy prompt files assets to a destination repository.

Arguments:
    destination-directory   Target directory (absolute or relative path)

Examples:
    $(basename "$0") /path/to/my-project
    $(basename "$0") ../my-project
    $(basename "$0") ~/projects/my-app
EOF
}

error() {
    echo "Error: $1" >&2
    exit 1
}

info() {
    echo "→ $1"
}

copy_agents() {
    local dest_agents="$1/.github/agents"
    mkdir -p "${dest_agents}"

    info "Copying agent files to ${dest_agents}"
    find "${AGENTS_DIR}" -maxdepth 1 -name "*.md" -type f -exec cp {} "${dest_agents}/" \;
}

copy_instructions() {
    local dest_instructions="$1/.github/instructions"
    mkdir -p "${dest_instructions}"

    info "Copying instruction files to ${dest_instructions}"

    # Copy top-level instruction files
    find "${INSTRUCTIONS_DIR}" -maxdepth 1 -name "*.md" -type f -exec cp {} "${dest_instructions}/" \;

    # Copy include directory if it exists
    if [[ -d "${INSTRUCTIONS_DIR}/include" ]]; then
        mkdir -p "${dest_instructions}/include"
        find "${INSTRUCTIONS_DIR}/include" -name "*.md" -type f -exec cp {} "${dest_instructions}/include/" \;
    fi
}

copy_prompts() {
    local dest_prompts="$1/.github/prompts"
    mkdir -p "${dest_prompts}"

    info "Copying prompt files to ${dest_prompts}"
    find "${PROMPTS_DIR}" -maxdepth 1 -name "*.prompt.md" -type f -exec cp {} "${dest_prompts}/" \;
}

copy_skills() {
    local dest_skills="$1/.github/skills"
    mkdir -p "${dest_skills}"

    info "Copying skills files to ${dest_skills}"
    find "${SKILLS_DIR}" -maxdepth 1 -name "*.md" -type f -exec cp {} "${dest_skills}/" \;
}

copy_copilot_instructions() {
    local dest="$1/.github"
    mkdir -p "${dest}"

    info "Copying copilot-instructions.md to ${dest}"
    cp "${COPILOT_INSTRUCTIONS}" "${dest}/"
}

copy_constitution() {
    local dest="$1/.specify/memory"
    mkdir -p "${dest}"

    info "Copying constitution.md to ${dest}"
    cp "${CONSTITUTION}" "${dest}/"
}

copy_adr_template() {
    local dest="$1/docs/adr"
    mkdir -p "${dest}"

    info "Copying adr-template.md to ${dest}"
    cp "${ADR_TEMPLATE}" "${dest}/"
}

copy_docs_gitignore() {
    local dest="$1/docs"
    mkdir -p "${dest}"

    info "Copying docs/.gitignore to ${dest}"
    cp "${DOCS_GITIGNORE}" "${dest}/"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
    if [[ $# -ne 1 ]]; then
        usage
        exit 1
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
        error "Destination directory cannot be empty"
    fi

    # Create destination if it doesn't exist
    if [[ ! -d "${destination}" ]]; then
        info "Creating destination directory: ${destination}"
        mkdir -p "${destination}"
    fi

    echo "Applying prompt files to: ${destination}"
    echo

    copy_agents "${destination}"
    copy_instructions "${destination}"
    copy_prompts "${destination}"
    copy_skills "${destination}"
    copy_copilot_instructions "${destination}"
    copy_constitution "${destination}"
    copy_adr_template "${destination}"
    copy_docs_gitignore "${destination}"

    echo
    echo "Done. Assets copied to ${destination}"
}

main "$@"
