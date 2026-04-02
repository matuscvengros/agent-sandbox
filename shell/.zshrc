# Claude Docker Sandbox launcher
# Usage: cc [options] [-- extra args passed to claude/container]
#   cc                  Run Claude with persistent state
#   cc -is, --isolated  Run Claude in ephemeral mode (no host state)
#   cc -b, --bash       Drop into a bash shell instead of Claude
cc() {
    local -a compose=(docker compose -f "$DOCKER_SANDBOX_DIR/docker-compose.yml")
    local project_name
    project_name="$(basename "$PWD")"

    local mode="persistent"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -is|--isolated) mode="isolated"; shift ;;
            -b|--bash)      mode="bash";     shift ;;
            --)             shift; break ;;
            *)              break ;;
        esac
    done

    case "$mode" in
        isolated)
            PROJECT_NAME="$project_name" "${compose[@]}" run --rm claude-sandbox claude "$@"
            ;;
        bash)
            PROJECT_NAME="$project_name" "${compose[@]}" run --rm claude-sandbox "$@"
            ;;
        persistent)
            PROJECT_NAME="$project_name" "${compose[@]}" run --rm \
                -v /Users/agents/.claude:/home/claude/.claude \
                -v /Users/agents/.claude.json:/home/claude/.claude.json \
                -v /Users/agents/.config:/home/claude/.config \
                claude-sandbox \
                claude --dangerously-skip-permissions "$@"
            ;;
    esac
}
