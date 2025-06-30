#!/usr/bin/env bash

CONFIG_FILE="$HOME/.pullallrc"
HARDCODED_DEFAULT_DIR="/Users/$USER/repo"

DEFAULT_DIR="$HARDCODED_DEFAULT_DIR"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

show_help() {
    cat << EOF
pull-all 🌀

Usage:
  pull-all [directory]                     Pull all Git repos in given directory or default
  pull-all run [directory]                 (Same as above)
  pull-all --exclude dir1,dir2 [directory] Pull all Git repos except specified directories
  pull-all set-default <dir>              Set default directory persistently
  pull-all get-default                    Show current default directory
  pull-all help                           Show this help message

Examples:
  pull-all
  pull-all ~/projects
  pull-all --exclude node_modules,vendor ~/code
  pull-all set-default ~/code
  pull-all get-default
EOF
}

set_default() {
    local new_dir="$1"
    if [[ -z "$new_dir" ]]; then
        echo "❌ Error: No directory provided."
        echo "Usage: pull-all set-default <directory>"
        exit 1
    fi
    echo "DEFAULT_DIR=\"$new_dir\"" > "$CONFIG_FILE"
    echo "✅ Default directory set to: $new_dir"
}

get_default() {
    if [[ -z "$DEFAULT_DIR" ]]; then
        echo "ℹ️ No default directory set."
    else
        echo "📁 Current default directory: $DEFAULT_DIR"
    fi
}

run_pull() {
    local base_dir="$1"
    local excluded_dirs="$2"
    if [[ -z "$base_dir" ]]; then
        base_dir="$DEFAULT_DIR"
    fi

    local exclude_args=""
    if [[ ! -z "$excluded_dirs" ]]; then
        IFS=',' read -ra ADDR <<< "$excluded_dirs"
        for dir in "${ADDR[@]}"; do
            # Trim whitespace
            dir=$(echo "$dir" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            exclude_args="$exclude_args -not -path '*/$dir/*'"
        done
    fi

    echo "🔍 Scanning for Git repos in: $base_dir"
    if [[ ! -z "$excluded_dirs" ]]; then
        echo "🚫 Excluding directories: $excluded_dirs"
    fi

    if [[ -z "$exclude_args" ]]; then
        find "$base_dir" -type d -name ".git" | while read -r gitdir; do
            process_repo "$gitdir"
        done
    else
        eval "find \"$base_dir\" -type d -name \".git\" $exclude_args" | while read -r gitdir; do
            process_repo "$gitdir"
        done
    fi
}

process_repo() {
    local gitdir="$1"
    local repo_dir="$(dirname "$gitdir")"
        echo -e "\n👉 Pulling in: $repo_dir"

        (
            cd "$repo_dir" || exit

            default_branch=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')
            current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

            if [[ "$current_branch" != "$default_branch" ]]; then
                echo "🔁 Switching to $default_branch from $current_branch"
                git switch "$default_branch" 2>/dev/null || git checkout "$default_branch"
            fi

            echo "⬇️ Pulling latest changes from origin/$default_branch"
            git pull
        )
        echo "✅ Pulled latest changes from origin/$default_branch"
}

EXCLUDED_DIRS=""
COMMAND="$1"
shift || true

if [[ "$1" == "--exclude" ]]; then
    EXCLUDED_DIRS="$2"
    shift 2
fi

if [[ "$COMMAND" != "run" && "$COMMAND" != "set-default" && "$COMMAND" != "get-default" && "$COMMAND" != "help" && "$COMMAND" != "-h" && "$COMMAND" != "--help" ]]; then
    if [[ -d "$COMMAND" || "$COMMAND" =~ ^[.~\/] ]]; then
        run_pull "$COMMAND" "$EXCLUDED_DIRS"
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
        run_pull "$1" "$EXCLUDED_DIRS"
        ;;
    *)
        echo "❌ Unknown command or invalid directory: $COMMAND"
        echo "Use 'pull-all help' to see available options."
        exit 1
        ;;
esac
