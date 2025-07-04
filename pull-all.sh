#!/usr/bin/env bash

CONFIG_FILE="$HOME/.pullallrc"
HARDCODED_DEFAULT_DIR="$HOME/repo"

DEFAULT_DIR="$HARDCODED_DEFAULT_DIR"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

show_help() {
    cat << EOF
pull-all 🌀

Usage:
  pull-all [directory]               Pull all Git repos in given directory or default
  pull-all run [directory]           (Same as above)
  pull-all -p|--parallel [dir]       Pull all repos in parallel
  pull-all -m|--merge-master         Merge master into current branch (if conflict-free)
  pull-all set-default <dir>         Set default directory persistently
  pull-all get-default               Show current default directory
  pull-all help                      Show this help message

Note: The -p / --parallel and -m / --merge-master flags can be placed anywhere

Examples:
  pull-all
  pull-all ~/projects
  pull-all -p ~/projects
  pull-all ~/projects -pm
  pull-all --parallel --merge-master
  pull-all run ~/projects -m
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
    local do_merge="$2"

    local output=""
    output+="\n👉 Pulling in: $repo_dir"

    if ! git -C "$repo_dir" rev-parse --is-inside-work-tree &>/dev/null; then
        output+="\n❌ Not a valid Git repository"
        echo -e "$output"
        return
    fi

    local default_branch=$(git -C "$repo_dir" remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')
    local current_branch=$(git -C "$repo_dir" symbolic-ref --short HEAD 2>/dev/null)

    if [[ "$current_branch" != "$default_branch" ]]; then
        output+="\n🔁 Switching to $default_branch from $current_branch"
        git -C "$repo_dir" switch "$default_branch" 2>/dev/null || git -C "$repo_dir" checkout "$default_branch"
    fi

    output+="\n⬇️ Pulling latest changes from origin/$default_branch"
    local pull_output=$(git -C "$repo_dir" pull 2>&1)
    output+="\n$pull_output"

    if [[ "$do_merge" == "true" ]]; then
        # Aktif olmayan branch'e geri geç ve merge et
        if [[ "$current_branch" != "$default_branch" ]]; then
            git -C "$repo_dir" switch "$current_branch" 2>/dev/null || git -C "$repo_dir" checkout "$current_branch"
            output+="\n🔀 Trying to merge origin/$default_branch into $current_branch..."

            git -C "$repo_dir" fetch origin "$default_branch" &>/dev/null
            git -C "$repo_dir" merge "origin/$default_branch" --no-edit &>/dev/null

            if [[ $? -eq 0 ]]; then
                output+="\n✅ Merge successful"
            else
                output+="\n⚠️ Conflict detected, aborting merge"
                git -C "$repo_dir" merge --abort &>/dev/null
            fi
        fi
    fi

    echo -e "$output"
}

run_pull() {
    local base_dir="$1"
    local parallel="$2"
    local do_merge="$3"

    if [[ -z "$base_dir" ]]; then
        base_dir="$DEFAULT_DIR"
    fi

    echo "🔍 Scanning for Git repos in: $base_dir"

    if [[ "$parallel" == "true" ]]; then
        echo "⚡ Running in parallel mode"
        while read -r gitdir; do
            repo_dir="$(dirname "$gitdir")"
            (
                pull_single_repo "$repo_dir" "$do_merge"
            ) &
        done < <(find "$base_dir" -type d -name ".git")
        wait
        echo "✅ All parallel operations completed"
    else
        find "$base_dir" -type d -name ".git" | while read -r gitdir; do
            repo_dir="$(dirname "$gitdir")"
            pull_single_repo "$repo_dir" "$do_merge"
        done
    fi
}

# Argument parsing
COMMAND=""
PARALLEL=false
MERGE_MASTER=false
NEW_ARGS=()

for arg in "$@"; do
    case "$arg" in
        -p|--parallel)
            PARALLEL=true
            ;;
        -m|--merge-master)
            MERGE_MASTER=true
            ;;
        *)
            NEW_ARGS+=("$arg")
            ;;
    esac
done

set -- "${NEW_ARGS[@]}"
COMMAND="$1"
shift || true

if [[ "$COMMAND" != "run" && "$COMMAND" != "set-default" && "$COMMAND" != "get-default" && "$COMMAND" != "help" && "$COMMAND" != "-h" && "$COMMAND" != "--help" ]]; then
    if [[ -d "$COMMAND" || "$COMMAND" =~ ^[.~\/] ]]; then
        run_pull "$COMMAND" "$PARALLEL" "$MERGE_MASTER"
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
        run_pull "$1" "$PARALLEL" "$MERGE_MASTER"
        ;;
    *)
        echo "❌ Unknown command or invalid directory: $COMMAND"
        echo "Use 'pull-all help' to see available options."
        exit 1
        ;;
esac
