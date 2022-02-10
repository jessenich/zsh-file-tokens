#!/usr/bin/env bash

:token::main () {
    set -o errexit;
    set -o pipefail;
    set -o nounset;

    local -r __dirname="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
    local -r __filename="${__dirname}/$(basename "${BASH_SOURCE[0]}")";
    local -r index_file="${__dirname}/index.db";

    ::print_help() {
        cat <<'EOF'
Usage: token <name> [ <value> ]"
   token set github_token ghp_abcdef0123456789abcdef01234567

   Usage Examples:
      $ token get GITHUB_TOKEN"
      > ghp_abcdef0123456789abcdef01234567"

      $ token set GITHUB_TOKEN ghp_abcdef0123456789abcdef01234567"
      >

      $ token list
      > GITHUB_TOKEN:ghp_abcdef0123456789abcdef01234567
      > DOCKERHUB_TOKEN:dhp_abcdef0123456789abcdef01234567
EOF
    }

    ::init_db() {
        if ! builtin command -v sqlite3 >/dev/null; then
            echo "Unable to initialize database. Please install sqlite3.";
            exit 1;
        fi;

        if [ ! -f "$index_file" ]; then
            echo "Initializing database...";
            sqlite3 "$index_file" "CREATE TABLE index (path TEXT PRIMARY KEY);";
        fi;
    }

    ::get() {
        local -r token_path="$1";
        if [[ ! -r "$token_path" ]]; then
            echo "File not found: $token_path";
            return 127;
        fi
        cat "$token_path";
    }

    ::set() {
        setopt nohist

        local -r token_path="$1";
        local -r token_value="$2";

        if [[ ! -w "$token_path" ]]; then
            echo "File not writable: $token_path";
            return 64;
        fi

        echo -e "$token_value" | tee "$token_path" >/dev/null;
    }

    ::list() {
        local -r token_files="$(find "$token_path" -type f -path '**.token' -print0)";
        for token_file in $token_files; do
            local -r token_name="$(basename "$token_file")";
            local -r token_value="$(cat "$token_file")";
            echo "$token_name:$token_value";
        done
    }

    exit 0;
}
