#!/usr/bin/env sh

# Fail on error
set -o errexit
# Disable wildcard character expansion
set -o noglob
# Disable uninitialized variable usage
set -o nounset
# Disable error masking in pipe
# shellcheck disable=SC3040
if (set -o pipefail > /dev/null 2>&1); then
    set -o pipefail
fi

# ================
# LOGGER
# ================
# Error log level. Cause exit failure
LOG_LEVEL_ERROR=100
# Warning log level
LOG_LEVEL_WARN=200
# Informational log level
LOG_LEVEL_INFO=300
# Debug log level
LOG_LEVEL_DEBUG=400
# Log level
LOG_LEVEL=$LOG_LEVEL_INFO
# Log color flag
LOG_COLOR_ENABLE=true

# Convert log level to equivalent name
# @param $1 Log level
log_level_name() {
    _log_level=${1:-LOG_LEVEL}
    _log_level_name=

    case $_log_level in
        "$LOG_LEVEL_ERROR") _log_level_name=error ;;
        "$LOG_LEVEL_WARN") _log_level_name=warn ;;
        "$LOG_LEVEL_INFO") _log_level_name=info ;;
        "$LOG_LEVEL_DEBUG") _log_level_name=debug ;;
        *) ERROR "Unknown log level '$_log_level'" ;;
    esac

    printf '%s\n' "$_log_level_name"
}

# Check if log level is enabled
# @param $1 Log level
log_is_enabled() {
    [ "$1" -le "$LOG_LEVEL" ]
}

# Print log message
# @param $1 Log level
# @param $2 Message
_log_print_message() {
    _log_level=${1:-LOG_LEVEL_ERROR}
    shift
    _log_level_name=
    _log_message=${*:-}
    _log_prefix=
    _log_suffix="\033[0m"

    # Check log level
    log_is_enabled "$_log_level" || return 0

    case $_log_level in
        "$LOG_LEVEL_ERROR")
            _log_level_name=ERROR
            _log_prefix="\033[1;31m"
            ;;
        "$LOG_LEVEL_WARN")
            _log_level_name=WARN
            _log_prefix="\033[1;33m"
            ;;
        "$LOG_LEVEL_INFO")
            _log_level_name=INFO
            _log_prefix="\033[1;37m"
            ;;
        "$LOG_LEVEL_DEBUG")
            _log_level_name=DEBUG
            _log_prefix="\033[1;34m"
            ;;
    esac

    # Check color flag
    if [ "$LOG_COLOR_ENABLE" = false ]; then
        _log_prefix=
        _log_suffix=
    fi

    # Log
    printf '%b[%-5s] %b%b\n' "$_log_prefix" "$_log_level_name" "$_log_message" "$_log_suffix"
}

# Error log message
# @param $1 Message
ERROR() {
    _log_print_message "$LOG_LEVEL_ERROR" "$1" >&2
    exit 1
}
# Warning log message
# @param $1 Message
WARN() { _log_print_message "$LOG_LEVEL_WARN" "$1" >&2; }
# Informational log message
# @param $1 Message
INFO() { _log_print_message "$LOG_LEVEL_INFO" "$1"; }
# Debug log message
# @param $1 Message
DEBUG() { _log_print_message "$LOG_LEVEL_DEBUG" "$1"; }

# ================
# FUNCTIONS
# ================
# Assert command is installed
# @param $1 Command name
assert_cmd() {
    check_cmd "$1" || ERROR "Command '$1' not found"
    DEBUG "Command '$1' found at '$(command -v "$1")'"
}

# Check command is installed
# @param $1 Command name
check_cmd() {
    command -v "$1" > /dev/null 2>&1
}

# Show help message
show_help() {
    cat << EOF
Usage: ${0##*/}
         [--disable-color] [--git-dir <DIR>] [--help]
         [--log-level <LEVEL>]

.gitattributes checker.

Options:
  --disable-color        Disable color

  --git-dir <DIR>        Git directory
                         Default: $GIT_DIR

  --help                 Show this help message and exit

  --log-level <LEVEL>    Logger level
                         Default: $(log_level_name "$LOG_LEVEL")
                         Values:
                           error    Error level
                           warn     Warning level
                           info     Informational level
                           debug    Debug level
EOF
}

# Assert argument has a value
# @param $1 Argument name
# @param $2 Argument value
_parse_args_assert_value() {
    [ -n "${2+x}" ] || ERROR "Argument '$1' requires a non-empty value"
}

# Parse command line arguments
# @param $@ Arguments
parse_args() {
    while [ $# -gt 0 ]; do
        case $1 in
            --disable-color)
                # Disable color
                LOG_COLOR_ENABLE=false
                shift
                ;;
            --git-dir)
                # Git directory
                _parse_args_assert_value "$@"
                _git_dir=$2
                # Append .git if not present
                [ "$(basename "$_git_dir")" = ".git" ] || _git_dir="$_git_dir/.git"
                GIT_DIR=$_git_dir
                shift
                shift
                ;;
            --help)
                # Display help message and exit
                show_help
                exit 0
                ;;
            --log-level)
                # Log level
                _parse_args_assert_value "$@"
                case $2 in
                    error) LOG_LEVEL=$LOG_LEVEL_ERROR ;;
                    warn) LOG_LEVEL=$LOG_LEVEL_WARN ;;
                    info) LOG_LEVEL=$LOG_LEVEL_INFO ;;
                    debug) LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
                    *) ERROR "Value '$2' of argument '$1' is invalid" ;;
                esac
                shift
                shift
                ;;
        -*)
            # Unknown argument
            WARN "Unknown argument '$1' is ignored"
            shift
            ;;
        *)
            # No argument
            WARN "Skipping argument '$1'"
            shift
            ;;
        esac
    done
}

# Verify system
verify_system() {
    assert_cmd git

    [ -d "$GIT_DIR" ] || ERROR "Git directory '$GIT_DIR' does not exists"
}

# Verify gitattributes
verify_gitattributes() {
    _missing_attributes=$(git "--git-dir=$GIT_DIR" ls-files | git "--git-dir=$GIT_DIR" check-attr --all --stdin | grep 'text: auto' || printf '\n')

    if [ -n "$_missing_attributes" ]; then
        ERROR ".gitattributes rule missing for the following files:\n$_missing_attributes"
    else
        INFO "All files have a corresponding rule in .gitattributes"
    fi
}

# ================
# CONFIGURATION
# ================
# Git directory
GIT_DIR=".git"
# Log level
LOG_LEVEL=$LOG_LEVEL_INFO
# Log color flag
LOG_COLOR_ENABLE=true

# ================
# MAIN
# ================
{
    parse_args "$@"
    verify_system
    verify_gitattributes
}
