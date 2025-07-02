#!/usr/bin/env bash

CONFIG_FILE="$HOME/.pullallrc"
HARDCODED_DEFAULT_DIR="/Users/$USER/repo"

DEFAULT_DIR="$HARDCODED_DEFAULT_DIR"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

show_help() {
    cat << EOF
pull-all 🌀

Usage:
  pull-all [directory]           Pull all Git repos in given directory or default
  pull-all run [directory]       (Same as above)
  pull-all -p|--parallel [dir]   Pull all repos in parallel
  pull-all set-default <dir>     Set default directory persistently
  pull-all get-default           Show current default directory
  pull-all help                  Show this help message

Note: The -p or --parallel flag can be placed anywhere in the command

Examples:
  pull-all
  pull-all ~/projects
  pull-all -p ~/projects
  pull-all ~/projects -p
  pull-all --parallel
  pull-all run -p ~/projects
  pull-all run ~/projects --parallel
  pull-all set-default ~/code
  pull-all get-default
EOF
}

set_default() {
    local new_dir="$1"
    if [[ -z "$new_dir" ]]; then
        echo "❌ No directory provided"
        exit 1
    fi
    echo "DEFAULT_DIR=\"$new_dir\"" > "$CONFIG_FILE"
    echo "✅ Default directory set to: $new_dir"
}

get_default() {
    echo "📁 Current default directory: $DEFAULT_DIR"
}

pull_single_repo() {
    local repo_dir="$1"

    # Buffer output for clean display
    local output=""
    output+="\n👉 Pulling in: $repo_dir"

    cd "$repo_dir" || exit

    local default_branch=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')
    local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

    if [[ "$current_branch" != "$default_branch" ]]; then
    output+="\n🔁 Switching to $default_branch from $current_branch"
        git switch "$default_branch" 2>/dev/null || git checkout "$default_branch"
    fi

    output+="\n⬇️ Pulling latest changes from origin/$default_branch"
    local pull_output=$(git pull 2>&1)
    output+="\n$pull_output"

    # Output everything at once
    echo -e "$output"
}

run_pull() {
    local base_dir="$1"
    local parallel="$2"

    if [[ -z "$base_dir" ]]; then
        base_dir="$DEFAULT_DIR"
    fi

    echo "🔍 Scanning for Git repos in: $base_dir"

    if [[ "$parallel" == "true" ]]; then
        echo "⚡ Running in parallel mode"

        # Use process substitution instead of pipeline to avoid subshell
        while read -r gitdir; do
            repo_dir="$(dirname "$gitdir")"
            (
                pull_single_repo "$repo_dir"
            ) &
        done < <(find "$base_dir" -type d -name ".git")

        wait
        echo "✅ All parallel operations completed"
    else
        find "$base_dir" -type d -name ".git" | while read -r gitdir; do
            repo_dir="$(dirname "$gitdir")"
            (
                pull_single_repo "$repo_dir"
            )
        done
    fi
}

# Argument parsing

COMMAND=""
PARALLEL=false
NEW_ARGS=()

for arg in "$@"; do
    if [[ "$arg" == "-p" || "$arg" == "--parallel" ]]; then
        PARALLEL=true
    else
        NEW_ARGS+=("$arg")
    fi
done

set -- "${NEW_ARGS[@]}"
COMMAND="$1"
shift || true

if [[ "$COMMAND" != "run" && "$COMMAND" != "set-default" && "$COMMAND" != "get-default" && "$COMMAND" != "help" && "$COMMAND" != "-h" && "$COMMAND" != "--help" ]]; then
    if [[ -d "$COMMAND" || "$COMMAND" =~ ^[.~\/] ]]; then
        run_pull "$COMMAND" "$PARALLEL"
        exit 0
    fi
fi

case "$COMMAND" in
    help|-h|--help)
        show_help
        ;;
    set-default)
        set_default "$1"
        ;;
    get-default)
        get_default
        ;;
    run|"")
    run_pull "$1" "$PARALLEL"
        ;;
    *)
        echo "❌ Unknown command or invalid directory: $COMMAND"
        echo "Use 'pull-all help' to see available options."
        exit 1
        ;;
esac
